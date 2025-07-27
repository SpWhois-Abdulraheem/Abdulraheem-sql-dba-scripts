SELECT o.name, 
       ps.last_execution_time 
FROM   sys.dm_exec_procedure_stats ps 
INNER JOIN 
       sys.objects o 
       ON ps.object_id = o.object_id 
WHERE  DB_NAME(ps.database_id) = 'production' 
ORDER  BY 
       ps.last_execution_time DESC  


	   SELECT d.object_id, d.database_id, DB_NAME(database_id) AS 'database_name',   
    OBJECT_NAME(object_id, database_id) AS 'trigger_name', d.cached_time,  
    d.last_execution_time, d.total_elapsed_time,   
    d.total_elapsed_time/d.execution_count AS [avg_elapsed_time],   
    d.last_elapsed_time, d.execution_count  
FROM sys.dm_exec_trigger_stats AS d  
WHERE DB_NAME(database_id) = 'production' 
ORDER BY OBJECT_NAME(object_id, database_id)