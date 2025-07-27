DECLARE @FilterReportPath AS VARCHAR(500) = NULL 

DECLARE @FilterReportName AS VARCHAR(500) = NULL

--reports to be downloaded..
DECLARE @OutPath AS VARCHAR(500) = 'D:\\Reports\\Download\'
--Make sure this folder exist in drive
--Used to prepare the dynamic query

DECLARE @TSQL AS NVARCHAR(MAX)

--Simple validation of OutputPath; this can be changed as per ones need.


IF LTRIM(RTRIM(ISNULL(@OutPath,''))) = ''

BEGIN

  SELECT 'Invalid Output Path'

END

ELSE
print @OutPath

BEGIN

   --select * from Catalog
   SET @TSQL = STUFF((SELECT

                      ';EXEC master..xp_cmdshell ''bcp " ' +
                      ' SELECT ' +
                      ' CONVERT(VARCHAR(MAX), ' +
                      '       CASE ' +
                      '         WHEN LEFT(C.Content,3) = 0xEFBBBF THEN STUFF(C.Content,1,3,'''''''') '+
                      '         ELSE C.Content '+
                      '       END) ' +
                      ' FROM ' +
                      ' [ReportServer].[dbo].[Catalog] CL ' +
                      ' CROSS APPLY (SELECT CONVERT(VARBINARY(MAX),CL.Content) Content) C ' +
                      ' WHERE ' +
                      ' CL.ItemID = ''''' + CONVERT(VARCHAR(MAX), CL.ItemID) + ''''' " queryout "' + @OutPath + '' + CL.Name + '.rdl" ' + '-T -c -x'''
                    FROM
                      [ReportServer].[dbo].[Catalog] CL
                    WHERE
                      CL.[Type] = 2 --Report
                      AND '/' + CL.[Path] + '/' LIKE COALESCE('%/%' + @FilterReportPath + '%/%', '/' + CL.[Path] + '/')
                      AND CL.Name LIKE COALESCE('%' + @FilterReportName + '%', CL.Name)
                    FOR XML PATH('')), 1,1,'')

  --Execute the Dynamic Query
  print @TSQL

  EXEC SP_EXECUTESQL @TSQL

END