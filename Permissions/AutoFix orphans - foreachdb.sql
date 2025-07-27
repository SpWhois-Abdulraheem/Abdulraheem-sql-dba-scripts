--Modify USERNAME

EXECUTE sp_MSforeachdb 'USE [?]; EXEC sp_change_users_login Auto_Fix, USERNAME'