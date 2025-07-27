use distribution
go

select * from dbo.msdistribution_agents --where publisher_database_id = 35

/*############################
Step 1 ^^^
Step 2 vvv
################################*/
use distribution
go

SELECT distinct 
		ag.name
		, a.article
		, s.UndelivCmdsInDistDB
		, s.delivCmdsInDistDB
	FROM dbo.MSdistribution_status s 
	INNER JOIN dbo.msdistribution_agents ag ON ag.id = s.agent_id							
	INNER JOIN dbo.msarticles a ON a.publisher_id = ag.publisher_id AND a.article_id = s.article_id and a.publisher_db = ag.publisher_db
	where ag.publisher_database_id = 1 and ag.subscriber_id > 0 -- virtual subscribers are < 0
	--and a.article = 'QuoteCoverageFactorsHash'
ORDER BY   
		s.UndelivCmdsInDistDB DESC

/*###########################
Other stuff
###############################*/


select * from dbo.msarticles

SELECT 
	immediate_sync,
	allow_anonymous,
	CASE publication_type WHEN 0 THEN 'Transactional'
	WHEN 1 THEN 'Snapshot'
	WHEN 2 THEN 'Merge' END,
	* 
FROM MSpublications