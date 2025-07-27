print 'USE msdb
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''Backup: Linked Servers, User DB Permissions, Jobs '', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N''No description available.'', 
		@category_name=N''[Uncategorized (Local)]'', 
		@owner_login_name=N''AMTRUSTSERVICES\sqljobs'', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Delete old'', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''PowerShell'', 
		@command=N''$LimitDay = 5
$TargetPath= "\\clenas02\sqlbackups$\DR_MIRROR_SCRIPTS\@@servername\Archive"
$limit = (Get-Date).AddDays(-$LimitDay)
get-childitem -Path $TargetPath -Recurse -Force |where {$_.psiscontainer -and $_.lastwritetime -le $limit}|foreach { remove-item $_.fullname -recurse}'', 
		@database_name=N''master'', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Archive'', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''DECLARE @TodaysDate NVARCHAR(25)
DECLARE @cmdstr NVARCHAR(500)
SELECT @TodaysDate = Convert(NVARCHAR(10),GETDATE(),112) -- This code will set @TodaysDate with today date.  Format of yyyymmdd.
SET @cmdstr=''''robocopy \\clenas02\sqlbackups$\DR_MIRROR_SCRIPTS\@@servername \\clenas02\sqlbackups$\DR_MIRROR_SCRIPTS\@@servername\Archive\'''' +@TodaysDate+''''  *.sql /mov''''
EXEC master..xp_cmdshell @cmdstr'', 
		@database_name=N''master'', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Script: Linked Servers and Jobs'', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''PowerShell'', 
		@command=N''$directoryname = "\\clenas02\sqlbackups$\DR_MIRROR_SCRIPTS\@@servername\" 
$sqlserver = "@@servername"

function get-linkscripts {
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $sqlserver
$srv.LinkedServers | foreach {$_.Script()+ "GO"} | Out-File "$directoryname linkedservers.sql"}


function get-jobscripts {
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $sqlserver
$srv.JobServer.Jobs | foreach {$_.Script()+ "GO"} | Out-File "$directoryname jobs.sql"}

get-jobscripts
get-linkscripts'', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

use master
go
exec sys.sp_MSforeachdb 'IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
Begin
print ''EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=''''Get Permissions: ?'''', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''''CmdExec'''', 
		@command=N''''sqlcmd -d ? -i \\clenas02\sqlbackups$\Scripts\getusers.sql -o \\clenas02\sqlbackups$\DR_MIRROR_SCRIPTS\@@servername\?_Permissions.sql'''', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback''
end'

print'
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
go
'