SET NOCOUNT ON;

DECLARE @user_name    SYSNAME
        , @login_name SYSNAME;

SELECT @user_name = 'dmainc\aschroeder',
       @login_name = 'dmainc\aschroeder'

SELECT '
    USE ' + QUOTENAME(NAME) + ';

    CREATE USER ' + QUOTENAME(@user_name)
       + ' FOR LOGIN ' + QUOTENAME(@login_name)
       + ' WITH DEFAULT_SCHEMA=[dbo];

    EXEC sys.sp_addrolemember
      ''db_datareader'',
      ''' + @user_name + ''';



'
FROM   sys.databases
WHERE  database_id > 4
       AND state_desc = 'ONLINE' 