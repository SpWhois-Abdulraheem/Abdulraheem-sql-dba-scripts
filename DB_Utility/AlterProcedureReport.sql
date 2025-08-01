

SELECT	EventType,
		AlertTime,
		AlterObjectData.value('(/EVENT_INSTANCE/SPID)[1]', 'int') AS 'SPID',
		AlterObjectData.value('(/EVENT_INSTANCE/ServerName)[1]', 'varchar(100)') AS 'ServerName',
		AlterObjectData.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(100)') AS 'LoginName',
		AlterObjectData.value('(/EVENT_INSTANCE/UserName)[1]', 'varchar(100)') AS 'UserName',
		AlterObjectData.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(100)') AS 'DatabaseName',
		AlterObjectData.value('(/EVENT_INSTANCE/SchemaName)[1]', 'varchar(100)') AS 'SchemaName',
		AlterObjectData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(100)') AS 'ObjectName',
		AlterObjectData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(100)') AS 'ObjectType',
		AlterObjectData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'varchar(8000)') AS 'CommandText'
FROM DB_Utility.dbo.AlterObjectEventLog WITH(NOLOCK)
WHERE AlertTime >= '2016-02-12 08:00:00.000'
AND AlertTime <= '2016-02-12 12:00:00.000'


