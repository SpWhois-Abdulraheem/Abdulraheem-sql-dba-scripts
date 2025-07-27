--to validate these numbers, check the properties of the tempdb instance and check the physical file size
--they will be similar but not exact

  SELECT SUM(df.size)*1.0/128  AS [size in MB],
   --SUM(unallocated_extent_page_count) AS [free pages], 
(SUM(fsu.unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage fsu
JOIN tempdb.sys.database_files df
ON fsu.FILE_ID = df.FILE_ID