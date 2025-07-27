--This script shows the top cost sql parts including ad hocs from whole server.   You can comment out and use different order by clauses to change the results.  The wait seconds is a new column that shows how much of the total cpu seconds is taken by IO waits and the rest being actual processing of the statement.  The server the ad hocs are run on now attaches to each query correctly instead of displaying null.

select top 100
qt.text as [Full SQL],
SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1) as [SQL],
qd.name as [Database],
qs.execution_count as [Execution Count],
qs.total_logical_reads/131072 AS [Total Gigs Read],
qs.total_logical_reads/131072/qs.execution_count as [Gigs Read Per Execution],
qs.total_logical_writes/131072 [Total Gigs Written],
qs.total_logical_writes/131072/qs.execution_count [Gigs Written Per Execution],
qs.total_elapsed_time/1000000 as [Total CPU seconds],
qs.total_elapsed_time/1000000/qs.execution_count as [CPU Seconds Per Execution],
(qs.total_elapsed_time-qs.total_worker_time)/1000000 as [Wait Seconds],
qs.last_execution_time as [Last Executed],
qp.query_plan
from sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt  --Query text from here
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS db
LEFT JOIN sys.databases qd ON db.DatabaseID = qd.database_id  -- Database name from here
--Where qs.execution_count > 100  --Use to fine tune Per Execution searches for sql that runs often
--Where qt.text like '%dbo.caquoteautos%'
--Order by [Total Gigs Read] desc
--Order by [Gigs read per execution] desc
--Order by [Total Gigs Written] desc
--Order by [Gigs Written Per Execution] desc 
Order by [Total CPU seconds] desc
--Order by [CPU Seconds Per Execution] desc
--Order by [Wait Seconds] desc
