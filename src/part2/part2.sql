--  Написать процедуру добавления P2P проверки
-- Параметры: ник проверяемого, ник проверяющего, название задания, статус P2P проверки, время. 
-- Если задан статус "начало", добавить запись в таблицу Checks 
-- (в качестве даты использовать сегодняшнюю). 
-- Добавить запись в таблицу P2P. 
-- Если задан статус "начало", в качестве проверки указать только что добавленную запись, 
-- иначе указать проверку с самым поздним (по времени) незавершенным P2P этапом


DROP PROCEDURE IF EXISTS proc_add_P2P;

CREATE OR REPLACE PROCEDURE proc_add_P2P (checked varchar,
                                          checking varchar,
                                          taskTitle varchar,
                                          P2Pstate status,
                                          P2Ptime time) 
LANGUAGE plpgsql AS $$
DECLARE
    _check_id integer;
BEGIN
    IF P2Pstate = 'Start' THEN
		_check_id = (select max(id) from checks) + 1;
        INSERT INTO Checks (id, Peer, Task, Date)
        VALUES (_check_id, checked, taskTitle, (SELECT CURRENT_DATE));

        _check_id = (select max(id) from checks);
    ELSE _check_id = (SELECT Checks.id
                      FROM p2p
                      JOIN checks
                      ON checks.id = p2p.check_
                      WHERE checkingpeer = checking 
                      AND peer = checked 
                      AND task = taskTitle);
    END IF;

    INSERT INTO P2P (check_, checkingpeer, state, time)
    VALUES (_check_id, checking, P2Pstate, P2Ptime);
END;
$$;

-- 2) Написать процедуру добавления проверки Verter'ом
-- Параметры: ник проверяемого, название задания, статус проверки Verter'ом, время. 

-- Добавить запись в таблицу Verter (в качестве проверки указать проверку соответствующего 
-- задания с самым поздним (по времени) успешным P2P этапом)

DROP PROCEDURE IF EXISTS proc_add_verter_check;
CREATE OR REPLACE PROCEDURE proc_add_verter_check (nickname varchar,
                                                   taskTitle varchar,
                                                   verterState status, 
                                                   checkTime time)
LANGUAGE plpgsql AS $$
DECLARE
    checkID integer;
BEGIN
    checkID = (SELECT checks.id
               FROM p2p
               JOIN checks
               ON checks.id = p2p.check_ AND p2p.state = 'Success' 
               AND checks.task = taskTitle
               AND checks.peer = nickname
               ORDER BY p2p.time ASC
               LIMIT 1);
    INSERT INTO verter (check_, state, time)
    VALUES (checkID, verterState, checkTime);
END
$$;


-- 3) Написать триггер: после добавления записи со статутом "начало" в таблицу P2P, 
-- изменить соответствующую запись в таблице TransferredPoints


DROP TRIGGER IF EXISTS trg_after_insert_p2p ON p2p;
DROP FUNCTION IF EXISTS fnc_trg_after_insert_p2p;

CREATE OR REPLACE FUNCTION fnc_trg_after_insert_p2p() RETURNS TRIGGER AS $trg_after_insert_p2p$
DECLARE
    checked varchar;
    points int;
BEGIN 
    IF (NEW.state = 'Start') THEN 
        checked = (SELECT peer
                   FROM checks
                   WHERE id = NEW.check_);

        points = (SELECT sum(pointsamount)
                  FROM transferredpoints
                  WHERE checkingpeer = NEW.checkingpeer
                  AND checkedpeer = checked);

        IF points IS NULL THEN
            INSERT INTO TransferredPoints(checkingpeer, checkedpeer, pointsamount)
            VALUES(NEW.checkingpeer, checked, 1);
        ELSE
            UPDATE TransferredPoints
            SET pointsamount = points + 1
            WHERE checkingpeer = NEW.checkingpeer
            AND checkedpeer = checked;
        END IF;
    END IF;
    RETURN NEW;
END;
$trg_after_insert_p2p$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_after_insert_p2p
AFTER INSERT ON p2p
FOR EACH ROW EXECUTE FUNCTION fnc_trg_after_insert_p2p();


-- Написать триггер: перед добавлением записи в таблицу XP, проверить корректность добавляемой записи

DROP TRIGGER IF EXISTS trg_xp_add ON XP;

CREATE OR REPLACE FUNCTION fnc_trg_xp_add() RETURNS TRIGGER AS $trg_xp_add$
DECLARE check_success boolean;
		p2p_state status;
		verter_state status;
	BEGIN
	    SELECT State INTO p2p_state FROM P2P WHERE (new.Check_ = P2P.Check_ AND P2P.State != 'Start');
		IF (p2p_state = 'Failure') THEN
			check_success := false;
		ELSE
			check_success := true;
		END IF;
		SELECT State INTO verter_state FROM Verter WHERE (new.Check_ = Verter.Check_ AND Verter.State != 'Start');
		IF (verter_state = 'Failure') THEN
			check_success = false;
		END IF;
		IF (check_success = false) THEN
			raise exception 'Neuspeshnaya proverka';
		END IF;
		RETURN new;
	END;
$trg_xp_add$ LANGUAGE plpgsql;

CREATE TRIGGER trg_xp_add
BEFORE INSERT ON XP
FOR EACH ROW EXECUTE FUNCTION fnc_trg_xp_add();


DROP TRIGGER IF EXISTS trg_max_xp_add on XP;

CREATE OR REPLACE FUNCTION fnc_trg_max_xp_add() RETURNS TRIGGER AS $trg_max_xp_add$
DECLARE xp_tmp bigint;
	begin
	SELECT MaxXP INTO xp_tmp FROM Tasks JOIN Checks ON Checks.Task = Tasks.Title WHERE new.Check_ = Checks.ID;
		IF (new.XPAmount > xp_tmp) THEN
			raise exception ' Bolshe chem MaxXP ';
        ELSIF  (new.XPAmount < 0) THEN
			raise exception 'Men`she chem MaxXP ';
		END IF;
		RETURN new;
	END;
$trg_max_xp_add$ LANGUAGE plpgsql;

CREATE TRIGGER trg_max_xp_add
BEFORE INSERT ON XP
FOR EACH ROW EXECUTE FUNCTION fnc_trg_max_xp_add();

