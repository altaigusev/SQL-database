drop procedure if exists export_(varchar, varchar, varchar);
create or replace procedure export_(file_name varchar,
                                         table_name varchar,
                                         delimiter varchar)
language plpgsql
as $$
declare
    dir varchar := (select setting as directory
                         from pg_settings
                         where name = 'data_directory') || '/' || file_name;
begin
    EXECUTE format('copy %s to %L with csv delimiter %L header', quote_ident(table_name), dir, delimiter);
end $$;

create or replace procedure export_checks(delimiter varchar) language plpgsql as $$
begin
    call export_('checks.csv', 'checks', delimiter);
end $$;

create or replace procedure export_friends(delimiter varchar) language plpgsql as $$
begin
    call export_('friends.csv', 'friends', delimiter);
end $$;

create or replace procedure export_p2p(delimiter varchar) language plpgsql as $$
begin
    call export_('p2p.csv', 'p2p', delimiter);
end $$;

create or replace procedure export_peers(delimiter varchar) language plpgsql as $$
begin
    call export_('peers.csv', 'peers', delimiter);
end $$;

create or replace procedure export_recommendations(delimiter varchar) language plpgsql as $$
begin
    call export_('recommendations.csv', 'recommendations', delimiter);
end $$;

create or replace procedure export_tasks(delimiter varchar) language plpgsql as $$
begin
    call export_('tasks.csv', 'tasks', delimiter);
end $$;

create or replace procedure export_timetracking(delimiter varchar) language plpgsql as $$
begin
    call export_('timetracking.csv', 'timetracking', delimiter);
end $$;

create or replace procedure export_transferredpoints(delimiter varchar) language plpgsql as $$
begin
    call export_('transferredpoints.csv', 'transferredpoints', delimiter);
end $$;

create or replace procedure export_verter(delimiter varchar) language plpgsql as $$
begin
    call export_('verter.csv', 'verter', delimiter);
end $$;

create or replace procedure export_xp(delimiter varchar) language plpgsql as $$
begin
    call export_('xp.csv', 'xp', delimiter);
end $$;
--
call export_checks(',');
call export_friends(',');
call export_p2p(',');
call export_peers(',');
call export_recommendations(',');
call export_tasks(',');
call export_timetracking(',');
call export_transferredpoints(',');
call export_verter(',');
call export_xp(',');