SELECT    b.name AS JobName
            --, e.name
            , e.path
            , d.description
            --, a.SubscriptionID
            , laststatus
            , eventtype
            , LastRunTime
            , date_created
            , date_modified
FROM  ReportServer.dbo.ReportSchedule   a
JOIN  msdb.dbo.sysjobs b 
      ON cast(a.ScheduleID as varchar(255)) = b.name
JOIN  ReportServer.dbo.ReportSchedule c
      ON b.name = CAST(c.ScheduleID AS VARCHAR(255))
JOIN             
      (select eventtype,laststatus,LastRunTime,d.SubscriptionID,d.description, cast(d.report_oid as varchar(255)) report_oid from    ReportServer.dbo.Subscriptions d  ) d 
       on c.SubscriptionID = d.SubscriptionID
JOIN
      (select e.name, e.path, cast(e.itemid as varchar(255)) itemid from    ReportServer.dbo.Catalog e   ) e 
      on itemid = report_oid
	  --where b.name = 'F92C6DA1-0AFA-4696-A45B-8ACADAB606D1'
	  order by d.LastRunTime desc