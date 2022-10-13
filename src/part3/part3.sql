-- 1) Написать функцию, возвращающую таблицу TransferredPoints в более человекочитаемом виде
-- Ник пира 1, ник пира 2, количество переданных пир поинтов. 
-- Количество отрицательное, если пир 2 получил от пира 1 больше поинтов.

DROP FUNCTION IF EXISTS TransferredPoints;
CREATE OR REPLACE FUNCTION TransferredPoints () RETURNS TABLE (peer1 varchar, peer2 varchar, pointsamount numeric) 
AS $$ BEGIN RETURN QUERY EXECUTE 
'with t1 as (select checkingpeer as Peer1, 
checkedpeer as Peer2, 
SUM(pointsamount) as pointsamount
from transferredpoints
GROUP by Peer1, Peer2)

select tt1.peer1, tt1.peer2, (tt1.pointsamount - tt2.pointsamount) as pointsamount
from t1 tt1, t1 tt2
where (tt1.peer1 = tt2.peer2) and (tt1.peer2 = tt2.peer1) and tt1.peer1 < tt2.peer1
union all
(select tt1.peer1, tt1.peer2, tt1.pointsamount
from t1 tt1
except
select tt1.peer1, tt1.peer2, tt1.pointsamount 
from t1 tt1, t1 tt2
where (tt1.peer1 = tt2.peer2) and (tt1.peer2 = tt2.peer1))
order by peer1, peer2';
END;
$$ LANGUAGE plpgsql;

select *
from TransferredPoints();

-- 2) Написать функцию, которая возвращает таблицу вида: ник пользователя, название проверенного задания, 
-- кол-во полученного XP
-- В таблицу включать только задания, успешно прошедшие проверку (определять по таблице Checks).
-- Одна задача может быть успешно выполнена несколько раз. В таком случае в таблицу включать все успешные проверки.

DROP FUNCTION IF EXISTS checkXPOnPeer;
create or replace function checkXPOnPeer() returns table (peer varchar, task varchar, xp bigint)
AS $$ BEGIN RETURN QUERY EXECUTE 
  'select peer, task, xp.xpamount as XP from checks
left join xp on xp.check_ = checks.id
left join p2p on p2p.check_ = checks.id
left join verter on verter.check_ = checks.id
where p2p.state = ''Success'' and (verter.state = ''Success'' or verter.state is Null)';
END;
$$ LANGUAGE plpgsql;

select *
from checkXPOnPeer();

-- 3) Написать функцию, определяющую пиров, которые не выходили из кампуса в течение всего дня
-- Параметры функции: день, например 12.05.2022.
-- Функция возвращает только список пиров.

DROP FUNCTION IF EXISTS tracking;
create or replace function tracking(dt date) returns table (ppeer varchar)
AS $func$
BEGIN
RETURN QUERY
select peer
from timetracking
where date = dt
group by peer
having SUM(state) = 1;
END;
$func$ LANGUAGE plpgsql;

select * from tracking(dt := '2022-09-21');

-- 4) Найти процент успешных и неуспешных проверок за всё время
-- Формат вывода: процент успешных, процент неуспешных

DROP PROCEDURE IF EXISTS successPercent;
CREATE OR REPLACE PROCEDURE successPercent(result_data refcursor)
AS $$ BEGIN OPEN result_data FOR with ff as (
select id, check_, state, time from p2p
where not (state = 'Start')
union all
select id, check_,state, time from verter
where not (state = 'Start'))
select (cast(cast((select count(*)
from p2p
where not (state = 'Start')) - count(*) as numeric) / (select count(*)
from p2p
where not (state = 'Start')) * 100 as int)) AS SuccessfulChecks ,
cast(cast(count(*) as numeric) / (select count(*)
from p2p
where not (state = 'Start')) * 100 as int) AS UnsuccessfulChecks
from ff
where (state = 'Failure');
END;
$$ LANGUAGE plpgsql;

CALL successPercent('data');
fetch all from "data";
close "data";

-- 5) Посчитать изменение в количестве пир поинтов каждого пира по таблице TransferredPoints
-- Результат вывести отсортированным по изменению числа поинтов. 
-- Формат вывода: ник пира, изменение в количество пир поинтов

