/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ID]
      --,[Server Name]
      --,[Server Version]
      --,[Database Name]
      --,[Issue]
      --,[Source Compatibility Level]
      --,[Impact]
      --,[Target Compatibility Level]
      --,[Compatibility Category]
      --,[Recommendation]
      --,[More Info]
      ,[Impacted Object]
      ,'ALTER TABLE '+REPLACE(RIGHT([Impacted Object], LEN([Impacted Object])-4),'.', ' ALTER COLUMN ')+' NVARCHAR(MAX)' 'alter script'
	  ,LEFT(RIGHT([Impacted Object], LEN([Impacted Object])-4),CHARINDEX('.',RIGHT([Impacted Object], LEN([Impacted Object])-4))-1) 'TABLE NAME'
	  ,SUBSTRING(
	  RIGHT([Impacted Object], LEN([Impacted Object])-4)
	  ,CHARINDEX('.',RIGHT([Impacted Object], (LEN([Impacted Object])-4)))+1
	  ,100) 'COLUMN NAME'
	  
      ,(SELECT DATA_TYPE 
	  FROM INFORMATION_SCHEMA.COLUMNS
		WHERE 
     TABLE_NAME = LEFT(RIGHT([Impacted Object], LEN([Impacted Object])-4),CHARINDEX('.',RIGHT([Impacted Object], LEN([Impacted Object])-4))-1) AND 
     COLUMN_NAME = SUBSTRING(
	  RIGHT([Impacted Object], LEN([Impacted Object])-4)
	  ,CHARINDEX('.',RIGHT([Impacted Object], (LEN([Impacted Object])-4)))+1
	  ,100)) 'Current data type'


      --,[Planned Change Date]
      --,[Origional Object Scripted]
      --,[Alter Script Created]
      --,[Complete]
      --,[APP]

	  into #temp
  FROM [DB_Utility].[DB_Utility].[dbo].[ProductionUpgrade]
  where issue = 'Deprecated data types TEXT, IMAGE or NTEXT'


  select * from #temp where [Current data type] is not null

  drop table #temp