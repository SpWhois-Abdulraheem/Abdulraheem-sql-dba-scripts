use ReportServer
GO

SELECT [SubscriptionID]
      ,[OwnerID]
      ,[Report_OID]      
      ,[ModifiedDate]
      ,[Description]
      ,[LastStatus]      
      ,[LastRunTime]
      ,[Parameters]
      ,[DataSettings]
      ,[DeliveryExtension]
      ,[Version]
      ,[ReportZone]
  FROM [ReportServer].[dbo].[Subscriptions]
 where ownerID = '9A534CB6-8A6B-40EA-A072-F6E86DDCC2E2'
  order by Report_OID desc

  SELECT
jobs.name AS JobName,
C.path AS ReportPath,
C.name AS ReportName,
u.username AS SubscriptionOwner,
s.report_oid as ReportID,
s.subscriptionID as Subscription
FROM dbo.ReportSchedule RS
JOIN msdb.dbo.sysjobs jobs
ON CONVERT(varchar(36), RS.ScheduleID) = jobs.name
INNER JOIN dbo.Subscriptions S
ON RS.SubscriptionID = S.SubscriptionID
INNER JOIN dbo.Catalog C
ON s.report_oid = C.itemid
INNER JOIN dbo.users u
ON s.ownerid = u.userid
where s.ownerID = '9A534CB6-8A6B-40EA-A072-F6E86DDCC2E2'