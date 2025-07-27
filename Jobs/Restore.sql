USE [msdb]
GO

/****** Object:  Job [Restore - OnDemand: ETG from 11/17 Production Nightly Backup]    Script Date: 11/18/2015 2:02:46 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/18/2015 2:02:46 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Restore - OnDemand: xxxxxxxxxxxx from Production Nightly Backup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job kills connections, restores the nightly backup of AMT-EOM.ETG (from CLE-D2D01) to DEV-EOM\STAGING.ETG, changes recovery model to simple, shrinks files, and fixes user rights.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'AMTRUSTSERVICES\sqljobs', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Notification Database Restore Started]    Script Date: 11/18/2015 2:02:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Notification Database Restore Started', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE msdb.dbo.sp_send_dbmail
@profile_name = ''SQLMailProfile'',
@recipients = ''DatabaseSupport@amtrustgroup.com; QATech@amtrustgroup.com'',
       @subject    = ''Database restore of DEV-EOM\STAGING.ETG is underway...'',
       @body       = ''Database restore of DEV-EOM\STAGING.ETG from AMT-EOM.ETG is underway.   An email will be sent out when the restore is complete.''
', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill connections: ETG]    Script Date: 11/18/2015 2:02:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill connections: ETG', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
--RUN THIS TO KILL ALL CONNECTIONS (EVEN FROM MASTER)
DECLARE @ID int, @SQL nvarchar(50)

DECLARE Processes CURSOR FOR
	SELECT Request_session_id
	FROM sys.dm_tran_locks
	WHERE resource_database_id = DB_ID(''ETG'')
	AND resource_type = ''DATABASE''
	AND	request_session_id <> @@SPID
	--AND LOGINAME <> ''sa''

OPEN Processes

FETCH NEXT FROM Processes INTO @ID

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SET @SQL = ''KILL '' + Cast(@ID as nvarchar(10))
	EXEC sp_executesql @SQL

	FETCH NEXT FROM Processes INTO @ID
END

CLOSE Processes

DEALLOCATE Processes

GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore from Disk: ETG]    Script Date: 11/18/2015 2:02:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore from Disk: ETG', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'RESTORE DATABASE [ETG]
FROM DISK = N''\\cle-d2d01\SQL\Prod\Amt-Eom\ETG\Archive\ETG_20151118.bak''
WITH FILE = 1
	,MOVE N''ETG'' TO N''D:\STAGING\dev_dbeom01_staging_db\Data\ETG.mdf''
	,MOVE N''ETG_log'' TO N''D:\STAGING\dev_dbeom01_staging_log\Log\ETG_log.ldf''
	,NOUNLOAD
	,REPLACE
	,STATS = 5
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set Recovery Model to Simple]    Script Date: 11/18/2015 2:02:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set Recovery Model to Simple', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER DATABASE ETG SET RECOVERY SIMPLE;
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Shrink files: ETG]    Script Date: 11/18/2015 2:02:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Shrink files: ETG', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DBCC SHRINKFILE(ETG_log,0) WITH NO_INFOMSGS
GO', 
		@database_name=N'ETG', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Grant db_owner Permissions]    Script Date: 11/18/2015 2:02:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Grant db_owner Permissions', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
--devwebapp
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = N''AMTRUSTSERVICES\devwebapp'')
	CREATE USER [AMTRUSTSERVICES\devwebapp] FOR LOGIN [AMTRUSTSERVICES\devwebapp]

EXEC sp_addrolemember db_owner, [AMTRUSTSERVICES\devwebapp]
GO

', 
		@database_name=N'ETG', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Auto_Fix Orphans: ETG]    Script Date: 11/18/2015 2:02:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Auto_Fix Orphans: ETG', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec sp_change_users_login ''auto_fix'', ''ANAUser''
exec sp_change_users_login ''auto_fix'', ''LinkedServerReader''', 
		@database_name=N'ETG', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Notification Database Restore Complete]    Script Date: 11/18/2015 2:02:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Notification Database Restore Complete', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE msdb.dbo.sp_send_dbmail
@profile_name = ''SQLMailProfile'',
@recipients = ''DatabaseSupport@amtrustgroup.com; QATech@amtrustgroup.com'',
       @subject    = ''Database restore of DEV-EOM\STAGING.ETG is complete...'',
       @body       = ''The database restore of DEV-EOM\STAGING.ETG is complete.''
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'onetime etg', 
		@enabled=1, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20151118, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'1ba886ce-4497-4fe0-bb6f-f422fb4fcabb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO