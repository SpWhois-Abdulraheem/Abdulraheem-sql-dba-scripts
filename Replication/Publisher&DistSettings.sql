
--Get Publication Settings
use distribution
go

SELECT 
	immediate_sync,
	allow_anonymous,
	CASE publication_type WHEN 0 THEN 'Transactional'
	WHEN 1 THEN 'Snapshot'
	WHEN 2 THEN 'Merge' END,
	* 
FROM MSpublications

 
 --get ID's
use distribution
go
select * from MSpublisher_databases



--Get Dist. retention settings etc
use master
GO
EXEC sp_helpdistributor;
EXEC sp_helpdistributiondb;