--Author:		Andrea Gnemmi
--Conference:	SQL Start 2025
--Date:			13/06/2025	

--simulate active session in another query window
select pg_sleep(360);

--active sessions
SELECT pid, user, query_start,
  current_timestamp - pg_stat_activity.query_start AS query_time,
  state, substring(query, 100) as query_short, wait_event_type, wait_event
FROM pg_stat_activity
WHERE (current_timestamp - pg_stat_activity.query_start) > interval '30 seconds'; --and state <> 'idle';

--other info on sessions and idle sessions
SELECT pid,datname,application_name, client_addr, user, query_start,
    state
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
	AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled') 
	AND state_change < current_timestamp - INTERVAL '30 seconds';

--terminate idle sessions
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
	AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled') 
	AND state_change < current_timestamp - INTERVAL '1' MINUTE;

--check version for wait infos (PostgreSQL 17)
SELECT version();

--see wait events
select *
from pg_wait_events;

--active sessions with wait event description
SELECT pid, user, query_start,
  current_timestamp - active.query_start AS query_time,
  state, substring(query, 100) as query_short, wait_event_type, wait_event, wait.description
FROM pg_stat_activity as active
inner JOIN pg_wait_events as wait 
ON active.wait_event_type = wait.type AND active.wait_event = wait.name
WHERE (current_timestamp - active.query_start) > interval '30 seconds' and state <> 'idle';

--count active sessions
select count(pid) active_sessions
from pg_stat_activity
where state='active';

--total vs max sessions
with total_sessions as
(select count(pid) tot
from pg_stat_activity),
max_conn as
(SELECT
setting::float 
FROM pg_settings 
WHERE name = 'max_connections')
select tot as total_sessions, setting as max_connections, round(tot/setting::numeric(10,2)*100,2) as perc_max_connections
from total_sessions
cross join max_conn;



--altre query cumulative stats se c'é tempo!
select *
from pg_stat_database;

select *
from pg_stat_user_tables;

select *
from pg_stat_sys_tables;

select *
from pg_stat_user_indexes;

select *
from pg_stat_user_functions;

