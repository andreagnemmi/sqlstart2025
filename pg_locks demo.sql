--Author:		Andrea Gnemmi
--Conference:	SQL Start 2025
--Date:			13/06/2025	

--Using test database chinook available in various RDBMS: SQL Server, PostgreSQL, Oracle
--https://github.com/cwoodruff/ChinookDatabase

--simulate a lock on a table in a session
do $$
begin 
lock table "Album" in exclusive mode;
select pg_sleep(360);
end $$;

--insert into using another session
insert into "Album" ("AlbumId", "Title", "ArtistId" )
values (349,'Live at the Greek II', 137);

--select from same table in yet another session
select *
from "Album";

--query pg_locks (in another query window)
select relation ::regclass,locktype, mode, granted, waitstart 
from pg_locks;

