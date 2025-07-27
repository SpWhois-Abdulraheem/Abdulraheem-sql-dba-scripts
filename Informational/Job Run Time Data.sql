/*  Get the average run times of jobs */

/*  How many days do you want to include in your run-time average?
    Recent values tend to be more useful, set the value of @daysToAverage*/
SET NOCOUNT ON    
Declare @daysToAverage smallint = 20;

--create @RunTime table to hold data
 
Declare @RunTimeTable Table
(		
     job_id      uniqueidentifier
	, step_id int
	, step_name varchar(200)
    , maxRunTime  int
    , avgRunTime  int
    , minRunTime  int
);
 
--Create @weekDay table to hold days 
/* Parse the schedule into something we can understand */
Declare @weekDay Table (
      mask       int
    , maskValue  varchar(32)
);
 
Insert Into @weekDay
Select 1, 'Sunday'  Union All
Select 2, 'Monday'  Union All
Select 4, 'Tuesday'  Union All
Select 8, 'Wednesday'  Union All
Select 16, 'Thursday'  Union All
Select 32, 'Friday'  Union All
Select 64, 'Saturday';



 
/* First, let's get our run-time average */
Insert Into @RunTimeTable
Select job_id
	,step_id
	,step_name
    , MAX((run_duration/10000) * 3600 + (run_duration/100%100)*60 + run_duration%100) As 'avgRunTime' /* convert HHMMSS to seconds */
    , AVG((run_duration/10000) * 3600 + (run_duration/100%100)*60 + run_duration%100) As 'avgRunTime' /* convert HHMMSS to seconds */
    , MIN((run_duration/10000) * 3600 + (run_duration/100%100)*60 + run_duration%100) As 'avgRunTime' /* convert HHMMSS to seconds */
From msdb.dbo.sysjobhistory
Where --step_id = 0 -- only grab our total run-time
    run_status = 1 -- only grab successful executions
    And msdb.dbo.agent_datetime(run_date, run_time) >= DateAdd(day, -@daysToAverage, GetDate())
Group By job_id, step_id, step_name;

 
/* Now let's get our schedule information */
With myCTE
As(
    Select sched.name As 'scheduleName'
        , sched.schedule_id
        , jobsched.job_id
        , Case When sched.freq_type = 1 Then 'Once' 
            When sched.freq_type = 4 
                And sched.freq_interval = 1 
                    Then 'Daily'
            When sched.freq_type = 4 
                Then 'Every ' + Cast(sched.freq_interval As varchar(5)) + ' days'
            When sched.freq_type = 8 Then 
                Replace( Replace( Replace(( 
                    Select maskValue 
                    From @weekDay As x 
                    Where sched.freq_interval & x.mask <> 0 
                    Order By mask For XML Raw)
                , '"/><row maskValue="', '; '), '<row maskValue="', ''), '"/>', '') 
                + Case When sched.freq_recurrence_factor <> 0 
                        And sched.freq_recurrence_factor = 1 
                            Then '; weekly' 
                    When sched.freq_recurrence_factor <> 0 Then '; every ' 
                + Cast(sched.freq_recurrence_factor As varchar(10)) + ' weeks' End
            When sched.freq_type = 16 Then 'On day ' 
                + Cast(sched.freq_interval As varchar(10)) + ' of every '
                + Cast(sched.freq_recurrence_factor As varchar(10)) + ' months' 
            When sched.freq_type = 32 Then 
                Case When sched.freq_relative_interval = 1 Then 'First'
                    When sched.freq_relative_interval = 2 Then 'Second'
                    When sched.freq_relative_interval = 4 Then 'Third'
                    When sched.freq_relative_interval = 8 Then 'Fourth'
                    When sched.freq_relative_interval = 16 Then 'Last'
                End + 
                Case When sched.freq_interval = 1 Then ' Sunday'
                    When sched.freq_interval = 2 Then ' Monday'
                    When sched.freq_interval = 3 Then ' Tuesday'
                    When sched.freq_interval = 4 Then ' Wednesday'
                    When sched.freq_interval = 5 Then ' Thursday'
                    When sched.freq_interval = 6 Then ' Friday'
                    When sched.freq_interval = 7 Then ' Saturday'
                    When sched.freq_interval = 8 Then ' Day'
                    When sched.freq_interval = 9 Then ' Weekday'
                    When sched.freq_interval = 10 Then ' Weekend'
                End
                + Case When sched.freq_recurrence_factor <> 0 
                        And sched.freq_recurrence_factor = 1 Then '; monthly'
                    When sched.freq_recurrence_factor <> 0 Then '; every ' 
                + Cast(sched.freq_recurrence_factor As varchar(10)) + ' months' End
            When sched.freq_type = 64 Then 'StartUp'
            When sched.freq_type = 128 Then 'Idle'
          End As 'frequency'
        , IsNull('Every ' + Cast(sched.freq_subday_interval As varchar(10)) + 
            Case When sched.freq_subday_type = 2 Then ' seconds'
                When sched.freq_subday_type = 4 Then ' minutes'
                When sched.freq_subday_type = 8 Then ' hours'
            End, 'Once') As 'subFrequency'
        , Replicate('0', 6 - Len(sched.active_start_time)) 
            + Cast(sched.active_start_time As varchar(6)) As 'startTime'
        , Replicate('0', 6 - Len(sched.active_end_time)) 
            + Cast(sched.active_end_time As varchar(6)) As 'endTime'
        , Replicate('0', 6 - Len(jobsched.next_run_time)) 
            + Cast(jobsched.next_run_time As varchar(6)) As 'nextRunTime'
        , Cast(jobsched.next_run_date As char(8)) As 'nextRunDate'
    From msdb.dbo.sysschedules As sched
    Join msdb.dbo.sysjobschedules As jobsched
        On sched.schedule_id = jobsched.schedule_id
    Where sched.enabled = 1
)
 
