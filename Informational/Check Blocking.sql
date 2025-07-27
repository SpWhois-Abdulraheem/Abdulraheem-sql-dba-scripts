SELECT Blocked.Session_ID AS Blocked_Session_ID
	,Blocked_SQL.TEXT AS Blocked_SQL
	,waits.wait_type AS Blocked_Resource
	,Blocking.Session_ID AS Blocking_Session_ID
	,Blocking_SQL.TEXT AS Blocking_SQL
	,GETDATE()
FROM sys.dm_exec_connections AS Blocking
INNER JOIN sys.dm_exec_requests AS Blocked ON Blocked.Blocking_Session_ID = Blocking.Session_ID
CROSS APPLY (
	SELECT *
	FROM sys.dm_exec_sql_text(Blocking.most_recent_sql_handle)
	) AS Blocking_SQL
CROSS APPLY (
	SELECT *
	FROM sys.dm_exec_sql_text(Blocked.sql_handle)
	) AS Blocked_SQL
INNER JOIN sys.dm_os_waiting_tasks AS waits ON waits.Session_ID = Blocked.Session_ID
