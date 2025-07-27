/****** Search by TABLE_NAME
	This script will show you if a table is being published and
	which publication it belongs to.   ******/

USE [PL]
SELECT syspublications.name as Publication, sysarticles.name as Article
    --, sysarticles.pubid,  syspublications.pubid
FROM [PL].[dbo].[sysarticles]
    INNER JOIN [PL].[dbo].[syspublications]
    ON sysarticles.pubid = syspublications.pubid
WHERE sysarticles.name = 'TABLE_NAME'