DROP PROCEDURE IF EXISTS ChangePoints;
CREATE OR REPLACE PROCEDURE ChangePoints (result_data refcursor)
AS $$ BEGIN OPEN result_data FOR
select checkingpeer as Peer, SUM(pointsamount) as PointsChange
from
(
SELECT checkingpeer, SUM(pointsamount) as pointsamount
FROM TransferredPoints
group by checkingpeer
union all
SELECT checkedpeer, SUM(-pointsamount) as pointsamount
FROM TransferredPoints
group by checkedpeer) as change
group by Peer
order by Peer;
END;
$$ LANGUAGE plpgsql;

CALL ChangePoints('data');
fetch all from "data";
close "data";

-- 6) Посчитать изменение в количестве пир поинтов каждого пира по таблице, возвращаемой первой функцией из Part 3
-- Результат вывести отсортированным по изменению числа поинтов. 
-- Формат вывода: ник пира, изменение в количество пир поинтов

DROP procedure IF EXISTS ChangePointsOnFirstFoo;
CREATE OR REPLACE procedure ChangePointsOnFirstFoo (result_data refcursor) 
AS $$ BEGIN OPEN result_data FOR
select peer1 as Peer, sum(pointsamount) as PointsChange
from
(select peer1, SUM(pointsamount) as pointsamount 
from TransferredPoints()
group by peer1
union all
select peer2, SUM(-pointsamount) as pointsamount
from TransferredPoints()
group by peer2) as change
group by Peer
order by Peer;
END;
$$ LANGUAGE plpgsql;

CALL ChangePointsOnFirstFoo('data');
fetch all from "data";
close "data";

-- 7) Определить самое часто проверяемое задание за каждый день
-- При одинаковом количестве проверок каких-то заданий в определенный день, вывести их все. 
-- Формат вывода: день, название задания

DROP procedure IF EXISTS TopTaskOnDate;
create or replace procedure TopTaskOnDate(result_data refcursor)
AS $$ BEGIN OPEN result_data FOR
  WITH t1 AS (
    SELECT date, checks.task, COUNT(task) AS count_
    FROM checks
    GROUP BY checks.task, date
)
SELECT date AS day, t2.task
FROM (
    SELECT t1.task, t1.date, rank() OVER (PARTITION BY t1.date ORDER BY count_ DESC) AS rank
    FROM t1
    ) AS t2
WHERE rank = 1
ORDER BY day;
END;
$$ LANGUAGE plpgsql;

CALL TopTaskOnDate('data');
fetch all from "data";
close "data";

-- 8) Определить длительность последней P2P проверки
-- Под длительностью подразумевается разница между временем, указанным в записи со статусом "начало", и временем, указанным в записи со статусом "успех" или "неуспех". 
-- Формат вывода: длительность проверки

DROP PROCEDURE IF EXISTS checkDuration;
CREATE OR REPLACE PROCEDURE checkDuration()
AS $$
declare dur time;
BEGIN
dur := (with t1 as (select * from p2p
where id = (SELECT max(id)
            FROM p2p) or id = (SELECT max(id)FROM p2p) - 1)
select tt2.time - tt1.time as Duration_Time from t1 tt1, t1 tt2
where tt2.id = (SELECT max(id) FROM t1) and tt1.id = (SELECT max(id) FROM t1) - 1);
raise notice '%', dur;
END;
$$ LANGUAGE plpgsql;

call checkDuration();

-- 9) Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания
-- Параметры процедуры: название блока, например "CPP". 
-- Результат вывести отсортированным по дате завершения. 
-- Формат вывода: ник пира, дата завершения блока (т.е. последнего выполненного задания из этого блока)

DROP PROCEDURE IF EXISTS finishBlock;
CREATE OR REPLACE PROCEDURE finishBlock(result_data refcursor, inBlock varchar)
AS $$ BEGIN OPEN result_data for

select checks.peer, date  from checks
full join p2p on p2p.check_ = checks.id
full join verter on verter.check_ = checks.id 
where p2p.state = 'Success' and  (verter.state = 'Success' or verter.state is null) 
and checks.task = (
select title
from (select title, substring(tasks.title from '^[A-Z]*') as block
from tasks) as t1
where t1.block = inBlock
order by title DESC
limit 1);
END;
$$ LANGUAGE plpgsql;

CALL finishBlock('task9', 'C');
fetch all
from "task9";

