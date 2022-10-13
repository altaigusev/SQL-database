drop table if exists Peers CASCADE;
drop table if exists Tasks CASCADE;
drop table if exists Checks CASCADE;
drop table if exists P2P CASCADE;
drop table if exists Verter CASCADE;
drop table if exists TransferredPoints CASCADE;
drop table if exists Friends CASCADE;
drop table if exists Recommendations CASCADE;
drop table if exists XP CASCADE;
drop table if exists TimeTracking CASCADE;
DROP TYPE IF EXISTS status CASCADE;

create table if not exists Peers
( Nickname varchar primary key,
 Birthday date not null
);

create table if not exists Tasks
( Title varchar primary key,
 ParentTask varchar,
 MaxXP bigint NOT NULL,
 foreign key (ParentTask) references Tasks(Title)
);

drop trigger if exists trg_tasks_add on tasks;

create or replace function fnc_trg_tasks_add() returns trigger as $trg_tasks_add$
declare null_tasks_count bigint;
	begin
	    select count(*) into null_tasks_count from tasks  where ParentTask is null;
		if (num_nulls(new.ParentTask) = 1 and null_tasks_count = 1) then
			raise exception 'only one null';
		end if;
		return new;
	end;
$trg_tasks_add$ language plpgsql;

create trigger trg_tasks_add
before insert on tasks
for each row execute function fnc_trg_tasks_add();

create type status as enum ('Start', 'Success', 'Failure');

create table if not exists Checks
( ID serial primary key,
 Peer varchar not null,
 Task varchar not null,
 Date date,
 constraint fk_Checks_Peers foreign key (Peer) references Peers(Nickname),
 constraint fk_Checks_Tasks foreign key (Task) references Tasks(Title)
);


create table if not exists P2P
(
	ID serial primary key,
	Check_ bigint not null,
	CheckingPeer varchar not null,
	State status,
	Time time,
	constraint fk_P2P_Checks foreign key (Check_) references Checks(ID),
	constraint fk_P2P_Peers foreign key (CheckingPeer) references Peers(Nickname)
);

drop trigger if exists trg_p2p_add on P2P;
create or replace function fnc_trg_p2p_add() returns trigger as $trg_p2p_add$
declare p2p_count int;
	begin
		select count(*) into p2p_count from P2P where new.Check_ = p2p.Check_;
		if (p2p_count > 1 or (p2p_count = 0 and new.State !='Start')) then
			raise exception 'Tolko 2 zapisi odnoy proverky i pervaya - Start';
		end if;
		return new;
	end;
$trg_p2p_add$ language plpgsql;

create trigger trg_p2p_add
before insert on p2p
for each row execute function fnc_trg_p2p_add();

create table if not exists Verter
( 	ID serial primary key,
	Check_ bigint not null,
	State status,
	Time time,
    constraint fk_Verter_Checks foreign key (Check_) references Checks(ID)
);

drop trigger if exists trg_verter_add on verter;
create or replace function fnc_trg_verter_add() returns trigger as $trg_verter_add$
declare p2p_check status;
		verter_check status;
		verter_count int;
	begin
	    select State into p2p_check from P2P where new.Check_ = P2P.Check_ and P2P.State != 'Start';
		if (p2p_check = 'Failure') then
			raise exception 'verter ne mozhet proverit to chto zafeilili piry';
		end if;
		select count(*) into verter_count from verter where new.Check_ = Verter.Check_;
		if (verter_count > 1 or (verter_count = 0 and new.State !='Start')) then
			raise exception 'Tolko 2 zapisi odnoy proverky i pervaya - Start';
		end if;
		
		return new;
	end;
$trg_verter_add$ language plpgsql;

create trigger trg_verter_add
before insert on verter
for each row execute function fnc_trg_verter_add();


create table if not exists TransferredPoints
( ID serial primary key,
  CheckingPeer varchar not null,
 CheckedPeer varchar not null,
 PointsAmount bigint not null default 1,
 constraint fk_TransferredPoints_Peers foreign key (CheckingPeer) references Peers(Nickname),
 constraint fk_TransferredPoints_Peers_ foreign key (CheckedPeer) references Peers(Nickname),
 check (CheckingPeer != CheckedPeer)
);

