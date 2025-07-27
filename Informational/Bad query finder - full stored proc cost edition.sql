select top 50 qt.TEXT as [Query],
qd.name as [Database],
qs.execution_count as [Execution Count],
qs.total_logical_reads/131072 AS [Total Gigs Read],
qs.total_logical_reads/131072/qs.execution_count as [Gigs Read Per Execution],
qs.total_logical_writes/131072 [Total Gigs Written],
qs.total_logical_writes/131072/qs.execution_count [Gigs Written Per Execution],
qs.total_elapsed_time/1000000 as [Total CPU seconds],
qs.total_elapsed_time/1000000/qs.execution_count as [CPU Seconds Per Execution],
qs.last_execution_time as [Last Executed],
--(qs.total_logical_reads*8192) / (qs.total_elapsed_time / 1000) as [Bytes Read Per microsecond], --Comment out unless sort Bytes Read Per
qp.query_plan
from sys.dm_exec_procedure_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp  --XML plan from here
LEFT JOIN sys.databases qd ON qt.dbid = qd.database_id  -- Database name from here NULL means adhoc or prepared or linked server
--Where qs.total_elapsed_time > 0 and qs.total_logical_reads/131072 > 500 --Comment out unless sort Bytes Read Per 
--Where qs.execution_count > 100  --Use to fine tune Per Execution searches for sql that runs often
--Where qd.name = 'GrandCentral' --drill down to specific database
Order by [Total Gigs Read] desc
--Order by [Gigs read per execution] desc
--Order by [Total Gigs Written] desc
--Order by [Gigs Written Per Execution] desc 
--Order by [Total CPU seconds] desc
--Order by [CPU Seconds Per Execution] desc
--Order by [Bytes Read Per microsecond]
