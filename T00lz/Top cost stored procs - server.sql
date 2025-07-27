--This script shows the top cost stored procedures from whole server.  You can place a specific name of a stored proc into the Object Name.  You can comment out and use different order by clauses to change the results.  The wait seconds is a new column that shows how much of the total cpu seconds is taken by IO waits and the rest being actual processing of the statement.

select top 50 qt.TEXT as [SQL],
OBJECT_NAME(qs.object_id, qs.database_id) as [Procedure Name],
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
FROM sys.dm_exec_procedure_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp  --XML plan from here
LEFT JOIN sys.databases qd ON qt.dbid = qd.database_id  -- Database name from here NULL means adhoc or prepared or linked server
--Where qs.execution_count > 100  --Use to fine tune Per Execution searches for sql that runs often
WHERE OBJECT_NAME(qs.object_id, qs.database_id) = 'AgentApplicationTransLog_GetTransactions_WithDateFilter'
--WHERE qs.object_id = 710746692 and qs.database_id = 32767
--Order by [Total Gigs Read] desc
--Order by [Gigs read per execution] desc
--Order by [Total Gigs Written] desc
--Order by [Gigs Written Per Execution] desc 
Order by [Total CPU seconds] desc
--Order by [CPU Seconds Per Execution] desc
--Order by [Wait Seconds] desc


