 -- Get list of possibly unused SPs (SQL 2008 only)
    SELECT p.name AS 'Procedure'        -- Get list of all SPs in the current database
	into #unused
    FROM sys.procedures AS p	
    WHERE p.is_ms_shipped = 0
    EXCEPT
    SELECT p.name AS 'Procedure'        -- Get list of all SPs from the current database 
    FROM sys.procedures AS p          -- that are in the procedure cache
    INNER JOIN sys.dm_exec_procedure_stats AS qs
    ON p.object_id = qs.object_id
    WHERE p.is_ms_shipped = 0;


	--use DB_Utility
	--go

	--Create table [Procedure_Use]
	--([Procedure] nvarchar(250) null
	--,last_execution_time datetime null)

	    SELECT p.name AS 'Procedure'
		--, qs.last_execution_time        
	into #Used
    FROM sys.procedures AS p
    INNER JOIN sys.dm_exec_procedure_stats AS qs
    ON p.object_id = qs.object_id
    WHERE p.is_ms_shipped = 0

	select *, 1 'Used' from #Used
	union
	select *, 0 'Used' from #unused

	drop table #used
	drop table #unused