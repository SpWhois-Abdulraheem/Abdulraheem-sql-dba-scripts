
SELECT  publisher_database_id, COUNT(*) as [count]
Into #count
  FROM [distribution].[dbo].[MSrepl_commands] c
  group by publisher_database_id
 
 
 Select c.publisher_database_id, p.publisher_db, c.[count]
 FROM #count c
   INNER JOIN [distribution].[dbo].[MSpublisher_databases] p ON p.id = c.publisher_database_id 
   
   DROP TABLE #count
------------------------------------------------------------------------------
--Top ID and Database name feeds into bottom
------------------------------------------------------------------------------
SELECT article_id, COUNT(*) as [count]
INTO #count2
  FROM [distribution].[dbo].[MSrepl_commands] with (nolock)
  where publisher_database_id = 1
  Group by article_id
  
  Select a.article, c.[count]
  FROM #count2 c
  INNER JOIN [distribution].[dbo].[MSarticles] a on c.article_id=a.article_id
  WHERE a.publisher_db = 'PL'
  ORDER BY [COUNT] desc
  
  drop table #count2