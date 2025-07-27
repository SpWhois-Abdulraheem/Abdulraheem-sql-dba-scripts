use distribution
go
select @@servername as [Dist], pub.name as [Pub], s.publisher_db as [DB], pb.publication,  a.article--, sub.name as [Sub]
from dbo.MSsubscriptions s
INNER JOIN dbo.msarticles a ON a.publisher_id = s.publisher_id AND a.article_id = s.article_id and a.publisher_db = s.publisher_db
INNER JOIN master.sys.servers pub ON pub.server_id = s.publisher_id
INNER JOIN master.sys.servers sub ON sub.server_id = s.subscriber_id
INNER JOIN dbo.MSpublications pb ON pb.publication_id = s.publication_id
where status = 1 and subscriber_id > 0
order by [Pub], [DB], a.article desc 