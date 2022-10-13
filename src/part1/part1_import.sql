
drop procedure if exists import_(varchar, varchar, varchar);
create or replace procedure import_(file_name varchar,
                                         table_name varchar,
                                         delimiter varchar)
language plpgsql
as $$
declare
    dir varchar := (select setting as directory
                         from pg_settings
                         where name = 'data_directory') || '/' || file_name;
begin
    EXECUTE format('copy %s from %L with csv delimiter %L header', quote_ident(table_name), dir, delimiter);
end $$;

create or replace procedure import_checks(delimiter varchar) language plpgsql as $$
begin
    call import_('checks.csv', 'checks', delimiter);
end $$;

create or replace procedure import_Friends(delimiter varchar) language plpgsql as $$
begin
    call import_('friends.csv', 'friends', delimiter);
end $$;

create or replace procedure import_P2P(delimiter varchar) language plpgsql as $$
begin
    call import_('p2p.csv', 'p2p', delimiter);
end $$;

create or replace procedure import_peers(delimiter varchar) language plpgsql as $$
begin
    call import_('peers.csv', 'peers', delimiter);
end $$;

create or replace procedure import_Recommendations(delimiter varchar) language plpgsql as $$
begin
    call import_('recommendations.csv', 'recommendations', delimiter);
end $$;

create or replace procedure import_Tasks(delimiter varchar) language plpgsql as $$
begin
    call import_('tasks.csv', 'tasks', delimiter);
end $$;

create or replace procedure import_TimeTracking(delimiter varchar) language plpgsql as $$
begin
    call import_('timetracking.csv', 'timetracking', delimiter);
end $$;

create or replace procedure import_TransferredPoints(delimiter varchar) language plpgsql as $$
begin
    call import_('transferredpoints.csv', 'transferredpoints', delimiter);
end $$;

create or replace procedure import_Verter(delimiter varchar) language plpgsql as $$
begin
    call import_('verter.csv', 'verter', delimiter);
end $$;

create or replace procedure import_XP(delimiter varchar) language plpgsql as $$
begin
    call import_('xp.csv', 'xp', delimiter);
end $$;

--
call import_peers(',');
call import_tasks(',');
call import_checks(',');
call import_xp(',');
call import_friends(',');
call import_p2p(',');
call import_timetracking(',');
call import_transferredpoints(',');
call import_verter(',');
call import_recommendations(',');
