--This script determines how much CPU is used by each database on the server.  It includes a short period of time and all queries including ad hocs.  It also specifies how much is waits.

WITH DB_CPU_Stats 
AS 
(SELECT DatabaseID, DB_Name(DatabaseID) AS [DatabaseName], 
  SUM(total_elapsed_time)/1000000 AS [CPU_Time_S], (SUM(total_elapsed_time)-SUM(total_worker_time))/1000000 as [Wait_time] 
 FROM sys.dm_exec_query_stats AS qs 
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
              FROM sys.dm_exec_plan_attributes(qs.plan_handle) 
              WHERE attribute = N'dbid') AS db 
 GROUP BY DatabaseID) 
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_S] DESC) AS [row_num], 
       DatabaseName, [CPU_Time_S], [Wait_time], 
       CAST([CPU_Time_S] * 1.0 / SUM([CPU_Time_S]) 
       OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]           
FROM DB_CPU_Stats 
ORDER BY row_num; 

