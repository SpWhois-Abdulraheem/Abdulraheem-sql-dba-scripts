--Tells which portion of sql server is using the most memory

SELECT * FROM sys.dm_os_memory_clerks ORDER BY (single_pages_kb + multi_pages_kb + awe_allocated_kb) desc

Tells what type of plans are being used, how much memory it is taking up and if they are only used a single time

SELECT objtype AS [CacheType]
        , count_big(*) AS [Total Plans]
        , sum(cast(size_in_bytes as decimal(12,2)))/1024/1024 AS [Total MBs]
        , avg(usecounts) AS [Avg Use Count]
        , sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(12,2)))/1024/1024 AS [Total MBs - USE Count 1]
        , sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs - USE Count 1] DESC
Tells the top X number of plans by space used up and shows the query taking that plan and specifies adhoc but you can remove that line to see all plans

SELECT TOP(10) * FROM sys.dm_Exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
AND objtype = 'Adhoc' AND usecounts = 1
AND size_in_bytes < 5242880 ORDER BY size_in_bytes DESC 

SELECT * FROM sys.dm_os_memory_clerks ORDER BY (single_pages_kb + multi_pages_kb + awe_allocated_kb) desc