create table if not exists Friends
( ID serial primary key,
  Peer1 varchar not null,
 Peer2 varchar not null,
 constraint fk_Friends_Peers foreign key (Peer1) references Peers(Nickname),
 constraint fk_Friends_Peers_ foreign key (Peer2) references Peers(Nickname),
 check (Peer1 != Peer2)
);

drop trigger if exists trg_friends_add on Friends;
create or replace function fnc_trg_friends_add() returns trigger as $trg_friends_add$
declare friend_count bigint;
	begin
	    select count(*) into friend_count from Friends where (new.Peer1 = Friends.Peer1 and new.Peer2 = Friends.Peer2) or
														(new.Peer1 = Friends.Peer2 and new.Peer2 = Friends.Peer1);
		if (friend_count > 0) then
			raise exception 'Para uzhe est';
		end if;
		return new;
	end;
$trg_friends_add$ language plpgsql;

create trigger trg_friends_add
before insert on Friends
for each row execute function fnc_trg_friends_add();

create table if not exists Recommendations
( ID serial primary key,
  Peer varchar not null,
  RecommendedPeer varchar default null,
  constraint fk_Recommendations_Peers foreign key (Peer) references Peers(Nickname),
  constraint fk_Recommendations_Peers_ foreign key (RecommendedPeer) references Peers(Nickname),
 check (Peer != RecommendedPeer),
 unique (Peer, RecommendedPeer)
);

drop trigger if exists trg_recommendations_add on Recommendations;
create or replace function fnc_trg_recommendations_add() returns trigger as $trg_recommendations_add$
declare recom_count bigint;
	begin
	    select count(*) into recom_count from TransferredPoints where (new.Peer = TransferredPoints.CheckedPeer and 
																	   new.RecommendedPeer = TransferredPoints.CheckingPeer);
		if (recom_count = 0) then
			raise exception 'Oni ne proveryalis';
		end if;
		return new;
	end;
$trg_recommendations_add$ language plpgsql;

create trigger trg_recommendations_add
before insert on Recommendations
for each row execute function fnc_trg_recommendations_add();


create table if not exists XP
( ID serial primary key,
  Check_ bigint not null,
  XPAmount bigint,
  constraint fk_XP_Checks foreign key (Check_) references Checks(ID)
);

-- drop trigger if exists trg_xp_add on XP;
-- create or replace function fnc_trg_xp_add() returns trigger as $trg_xp_add$
-- declare check_success boolean;
-- 		p2p_state status;
-- 		verter_state status;
-- 	begin
-- 	    select State into p2p_state from P2P where (new.Check_ = P2P.Check_ and P2P.State != 'Start');
-- 		if (p2p_state = 'Failure') then
-- 			check_success := false;
-- 		else
-- 			check_success := true;
-- 		end if;
-- 		select State into verter_state from Verter where (new.Check_ = Verter.Check_ and Verter.State != 'Start');
-- 		if (verter_state = 'Failure') then
-- 			check_success = false;
-- 		end if;
-- 		if (check_success = false) then
-- 			raise exception 'Neuspeshnaya proverka';
-- 		end if;
-- 		return new;
-- 	end;
-- $trg_xp_add$ language plpgsql;

-- create trigger trg_xp_add
-- before insert on XP
-- for each row execute function fnc_trg_xp_add();


-- drop trigger if exists trg_max_xp_add on XP;
-- create or replace function fnc_trg_max_xp_add() returns trigger as $trg_max_xp_add$
-- declare xp_tmp bigint;
-- 	begin
-- 	select MaxXP into xp_tmp from Tasks join Checks on Checks.Task = Tasks.Title where new.Check_ = Checks.ID;
-- 		if (new.XPAmount > xp_tmp) then
-- 			raise exception ' Bolshe chem MaxXP ';
-- 		end if;
-- 		return new;
-- 	end;
-- $trg_max_xp_add$ language plp gsql;

-- create trigger trg_max_xp_add
-- before insert on XP
-- for each row execute function fnc_trg_max_xp_add();


create table if not exists TimeTracking
( ID serial primary key,
  Peer varchar not null,
  Date date,
  Time time,
  State int check (State in (1, 2)),
  constraint fk_TimeTracking_Peers foreign key (Peer) references Peers(Nickname)
);
