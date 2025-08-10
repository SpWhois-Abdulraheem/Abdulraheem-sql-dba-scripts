---Table Fragmentation Fix -----

1. show table status;

2. SELECT
    table_schema,
    table_name,
    ROUND(data_length/1024/1024) AS data_MB,
    ROUND(data_free/1024/1024) AS free_MB,
    ROUND((data_free/data_length)*100, 2) AS frag_pct
FROM information_schema.tables
WHERE engine = 'InnoDB'
  AND data_free > 0
  AND table_schema NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')
ORDER BY free_MB DESC;


3. SELECT CONCAT('OPTIMIZE TABLE `', table_schema, '`.`', table_name, '`;') AS stmt
FROM information_schema.tables
WHERE engine = 'InnoDB'
  AND data_free > 1024 * 1024 * 500 -- More than 500MB of free space
  AND table_schema NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')
ORDER BY data_free DESC;