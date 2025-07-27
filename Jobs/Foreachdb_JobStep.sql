




exec sp_MSforeachdb '
EXEC msdb.dbo.sp_add_jobstep @job_id=''33688A03-1F98-4035-9D94-3A2EBFAD0082'', @step_name=N''CheckDB: ?'', 
		 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=1, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''DBCC CheckDB
Go

'', 
		@database_name=N''?'', 
		@flags=0


EXEC msdb.dbo.sp_add_jobstep @job_id=''33688A03-1F98-4035-9D94-3A2EBFAD0082'', @step_name=N''Notification of CheckDB Failure: ?'', 
		
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=1, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''EXEC spDBA_job_notification $(ESCAPE_NONE(JOBID))'', 
		@database_name=N''master'', 
		@flags=0
'



exec sp_MSforeachdb '
EXEC msdb.dbo.sp_add_jobstep @job_id=''33688A03-1F98-4035-9D94-3A2EBFAD0082'', @step_name=N''Rebuild Index: ?'', 
		
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=143, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N'''', 
		@database_name=N''?'', 
		@flags=0

/****** Object:  Step [Notification of Index Rebuilding Failure: SRClaims]    Script Date: 4/11/2016 3:23:06 PM ******/
EXEC msdb.dbo.sp_add_jobstep @job_id=''33688A03-1F98-4035-9D94-3A2EBFAD0082'', @step_name=N''Notification of Index Rebuilding Failure: ?'', 
		
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''EXEC spDBA_job_notification $(ESCAPE_NONE(JOBID))'', 
		@database_name=N''master'', 
		@flags=0'