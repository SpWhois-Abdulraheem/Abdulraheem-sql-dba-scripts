SELECT des.session_id as [Session],
OBJECT_NAME(dest.objectid, der.database_id) AS [Stored Proc],
DB_NAME(der.database_id) AS [Database] ,
des.login_name as [Login],
des.[HOST_NAME] as [Host] ,
SUBSTRING(dest.text, der.statement_start_offset / 2,
( CASE WHEN der.statement_end_offset = -1
THEN DATALENGTH(dest.text)
ELSE der.statement_end_offset
END - der.statement_start_offset ) / 2)
AS [Query] ,
der.percent_complete as [% done],
der.blocking_session_id as [Blocked by],
des.[program_name] ,
der.wait_time as [Wait time],
der.last_wait_type [Last Wait],
der.wait_resource as [Waiting on],
deqp.query_plan as [Plan]
FROM sys.dm_exec_sessions des
LEFT JOIN sys.dm_exec_requests der
ON des.session_id = der.session_id
LEFT JOIN sys.dm_exec_connections dec
ON des.session_id = dec.session_id
CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) dest
CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) deqp
WHERE des.session_id <> @@SPID
ORDER BY [Stored Proc], der.database_id