-- 10) Определить, к какому пиру стоит идти на проверку каждому обучающемуся
-- Определять нужно исходя из рекомендаций друзей пира, т.е. нужно найти пира, проверяться у которого рекомендует наибольшее число друзей. 
-- Формат вывода: ник пира, ник найденного проверяющего

DROP PROCEDURE IF EXISTS mostRecommended;
CREATE OR REPLACE PROCEDURE mostRecommended(result_data refcursor)
AS $$ BEGIN OPEN result_data for
select peer1, recommendedpeer from 
(with t1 as (select peer1, peer2 as friend from friends
union all
select peer2, peer1 as friend from friends
)
select distinct ON(peer1)peer1, 
recommendedpeer,
COUNT(friend) as num

from t1
full join recommendations on t1.friend = Recommendations.peer
where peer1 != recommendedpeer
group by peer1, recommendedpeer
order by peer1, num desc) as tt2;
END;
$$ LANGUAGE plpgsql;

CALL mostRecommended('task10');
fetch all
from "task10";


-- 11) Определить процент пиров, которые:

-- Приступили к блоку 1
-- Приступили к блоку 2
-- Приступили к обоим
-- Не приступили ни к одному

-- Параметры процедуры: название блока 1, например CPP, название блока 2, например A. 
-- Формат вывода: процент приступивших к первому блоку, процент приступивших ко второму блоку, процент приступивших к обоим, процент не приступивших ни к одному

DROP PROCEDURE IF EXISTS blockStat;
CREATE OR REPLACE PROCEDURE blockStat(result_data refcursor, 
block1 varchar, block2 varchar)
AS $$
BEGIN OPEN result_data for
with t1 as
(select * 
from 
(select distinct on (peer) peer, title, substring(tasks.title from '^[A-Z]*') as block
from tasks
join checks ch on ch.task = title) as t1
where block = block1),
t2 as (select * 
from 
(select distinct on (peer) peer, title, substring(tasks.title from '^[A-Z]*') as block
from tasks
join checks ch on ch.task = title) as t1
where block = block2),
t3 as (select * from (select *
from t2
intersect
select *
from t1) as inter),
t4 as (select nickname as peer from peers
	  except
	  (select peer from t1 union select peer from t2)),
total as (select count(*) from peers),
first_col as (select (count(*) * 100 / (select * from total)) as StartedBlock1
from t1),
second_col as (select (count(*) * 100 / (select * from total)) as StartedBlock2
from t2),
third_col as (select (count(*) * 100 / (select * from total)) as StartedBothBlocks
from t3),
fourth_col as (select (count(*) * 100 / (select * from total)) as DidntStartAnyBlock
from t4)
select *
from first_col fc, second_col sc, third_col tc, fourth_col frc;
END;
$$ LANGUAGE plpgsql;

call blockStat('task11', 'CPP', 'C');
fetch all from "task11";

-- 12) Определить N пиров с наибольшим числом друзей
-- Параметры процедуры: количество пиров N. 
-- Результат вывести отсортированным по кол-ву друзей. 
-- Формат вывода: ник пира, количество друзей

DROP PROCEDURE IF EXISTS mostFriendly;
CREATE OR REPLACE PROCEDURE mostFriendly(result_data refcursor,num int)
AS $$ BEGIN OPEN result_data for
select peer1, count(peer2)
from friends
group by peer1
limit num;
END;
$$ LANGUAGE plpgsql;

CALL mostFriendly('task12', '2');
fetch all
from "task12";
close "task12";

-- 13) Определить процент пиров, которые когда-либо успешно проходили проверку в свой день рождения
-- Также определите процент пиров, которые хоть раз проваливали проверку в свой день рождения. 
-- Формат вывода: процент успехов в день рождения, процент неуспехов в день рождения

DROP PROCEDURE IF EXISTS BirhdayChecks;
CREATE OR REPLACE PROCEDURE BirhdayChecks(result_data refcursor)
AS $$ BEGIN OPEN result_data for

