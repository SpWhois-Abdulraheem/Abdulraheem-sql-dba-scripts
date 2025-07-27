USE DL
Go
exec sys.sp_helpsubscription

exec sys.sp_helppublication

--exec sp_changepublication @publication='DL_Trep', @property='immediate_sync',@value='FALSE'