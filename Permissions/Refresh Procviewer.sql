/****************************************
		db_procviewer CURSOR
	
	This cursor grants VIEW DEFINITION 
	permissions on all user made stored 
	procedures in a database.

  YOU MUST HAVE OWNERSHIP PERMISSIONS
	  ON THE DB TO RUN THIS SCRIPT
*****************************************/

DECLARE @Proc nvarchar(255), @SQL nvarchar(255)

DECLARE Procs CURSOR FOR 
	SELECT	'[' + ROUTINE_SCHEMA + '].[' + ROUTINE_NAME + ']' as[name] 
	FROM	INFORMATION_SCHEMA.ROUTINES 
	--WHERE	ROUTINE_TYPE = 'PROCEDURE'
		WHERE ROUTINE_NAME NOT LIKE '%?%'

OPEN Procs

FETCH NEXT FROM Procs INTO @Proc
WHILE (@@FETCH_STATUS = 0)
BEGIN

	SET @SQL = N'GRANT VIEW DEFINITION ON ' + @Proc + ' TO db_procviewer'

	exec sp_executesql @SQL

	FETCH NEXT FROM Procs INTO @Proc
END

CLOSE Procs

DEALLOCATE Procs

GO

