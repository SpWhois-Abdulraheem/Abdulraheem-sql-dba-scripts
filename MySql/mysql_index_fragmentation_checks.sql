QUERY 1 --- useful for general index bloat analysis, when innodb_index_stats is missing or empty.

SELECT 
  table_schema, 
  table_name, 
  ROUND(data_length / 1024 / 1024, 2) AS data_mb,
  ROUND(index_length / 1024 / 1024, 2) AS index_mb,
  ROUND(index_length / data_length, 2) AS index_to_data_ratio
FROM 
  information_schema.tables
WHERE 
  engine = 'InnoDB'
  AND table_schema NOT IN ('mysql', 'performance_schema', 'information_schema')
  AND data_length > 0
ORDER BY 
  index_to_data_ratio DESC;


QUERY 2 --- simple optimize if index_to_data_ratio > 2.0, a quick, rough-cleanup of large indexes, not ideal for regular maintenance

SELECT 
  CONCAT('OPTIMIZE TABLE `', table_schema, '`.`', table_name, '`;') AS optimize_stmt
FROM 
  information_schema.tables
WHERE 
  engine = 'InnoDB'
  AND table_schema NOT IN ('mysql', 'performance_schema', 'information_schema')
  AND data_length > 0
  AND index_length / data_length > 2.0
ORDER BY 
  index_length / data_length DESC;

QUERY 3 --- Fragmented-index finder(detailed)

/* ── Fragmented-index finder  ───────────────────────────────────────────
     Lists the 50 worst-offending InnoDB indexes, ordered by size.
     "rows_per_page" << 100 ⇒ much empty space per leaf page            */
SELECT
    idx.database_name              AS table_schema,
    idx.table_name,
    idx.index_name,
    idx.n_leaf_pages               AS leaf_pages,
    t.table_rows                   AS approx_rows,
    ROUND(t.table_rows / idx.n_leaf_pages, 2)  AS rows_per_page,
    ROUND(idx.n_leaf_pages * @@innodb_page_size / 1024 / 1024, 2)
                                     AS approx_index_size_mb
FROM   (
        SELECT  database_name,
                table_name,
                index_name,
                stat_value AS n_leaf_pages
        FROM    mysql.innodb_index_stats
        WHERE   stat_name = 'n_leaf_pages'
      ) AS idx
JOIN   information_schema.tables t
       ON  t.table_schema = idx.database_name
       AND t.table_name   = idx.table_name
WHERE  t.engine = 'InnoDB'
  AND  idx.database_name NOT IN ('mysql','information_schema',
                                 'performance_schema')
  AND  idx.n_leaf_pages > 100                 -- ignore tiny indexes
HAVING rows_per_page < 100                    -- <-- fragmentation threshold
ORDER  BY approx_index_size_mb DESC;


QUERY 4 --- For actual index defragmentation routine check

SELECT 
  CONCAT('OPTIMIZE TABLE `', idx.database_name, '`.`', idx.table_name, '`;') AS optimize_stmt
FROM (
  SELECT 
    i.database_name, 
    i.table_name, 
    i.index_name,
    i.n_leaf_pages,
    t.table_rows,
    ROUND(t.table_rows / i.n_leaf_pages, 2) AS rows_per_page
  FROM (
    SELECT 
      database_name, 
      table_name, 
      index_name, 
      stat_value AS n_leaf_pages
    FROM 
      mysql.innodb_index_stats
    WHERE 
      stat_name = 'n_leaf_pages'
  ) i
  JOIN information_schema.tables t
    ON t.table_schema = i.database_name
   AND t.table_name = i.table_name
  WHERE 
    t.engine = 'InnoDB'
    AND i.n_leaf_pages > 100
    AND t.table_rows > 0
    AND ROUND(t.table_rows / i.n_leaf_pages, 2) < 20
    AND i.database_name NOT IN ('mysql', 'information_schema', 'performance_schema')
) AS idx
ORDER BY optimize_stmt;











