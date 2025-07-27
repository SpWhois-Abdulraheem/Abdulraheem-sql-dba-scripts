SELECT 
  msp.publication AS PublicationName,
  msa.publisher_db AS DatabaseName,
  msa.article AS ArticleName,
  msa.source_owner AS SchemaName,
  msa.source_object AS TableName
FROM distribution.dbo.MSarticles msa
JOIN distribution.dbo.MSpublications msp ON msa.publication_id = msp.publication_id
--where msp.publication = 'PL_Rating_TRep' or msp.publication = 'PLV01_TRep' or msp.publication = 'PLV02_TRep' or msp.publication = 'PLV03_TRep' or msp.publication = 'PLV04_TRep'
ORDER BY 
  msp.publication, 
  msa.article