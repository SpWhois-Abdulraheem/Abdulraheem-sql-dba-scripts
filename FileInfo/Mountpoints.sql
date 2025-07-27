SELECT DISTINCT
volume_mount_point
,CASE  
           WHEN (total_bytes) > 1000 THEN CAST(CAST(((total_bytes) / 1073741824.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB'           
         END AS MountpointSize 
,CASE  
           WHEN (available_bytes) > 1000 THEN CAST(CAST(((available_bytes) / 1073741824.0) AS DECIMAL(18,2)) AS VARCHAR(20)) + ' GB'           
         END AS MountpointFree
FROM sys.master_files AS f
JOIN SYS.MASTER_FILES B 
           ON f.DATABASE_ID = B.DATABASE_ID   
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
ORDER BY MountpointFree ASC