select 
((select count(peer) as SuccessfulChecks from checks
full join peers on peers.nickname = checks.peer
full join p2p on p2p.check_ = checks.id
full join verter on verter.check_ = checks.id 
where extract(day from checks.date ) = extract(day from peers.birthday)
            and 
      extract(month from checks.date) = extract(month from peers.birthday) and
      p2p.state = 'Success' and (Verter.state = 'Success' or Verter.state is null)) * 100) / count(peers.nickname) as SuccessfulChecks,
      
      ((select count(peer) as UnsuccessfulChecks from checks
full join peers on peers.nickname = checks.peer
full join p2p on p2p.check_ = checks.id
full join verter on verter.check_ = checks.id 
where extract(day from checks.date ) = extract(day from peers.birthday)
            and 
      extract(month from checks.date) = extract(month from peers.birthday) and
      p2p.state = 'Failure' and (Verter.state = 'Failure' or Verter.state is null)) * 100) / count(peers.nickname) as UnsuccessfulChecks
from peers;

END;
$$ LANGUAGE plpgsql;

CALL BirhdayChecks('task13');
fetch all from task13;

-- 14) Определить кол-во XP, полученное в сумме каждым пиром
-- Если одна задача выполнена несколько раз, полученное за нее кол-во XP равно максимальному за эту задачу. 
-- Результат вывести отсортированным по кол-ву XP. 
-- Формат вывода: ник пира, количество XP

DROP PROCEDURE IF EXISTS SumXP;
CREATE OR REPLACE PROCEDURE SumXP(result_data refcursor)
AS $$ BEGIN OPEN result_data for

select peer, SUM(XPAmount) AS XP from (
select peer, task, MAX(XPAmount) AS XPAmount 
from xp
 join checks on checks.id = xp.check_
 group by peer,task
) as xpp
group by peer
order by XP DESC;

END;
$$ LANGUAGE plpgsql;

CALL SumXP('task14');
fetch all from "task14";


-- 15) Определить всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
-- Параметры процедуры: названия заданий 1, 2 и 3. 
-- Формат вывода: список пиров
DROP PROCEDURE IF EXISTS firstSecondButNotThird;
CREATE OR REPLACE PROCEDURE firstSecondButNotThird(result_data refcursor, 
task1 varchar, task2 varchar, task3 varchar)
AS $$
BEGIN OPEN result_data for
with raw_data as 
(select ch.peer, task
from p2p
join verter v on v.check_ = p2p.check_
join checks ch on ch.id = p2p.check_
where v.state = 'Success' and p2p.state = 'Success')
select peer
from raw_data
where task = task1
intersect
select peer
from raw_data
where task = task2
except
select peer
from raw_data
where task = task3;
END;
$$ LANGUAGE plpgsql;

call firstSecondButNotThird('task14', 'C2_SimpleBashUtils', 'C3_s21_stringplus', 'C5_s21_decimal');
fetch all from "task14";

-- 16)
--  Используя рекурсивное обобщенное табличное выражение, для каждой задачи вывести кол-во предшествующих ей задач
-- То есть сколько задач нужно выполнить, исходя из условий входа, чтобы получить доступ к текущей. 
-- Формат вывода: название задачи, количество предшествующих
DROP PROCEDURE IF EXISTS previousTasks;
CREATE OR REPLACE PROCEDURE previousTasks(result_data refcursor)
AS $$ BEGIN OPEN result_data FOR 
WITH RECURSIVE r(title, parenttask, n) AS (
    SELECT tasks.title,
        tasks.parenttask,
        0
    FROM tasks
    UNION
    SELECT T.title,
        T.parenttask,
        n + 1
    FROM tasks T
        INNER JOIN r ON r.title = T.parenttask
)
SELECT title AS Task,
    MAX(n) AS PrevCount
FROM r
GROUP BY title;
END;
$$ LANGUAGE plpgsql;

call previousTasks('task16');
fetch all from "task16";

-- 17) Найти "удачные" для проверок дни. День считается "удачным", если в нем есть хотя бы N идущих подряд успешных проверки
-- Параметры процедуры: количество идущих подряд успешных проверок N. 
-- Временем проверки считать время начала P2P этапа. 
-- Под идущими подряд успешными проверками подразумеваются успешные проверки, между которыми нет неуспешных. 
-- При этом кол-во опыта за каждую из этих проверок должно быть не меньше 80% от максимального.

