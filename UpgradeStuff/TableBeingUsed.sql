
SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
         --I.[NAME] AS [INDEX NAME], 
        -- sum(USER_SEEKS) 'USER_SEEKS', 
		 max(S.last_user_seek) 'last_user_seek',
        -- sum(USER_SCANS) 'USER_SCANS', 
		 max(s.last_user_scan) 'last_user_scan',
        -- sum(USER_LOOKUPS) 'USER_LOOKUPS', 
		 max(s.last_user_lookup) 'last_user_lookup',
        -- sum(USER_UPDATES) 'USER_UPDATES' ,
		 max(s.last_user_update) 'last_user_update'
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I 
           ON I.[OBJECT_ID] = S.[OBJECT_ID] 
              AND I.INDEX_ID = S.INDEX_ID 
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 
and OBJECT_NAME(S.[OBJECT_ID]) like 'ptc[_]%' and last_user_update > '2018-08-08 11:25:55.777'
group by
S.[OBJECT_ID]
order by
last_user_update desc