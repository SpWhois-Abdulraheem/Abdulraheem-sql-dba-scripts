---------------------------------------------------------------------------
/*  This will show last restore date of a server & its databases */
---------------------------------------------------------------------------


WITH LastRestores AS
(
SELECT
    DatabaseName = [d].[name] ,
    r.restore_date,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
)
SELECT *
FROM [LastRestores]
WHERE [RowNum] = 1
and DatabaseName not in ('master', 'model', 'msdb', 'tempdb')