DROP PROCEDURE IF EXISTS LuckyDays;
CREATE OR REPLACE PROCEDURE LuckyDays (result_data refcursor, N int) AS $$ BEGIN OPEN result_data FOR 
WITH data AS(
        SELECT date,time, status_check, LEAD(status_check) OVER (ORDER BY date, time) AS next_status_check
        FROM ( SELECT checks.date,
                 case WHEN 100 * xp.XPAmount / tasks.MaxXP >= 80 THEN true
                      ELSE false
                END AS status_check, p2p.time
                FROM checks
                    JOIN tasks ON checks.task = tasks.title
                    JOIN xp ON checks.id = xp.check_
                    JOIN p2p ON checks.id = p2p.check_
                    AND p2p.state in('Success', 'Failure')) 
         ch), data_prev_checks AS ( 
         SELECT t1.date, t1.time, t1.status_check, t1.next_status_check, COUNT (t2.date)
         FROM data t1
         JOIN data t2 on t1.date = t2.date AND t1.time <= t2.time AND t1.status_check = t2.next_status_check
         GROUP BY t1.date, t1.time, t1.status_check, t1.next_status_check)
SELECT date
FROM ( SELECT date, MAX(success_count) AS max_success_count
      FROM ( SELECT date, count as success_count
                FROM data_prev_checks
                WHERE status_check
            ) success_checks
       GROUP BY date) m
WHERE max_success_count >= N;
END;
$$ LANGUAGE plpgsql;

call LuckyDays ('task17', 2);
fetch all from "task17";

-- 18) Определить пира с наибольшим числом выполненных заданий
-- Формат вывода: ник пира, число выполненных заданий
DROP PROCEDURE IF EXISTS maxXP;
CREATE OR REPLACE PROCEDURE maxXP(result_data refcursor)
AS $$ BEGIN OPEN result_data for

select peer, count(xpamount) XP from xp 
join checks on checks.id = xp.check_
group by peer
order by XP desc limit 1;

END;
$$ LANGUAGE plpgsql;

CALL maxXP('task18');
fetch all from "task18";

--  19) Определить пира с наибольшим количеством XP


DROP PROCEDURE IF EXISTS max_xp_peer;
CREATE OR REPLACE PROCEDURE max_xp_peer(result_data refcursor)
LANGUAGE plpgsql AS $$
BEGIN
OPEN result_data FOR
    SELECT peers.nickname, sum(xp.xpamount)
    FROM peers
    JOIN checks
    ON peers.nickname = checks.peer
    JOIN xp
    ON checks.id = xp.check_
    GROUP BY peers.nickname
    ORDER BY sum DESC
    LIMIT 1;
END;
$$;

CALL max_xp_peer('data');
fetch all from "data";


-- 20) Определить пира, который провел сегодня в кампусе больше 
-- всего времени. Формат вывода: ник пира


DROP PROCEDURE IF EXISTS max_time_peer;
CREATE OR REPLACE PROCEDURE max_time_peer(result_data refcursor)
LANGUAGE plpgsql AS $$
BEGIN
OPEN result_data FOR
    WITH startState AS (SELECT peer, time AS inTime, state
               FROM timetracking
                WHERE state = 1
                AND date = CURRENT_DATE),
        finishState AS (SELECT peer, time AS outTime, state
               FROM timetracking
                WHERE state = 2
                AND date = CURRENT_DATE)

    SELECT startState.peer
    FROM startState
    JOIN finishState
    ON startState.peer = finishState.peer
    ORDER BY finishState.outTime - startState.inTime DESC
    LIMIT 1; 
END;
$$;

CALL max_time_peer('data');
fetch all from "data";

-- 21) Определить пиров, приходивших раньше заданного времени не менее N раз за всё время
-- Параметры процедуры: время, количество раз N. 
-- Формат вывода: список пиров


DROP PROCEDURE IF EXISTS max_time_spent;
CREATE OR REPLACE PROCEDURE max_time_spent(result_data refcursor, checkedTime time, N integer) 
LANGUAGE plpgsql AS $$ 
BEGIN 
    OPEN result_data FOR 
    SELECT peer
    FROM timetracking
    WHERE state = 1
    AND time < checkedTime
    GROUP BY peer
    HAVING count(peer) > N;
END;
$$;

CALL max_time_spent('data', '22:00', 1);
fetch all from "data";

-- 22) Определить пиров, выходивших за последние N дней из кампуса больше M раз
-- Параметры процедуры: количество дней N, количество раз M. 
-- Формат вывода: список пиров


