select j.job_id, j.name
       from msdb.dbo.sysjobs j
       WHERE j.Name NOT IN (SELECT     CONVERT(nvarchar(128), Schedule.ScheduleID)
                                         FROM         ReportServer.dbo.ReportSchedule INNER JOIN
                                         ReportServer.dbo.Schedule ON ReportSchedule.ScheduleID = Schedule.ScheduleID INNER JOIN
                                           ReportServer.dbo.Subscriptions ON ReportSchedule.SubscriptionID = Subscriptions.SubscriptionID INNER JOIN
                                           ReportServer.dbo.[Catalog] ON ReportSchedule.ReportID = [Catalog].ItemID AND Subscriptions.Report_OID = [Catalog].ItemID)
       AND j.[description] LIKE 'This job is owned by a report server process.%'