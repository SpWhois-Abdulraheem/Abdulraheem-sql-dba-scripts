SELECT DISTINCT job_name = NAME
    ,db_run = rs.db
    ,run_duration = CONVERT(CHAR(20), DATEADD(second, rd, 0), 108)
    ,run_datetime = CONVERT (CHAR (50),  rundatetime, 108)
FROM (
    SELECT j.NAME
        ,rd = DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR (20), run_duration), 6), 5, 0, ':'), 3, 0, ':'))
        ,rundatetime = STUFF (STUFF (CONVERT(VARCHAR (20), h.run_date), 5, 0, '-'), 8, 0, '-') + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR (20), run_time), 6), 5, 0, ':'), 3, 0, ':')
        ,db = s.database_name
    FROM msdb.dbo.sysjobhistory h
    INNER JOIN msdb.dbo.sysjobs AS j ON h.job_id = j.job_id
    INNER JOIN msdb.dbo.sysjobsteps AS s ON s.job_id = j.job_id
    WHERE h.step_id = 0
    and run_duration >= -1   
    GROUP BY j.NAME,s.database_name, s.step_name, run_duration, run_date, run_time
    )
    AS rs
    WHERE CONVERT (CHAR (50),  rundatetime, 108) > DATEADD (HOUR, -168, GETDATE())
    AND rs.db IS NOT NULL
	and name like 'Backup%'
	--and name = ''
	and db = 'Premdat'
ORDER BY db_run desc