/* Finally, let's look at our actual jobs and tie it all together */
Select Convert(varchar(30),SERVERPROPERTY('ServerName')) AS ServerName
	,replace(job.name,',',';') As 'jobName'
	,rtt.step_id
	,rtt.step_name
    , sched.scheduleName
    , sched.frequency
    , sched.subFrequency
    , SubString(sched.startTime, 1, 2) + ':' 
        + SubString(sched.startTime, 3, 2) --+ ' - ' 
        --+ SubString(sched.endTime, 1, 2) + ':' 
       --+ SubString(sched.endTime, 3, 2) 
       As 'scheduleTime' -- HH:MM 
    , RIGHT('0' + CONVERT(varchar(6), rtt.maxRunTime/86400),2)+ ':' + RIGHT('0' + CONVERT(varchar(6), rtt.maxRunTime % 86400 / 3600), 2)+ ':' + RIGHT('0' + CONVERT(varchar(2), (rtt.maxRunTime % 3600) / 60), 2)+ ':' + RIGHT('0' + CONVERT(varchar(2), rtt.maxRunTime % 60), 2)
    As 'MaxRunTime' --convert MAX to DD:HH:MM:SS
    , RIGHT('0' + CONVERT(varchar(6), rtt.avgRunTime/86400),2)+ ':' + RIGHT('0' + CONVERT(varchar(6), rtt.avgRunTime % 86400 / 3600), 2)+ ':' + RIGHT('0' + CONVERT(varchar(2), (rtt.avgRunTime % 3600) / 60), 2)+ ':' + RIGHT('0' + CONVERT(varchar(2), rtt.avgRunTime % 60), 2)
    As 'AvgRunTime' --convert AVG to DD:HH:MM:SS
    , RIGHT('0' + CONVERT(varchar(6), rtt.minRunTime/86400),2)+ ':' + RIGHT('0' + CONVERT(varchar(6), rtt.minRunTime % 86400 / 3600), 2)+ ':' + RIGHT('0' + CONVERT(varchar(2), (rtt.minRunTime % 3600) / 60), 2)+ ':' + RIGHT('0' + CONVERT(varchar(2), rtt.minRunTime % 60), 2)
    As 'MinRunTime' --convert MIN to DD:HH:MM:SS
From msdb.dbo.sysjobs As job
Join myCTE As sched
    On job.job_id = sched.job_id
Left Join @RunTimeTable As rtt
    On job.job_id = rtt.job_id
Where job.enabled = 1 -- do not display disabled jobs
Order By nextRunDate;