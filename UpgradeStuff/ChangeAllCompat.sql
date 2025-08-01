DECLARE @SQL VARCHAR(max)  = ''
,             @CompLevel int = 140

SELECT @SQL += 'ALTER DATABASE ' + quotename(NAME) + ' SET COMPATIBILITY_LEVEL = ' + cast(@CompLevel as char (3)) + ';' + CHAR(10) + CHAR(13)
FROM sys.databases
WHERE COMPATIBILITY_LEVEL <> @CompLevel

PRINT @SQL
--EXEC (@SQL)