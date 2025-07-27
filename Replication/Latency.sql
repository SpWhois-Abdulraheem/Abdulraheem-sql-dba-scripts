USE distribution
GO
SET NOCOUNT ON
GO
/*Set the latency threshold in minutes*/
DECLARE @THRESHOLD AS INT = 1
DECLARE @tableHTML NVARCHAR(MAX)

DECLARE @temp TABLE(
			subscriber varchar(100) NULL             
            ,latency  int NULL )

DECLARE @temptbl TABLE(
Name varchar(100) NOT NULL,
Article varchar(100) NOT NULL,
Commands INT NOT NULL);

/*GET ALL SUBSCRIBERS LATENCY*/

INSERT INTO @temp
	SELECT
		instance_name,
		(cntr_value / 1000) / 60
	FROM sys.dm_os_performance_counters
	WHERE object_name LIKE '%Replic%'
	AND counter_name LIKE '%Dist%latency%'


/*TOP 2 TABLES THAT ARE BEHIND PER SUBSCRIPTION*/

INSERT INTO @temptbl
	SELECT DISTINCT TOP 5
		ag.name,
		a.article,
		s.UndelivCmdsInDistDB
	FROM dbo.MSdistribution_status s
	INNER JOIN dbo.msdistribution_agents ag
		ON ag.id = s.agent_id
	INNER JOIN dbo.msarticles a
		ON a.publisher_id = ag.publisher_id
		AND a.article_id = s.article_id
		AND a.publisher_db = ag.publisher_db
	LEFT JOIN @TEMP T
		ON T.subscriber = ag.name
	WHERE T.latency > @THRESHOLD
	ORDER BY s.UndelivCmdsInDistDB DESC

	SELECT
	Subscriber,
	latency	
FROM @temp
WHERE LATENCY >= @THRESHOLD
order by latency desc


SELECT
	Name,
	Article,
	Commands
FROM @temptbl tt
JOIN @temp tm
	ON tm.subscriber = tt.name
WHERE tm.latency > @THRESHOLD
ORDER BY Name, Commands DESC