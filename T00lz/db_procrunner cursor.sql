/***********************************
		db_procrunner CURSOR
	
	This cursor grants EXECUTE 
	permissions on all user made
	stored procedures in CPPLIVE

YOU MUST HAVE OWNERSHIP PERMISSIONS
	ON THE DB TO RUN THIS SCRIPT
************************************/

USE PLStage
GO

DECLARE @Proc nvarchar(255), @SQL nvarchar(255), @Func nvarchar(255)

DECLARE Procs CURSOR FOR 
	SELECT	[name] 
	FROM	sys.Procedures 
	WHERE	is_ms_shipped = 0

OPEN Procs

FETCH NEXT FROM Procs INTO @Proc
WHILE (@@FETCH_STATUS = 0)
BEGIN

	SET @SQL = N'GRANT EXECUTE ON ' + @Proc + ' TO db_procrunner'

	exec sp_executesql @SQL

	FETCH NEXT FROM Procs INTO @Proc
END

CLOSE Procs

DEALLOCATE Procs

GO

DECLARE @SQL nvarchar(255), @Func nvarchar(255)

DECLARE Funcs CURSOR FOR 
	SELECT	[name] 
	FROM	sys.objects
	WHERE	is_ms_shipped = 0
	AND TYPE in ('FN', 'IF')

OPEN Funcs

FETCH NEXT FROM Funcs INTO @Func
WHILE (@@FETCH_STATUS = 0)
BEGIN

	SET @SQL = N'GRANT EXECUTE ON ' + @Func + ' TO db_procrunner'

	exec sp_executesql @SQL

	FETCH NEXT FROM Funcs INTO @Func
END

CLOSE Funcs

DEALLOCATE Funcs

GO
