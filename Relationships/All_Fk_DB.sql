SELECT fk.name AS Foreign_Key,
--SCHEMA_NAME(fk.schema_id) AS Schema_Name,
OBJECT_NAME(fk.parent_object_id) AS Table_Name,
--SCHEMA_NAME(o.schema_id) Referenced_Schema_Name,
OBJECT_NAME (fk.referenced_object_id) AS Referenced_Table_Name
,COL_NAME(fc.referenced_object_id, fc.referenced_column_id) referenced_column_name
FROM sys.foreign_keys fk
INNER JOIN sys.objects o ON fk.referenced_object_id = o.object_id
INNER JOIN sys.foreign_key_columns AS fc
   ON fk.object_id = fc.constraint_object_id
ORDER BY Referenced_Table_Name