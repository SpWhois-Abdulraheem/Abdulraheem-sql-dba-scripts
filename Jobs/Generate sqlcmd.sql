use master
go
exec sys.sp_MSforeachdb 'IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
Begin
Print ''sqlcmd -d ? -i \\clenas02\sqlbackups$\Scripts\getusers.sql -o \\clenas02\sqlbackups$\Test\?_Permissions.sql &&''
end'