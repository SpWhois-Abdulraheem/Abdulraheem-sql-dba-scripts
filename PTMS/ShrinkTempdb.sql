use tempdb 
go
dbcc freeproccache

checkpoint
go

dbcc shrinkfile('tempdev', 6000)
dbcc shrinkfile('tempdev2', 6000)
dbcc shrinkfile('tempdev3', 6000)
dbcc shrinkfile('tempdev4', 6000)
dbcc shrinkfile('tempdev5', 6000)
dbcc shrinkfile('tempdev6', 6000)
dbcc shrinkfile('tempdev7', 6000)
dbcc shrinkfile('tempdev8', 6000)
