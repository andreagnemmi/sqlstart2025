--Author:		Andrea Gnemmi
--Conference:	SQL Start 2025
--Date:			13/06/2025	

--https://www.postgresql.org/docs/current/pgbench.html
--pgbench 
--pgbench -U postgres -c 50 -j 3 -T 30 chinook
/*
-U indicates the role which runs all the queries, -c the number of sessions, -j the number of threads 
and -T the time in seconds of the test duration.
*/

--alter system set pg_stat_statements.track_planning = on;

select *
from pg_stat_statements_info;


select *
from pg_stat_statements;

--Top 20 slowest queries
SELECT userid::regrole,datname as dbname,  substring(query, 1, 100) AS short_query,
round(total_exec_time::numeric, 2) AS total_exec_time,calls,round(mean_exec_time::numeric, 2) AS mean,
round((100 * total_exec_time /sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM    pg_stat_statements
inner join pg_database
on dbid=oid
--where userid not in (10,30457)
ORDER BY total_exec_time DESC
limit 20;

--High I/O activity
--pay attention as it works only if parameter track_io_timing is set to on, beware of the overhead! pg_test_timing tool
--alter system set track_io_timing = on;

select userid::regrole, datname as dbname, substring(query, 1, 100) AS short_query,
calls,round(mean_exec_time::numeric/1000,4) as mean_time_seconds, 
(shared_blk_read_time+shared_blk_write_time+local_blk_read_time+local_blk_write_time+temp_blk_read_time+temp_blk_write_time) as io_time
from pg_stat_statements
inner join pg_database
on dbid=oid
--where userid not in (10,30457)
order by io_time desc
limit 20;

--top time consuming
select userid::regrole, datname as dbname, substring(query, 1, 100) AS short_query,
calls, total_exec_time/1000 as total_time_seconds ,min_exec_time/1000 as min_time_seconds,
max_exec_time/1000 as max_time_seconds,mean_exec_time/1000 as mean_time_seconds
from pg_stat_statements
inner join pg_database
on dbid=oid
order by mean_exec_time desc
limit 20;

--Queries longer than 1 ms
select rolname, datname as dbname,substring(query, 1, 100) AS short_query, total_exec_time/calls as avgtime_milliseconds, calls,
100.0 * shared_blks_hit /
               nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
from pg_stat_statements
inner join pg_authid aut
on userid=aut.oid
inner join pg_database datab
on dbid=datab.oid
where total_exec_time/calls>1 --and rolname<>'postgres' 

--top high memory usage
select userid::regrole, datname as dbname, substring(query, 1, 100) AS short_query,
(shared_blks_hit+shared_blks_dirtied) as memory_usage,calls,round(mean_exec_time::numeric, 2) AS mean
from pg_stat_statements 
inner join pg_database
on dbid=oid
order by memory_usage desc 
limit 10;

select *
from pg_database;

select pg_stat_statements_reset(); --resets all

select pg_stat_statements_reset(0,57345,-2487540212785485279) --userid Oid, dbid Oid, queryid bigint

--https://www.pgmustard.com/blog/approximate-the-p99-of-a-query-with-pgstatstatements