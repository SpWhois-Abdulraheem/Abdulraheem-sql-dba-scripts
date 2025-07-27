select step_id, step_name, on_success_action, on_success_step_id from msdb.dbo.sysjobsteps
where job_id = '33688A03-1F98-4035-9D94-3A2EBFAD0082'

--USE BELOW TO FIX JOB STEP ACTIONS THE LAZY WAY
declare @step int
declare @goto int

set @step = 59
SET @GOTO = 61
while @step < 195 
begin
exec msdb.dbo.sp_update_jobstep 
	@job_id = '33688A03-1F98-4035-9D94-3A2EBFAD0082'
	,@step_id= @step
	,@on_success_action= 4
	,@on_success_step_id= @GOTO;
SET @STEP = @STEP+2
SET @GOTO = @STEP+2
end