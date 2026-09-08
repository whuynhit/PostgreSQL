-- List all objects and their size within current database.
SELECT
  	current_database() AS database,
  	n.nspname AS schema_name,
  	c.relname AS object_name,
  	CASE 
  	WHEN c.relkind = 'r' THEN 'table'
  	WHEN c.relkind = 'i' THEN 'index'
  	WHEN c.relkind = 'S' THEN 'sequence'
  	WHEN c.relkind = 't' THEN 'TOAST'
  	WHEN c.relkind = 'v' THEN 'view'
  	WHEN c.relkind = 'm' THEN 'materialized view'
  	WHEN c.relkind = 'c' THEN 'composite type'
  	WHEN c.relkind = 'f' THEN 'foreign table'
  	WHEN c.relkind = 'p' THEN 'partitioned table'
  	WHEN c.relkind = 'I' THEN 'partitioned index'
  	ELSE 'other'
    END AS object_type,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
-- AND c.relispartition = false -- Uncomment to filter out Child Partitions
ORDER BY schema_name, object_name;
-- ORDER BY pg_total_relation_size(c.oid) DESC;

-- List object count by schema and object type
SELECT
    current_database() AS database,
    DISTINCT n.nspname AS schema_name,
  	c.relkind,
    CASE 
  	WHEN c.relkind = 'r' THEN 'table'
  	WHEN c.relkind = 'i' THEN 'index'
  	WHEN c.relkind = 'S' THEN 'sequence'
  	WHEN c.relkind = 't' THEN 'TOAST'
  	WHEN c.relkind = 'v' THEN 'view'
  	WHEN c.relkind = 'm' THEN 'materialized view'
  	WHEN c.relkind = 'c' THEN 'composite type'
  	WHEN c.relkind = 'f' THEN 'foreign table'
  	WHEN c.relkind = 'p' THEN 'partitioned table'
  	WHEN c.relkind = 'I' THEN 'partitioned index'
  	ELSE 'other'
    END AS type,
    COUNT (1)
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
-- AND c.relispartition = false -- Uncomment to filter out Child Partitions
GROUP BY schema_name, c.relkind,
ORDER BY schema_name, type;
