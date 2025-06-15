--Author:		Andrea Gnemmi
--Conference:	SQL Start 2025
--Date:			13/06/2025	

--first query combining pg_locks and pg_stat_activity
select relation ::regclass,locktype, wait_event_type, wait_event, mode, granted, waitstart
, state,left(query, 100) as short_query, usename
from pg_locks loc
inner join pg_stat_activity act
on loc.pid=act.pid
where wait_event is not null;

/*
extracting also blocking sessions info
At this point we can go further putting all the info of the blocked session and the session blocking it together, 
introducing the function pg_blocking_pids(pid) which returns an array of integers with all the blocking pids. 
*/
with blockers as 
(select pid, unnest(pg_blocking_pids(pid)) as blocked_by
from pg_locks
where granted is false)
, lockers as
(select pid, relation ::regclass,locktype, mode, granted, waitstart
from pg_locks
where granted is false)
select blockers.pid as blocked_pid, blocked_by as blocked_by_pid,relation, act.wait_event_type, act.wait_event, mode, waitstart
, left(act.query, 100) as blocked_query, act.usename as blocked_username, actb.wait_event_type||' '||actb.wait_event as wait_blocker, left(actb.query, 100) as blocking_query
,actb.usename as blocking_username
from blockers inner join lockers
on blockers.pid=lockers.pid
inner join pg_stat_activity act
on lockers.pid=act.pid
inner join pg_stat_activity actb
on blockers.blocked_by=actb.pid;




--more info
select loc.pid, pg_blocking_pids(loc.pid) as blocked_by,relation ::regclass,locktype, wait_event_type, wait_event, mode, granted--, waitstart
, state,left(query, 100) as short_query, usename
from pg_locks loc
inner join pg_stat_activity act
on loc.pid=act.pid
where wait_event is not null and granted is false;




