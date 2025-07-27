

--Blocked Process Report
SELECT	[BlockingEventData].value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime') AS 'BlockingEventTime',
		CAST([BlockingEventData].value('(/EVENT_INSTANCE/Duration)[1]', 'bigint') / 1000000.0 AS [decimal](16, 2)) AS 'BlockingDurationInSeconds',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@waitresource)[1]', 'varchar(64)') AS 'BlockedWaitResource',
		DB_NAME([BlockingEventData].value('(/EVENT_INSTANCE/DatabaseID)[1]', 'int')) AS 'BlockedWaitResourceDatabase',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@spid)[1]', 'int') AS 'BlockedProcessSPID',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@loginname)[1]', 'varchar(64)') AS 'BlockedProcessOwnerLoginName',
		UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@status)[1]', 'varchar(32)')) AS 'BlockedProcessStatus',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@lockMode)[1]', 'varchar(64)') AS 'BlockedProcessLockMode',
		UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@transactionname)[1]', 'varchar(64)')) AS 'BlockedProcessCommandType',

		CASE 
			WHEN SUBSTRING([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)'), 2, 4) = 'Proc' 
			THEN 'Stored Procedure: ' + OBJECT_NAME(
				CONVERT(INTEGER, LTRIM(RTRIM(SUBSTRING([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)'), 
				PATINDEX('%Object Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) + 12, 
				PATINDEX('%]%',[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) - (PATINDEX('%Object Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) + 12))))),
				CONVERT(INTEGER, LTRIM(RTRIM(SUBSTRING([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)'), 
				PATINDEX('%Database Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) + 14, 
				PATINDEX('%Object%',[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) - (PATINDEX('%Database Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) + 14)))))) +
				' On ' + DB_NAME(CONVERT(INTEGER, LTRIM(RTRIM(SUBSTRING([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)'), 
								PATINDEX('%Database Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) + 14, 
								PATINDEX('%Object%',[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) - (PATINDEX('%Database Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')) + 14))))))
			ELSE [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)')
		END AS 'BlockedProcessTSQL',

		UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@isolationlevel)[1]', 'varchar(64)')) AS 'BlockedProcessTransactionIsolationLevel',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@clientapp)[1]', 'varchar(128)') AS 'BlockedProcessClientApplication',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@hostname)[1]', 'varchar(64)') AS 'BlockedProcessHostName',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@spid)[1]', 'int') AS 'BlockingProcessSPID',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@loginname)[1]', 'varchar(64)') AS 'BlockingProcessOwnerLoginName',
		UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@status)[1]', 'varchar(32)')) AS 'BlockingProcessStatus',

		CASE 
			WHEN SUBSTRING([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)'), 2, 4) = 'Proc' 
			THEN 'Stored Procedure: ' + OBJECT_NAME(
				CONVERT(INTEGER, LTRIM(RTRIM(SUBSTRING([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)'), 
				PATINDEX('%Object Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) + 12, 
				PATINDEX('%]%',[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) - (PATINDEX('%Object Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) + 12))))),
				CONVERT(INTEGER, LTRIM(RTRIM(SUBSTRING([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)'), 
				PATINDEX('%Database Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) + 14, 
				PATINDEX('%Object%',[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) - (PATINDEX('%Database Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) + 14)))))) +
				' On ' + DB_NAME(CONVERT(INTEGER, LTRIM(RTRIM(SUBSTRING([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)'), 
								PATINDEX('%Database Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) + 14, 
								PATINDEX('%Object%',[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) - (PATINDEX('%Database Id = %', [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')) + 14))))))
			ELSE [BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(max)')
		END AS 'BlockingProcessTSQL',

		UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@isolationlevel)[1]', 'varchar(64)')) AS 'BlockingProcessTransactionIsolationLevel',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@clientapp)[1]', 'varchar(128)') AS 'BlockingProcessClientApplication',
		[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@hostname)[1]', 'varchar(64)') AS 'BlockingProcessHostName'
FROM DB_Utility.dbo.BlockedProcessEventLog WITH(NOLOCK)
WHERE AlertTime >= '2016-02-18 09:00:00.000'
--AND AlertTime <= '2016-02-12 09:00:00.000'
ORDER BY AlertTime


