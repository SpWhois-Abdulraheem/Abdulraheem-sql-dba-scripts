use distribution
go
--Search by publication name and optionally down to the individaul subscriber.
SELECT ag.name
		, ag.publication
		, a.article
		, s.UndelivCmdsInDistDB
		, s.delivCmdsInDistDB
	FROM dbo.MSdistribution_status s 
	INNER JOIN dbo.msdistribution_agents ag ON ag.id = s.agent_id							
	INNER JOIN dbo.msarticles a ON a.publisher_id = ag.publisher_id AND a.article_id = s.article_id
	where ag.publication like '%PLServices_Trep%'
	and ag.name = 'GMC-PLSERVICES-PLServices-PLServices_TRep-WNPS01\NPSREFLECTIVE1-313'
ORDER BY   
		s.UndelivCmdsInDistDB DESC
		,ag.publication 