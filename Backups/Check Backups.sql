use MSDB
go

SELECT
bs.[database_name]
,bs.[backup_start_date]
,bs.[type]
,bs.[server_name]
,bmf.physical_device_name

FROM [msdb].[dbo].[backupset] bs inner join [msdb].[dbo].[backupmediafamily] bmf
on bs.media_set_id = bmf.media_set_id
where
bs.[database_name] = 'Developers_Views'

/*
Backup type. Can be:
D = Database
I = Differential database
L = Log
F = File or filegroup
G =Differential file
P = Partial
Q = Differential partial
Can be NULL.
*/
and type = 'D'
order by backup_start_date desc

--2nd 

select @@servername as 'Instance',
SUBSTRING(s.name,1,40) AS 'Database'
, RecoveryModel= convert(sysname,DatabasePropertyEx(s.name,'Recovery'))
,CAST(b.backup_start_date AS char(11)) AS 'Backup Date '
,Status= convert(sysname,DatabasePropertyEx(s.name,'Status'))
, Updateability= convert(sysname,DatabasePropertyEx(s.name,'Updateability'))
, UserAccess= convert(sysname,DatabasePropertyEx(s.name,'UserAccess'))
--,  If_1_then_Published = DATABASEPROPERTYEX ( db_name(), 'IsPublished')
--,  If_1_then_MergePublished = DATABASEPROPERTYEX ( db_name(), 'IsMergePublished')
--,  If_1_then_SUSCRIBES = DATABASEPROPERTYEX ( db_name(), 'IsSubscribed')
 
,CASE WHEN b.backup_start_date > DATEADD(dd,-1,getdate())
THEN b.backup_start_date
WHEN b.backup_start_date > DATEADD(dd,-7,getdate())
THEN b.backup_start_date
ELSE b.backup_start_date
END
AS 'Backup Start Time'

from master..sysdatabases s
LEFT OUTER JOIN msdb..backupset b
ON s.name = b.database_name
AND b.backup_start_date = (SELECT MAX(backup_start_date)
FROM msdb..backupset
WHERE database_name = b.database_name
AND type = 'D') -- full database backups only, not log backups
WHERE s.name <> 'tempdb'

ORDER BY s.name