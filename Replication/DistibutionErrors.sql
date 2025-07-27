USE distribution
GO

SELECT 
	MSre.time,
	publisher.name, 
	MSda.publication, 
	MSda.publisher_db, 
	subscriber.name, 
	MSda.subscriber_db,
	MSre.error_code,
	MSre.error_text
FROM MSdistribution_history MSdh
INNER JOIN MSdistribution_agents MSda ON MSdh.agent_id = MSda.id
INNER JOIN MSrepl_errors MSre ON MSdh.error_id = MSre.id
INNER JOIN master.sys.servers publisher ON MSda.publisher_id = publisher.server_id
INNER JOIN master.sys.servers subscriber ON MSda.subscriber_id = subscriber.server_id
WHERE MSdh.error_id <> 0 
ORDER BY time desc