DROP PROCEDURE IF EXISTS out_of_campus_peers;
CREATE OR REPLACE PROCEDURE out_of_campus_peers(result_data refcursor, daysCount integer, N integer) 
LANGUAGE plpgsql AS $$ 
BEGIN 
    OPEN result_data FOR 
    SELECT peer
    FROM timetracking
    WHERE timetracking.state = 2
    AND current_date - timetracking.date <= daysCount
    GROUP BY peer
    HAVING COUNT(peer) > N;
END;
$$;

CALL out_of_campus_peers('data', 30, 1);
fetch all from "data";


-- 23) Определить пира, который пришел сегодня последним
-- Формат вывода: ник пира


DROP PROCEDURE IF EXISTS last_entered_peer;
CREATE OR REPLACE PROCEDURE last_entered_peer(result_data refcursor) 
LANGUAGE plpgsql AS $$
BEGIN
    OPEN result_data FOR
    SELECT peer
    FROM timetracking
    WHERE date = current_date
    AND state = 1
    ORDER BY time DESC
    LIMIT 1;
END;
$$; 

CALL last_entered_peer('data');
fetch all from "data";


-- 24) Определить пиров, которые выходили вчера из кампуса 
-- больше чем на N минут
-- Параметры процедуры: количество минут N. 
-- Формат вывода: список пиров


DROP PROCEDURE IF EXISTS yesterday_out_peers;
CREATE OR REPLACE PROCEDURE yesterday_out_peers(result_data refcursor, minutesCounts integer)
LANGUAGE plpgsql AS $$
BEGIN
OPEN result_data FOR
    WITH startState AS (SELECT *
                   FROM timetracking
                   WHERE state = 1
                   AND date = CURRENT_DATE - 1),
    finishState AS (SELECT *
                    FROM timetracking
                    WHERE state = 2
                    AND date = CURRENT_DATE - 1)

    SELECT startState.peer
    FROM startState
    JOIN finishState 
    ON startState.peer = finishState.peer
    AND finishState.time < startState.time
    AND startState.time - finishState.time > concat(minutesCounts, 'minutes')::interval;
END;
$$;

CALL yesterday_out_peers('data', 59);
fetch all from "data";

CALL yesterday_out_peers('data', 15);
fetch all from "data";


-- 25) Определить для каждого месяца процент ранних входов
-- Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, 
-- приходили в кампус за всё время (будем называть это общим числом входов). 
-- Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, 
-- приходили в кампус раньше 12:00 за всё время (будем называть это числом ранних входов). 
-- Для каждого месяца посчитать процент ранних входов в кампус относительно общего числа входов. 
-- Формат вывода: месяц, процент ранних входов


DROP PROCEDURE IF EXISTS early_entry;
CREATE OR REPLACE PROCEDURE early_entry(result_data refcursor) 
LANGUAGE plpgsql AS $$
BEGIN
OPEN result_data FOR
    WITH gs AS (SELECT generate_series(1, 12) as months),
    all_entry AS (SELECT DATE_PART('month', timetracking.date) as months, COUNT(*) AS counts
                  FROM timetracking
                  JOIN peers
                  ON timetracking.peer = peers.nickname
                  WHERE timetracking.state = '1'
                  AND DATE_PART('month', peers.birthday) = DATE_PART('month', timetracking.date)
                  GROUP BY months),
    early_entry AS (SELECT DATE_PART('month', timetracking.date) as months, count(*) AS counts
                    FROM timetracking
                    JOIN peers
                    ON timetracking.peer = peers.nickname
                    WHERE timetracking.state = '1'
                    AND DATE_PART('month', peers.birthday) = DATE_PART('month', timetracking.date)
                    AND timetracking.time < '12:00:00'
                    GROUP BY months)

    SELECT to_char(to_timestamp(entery.months::text, 'MM'), 'MONTH') AS Month, 
           entery.count2 * 100 / entery.count1 AS EarlyEntries
    FROM (SELECT gs.months, all_entry.counts as count1,
                 early_entry.counts as count2
          FROM gs
            JOIN all_entry ON all_entry.months = gs.months
            JOIN early_entry ON early_entry.months = gs.months
        ) AS entery;
END;
$$;

CALL early_entry('data');
fetch all from "data";
