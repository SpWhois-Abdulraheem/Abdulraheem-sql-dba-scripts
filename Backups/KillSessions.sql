DECLARE @ID int, @SQL nvarchar(50)

DECLARE Processes CURSOR FOR
	SELECT Request_session_id
	FROM sys.dm_tran_locks
	WHERE resource_database_id = DB_ID('gltaxrecon_daily_demo')
	AND resource_type = 'DATABASE'
	AND	request_session_id <> @@SPID
	--AND LOGINAME <> ''sa''

OPEN Processes

FETCH NEXT FROM Processes INTO @ID

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SET @SQL = 'KILL ' + Cast(@ID as nvarchar(10))
	EXEC sp_executesql @SQL

	FETCH NEXT FROM Processes INTO @ID
END

CLOSE Processes

DEALLOCATE Processes

GO