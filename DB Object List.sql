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
-- AND NOT c.relispartition -- Uncomment to filter out Child Partitions
ORDER BY schema_name, object_name;
-- ORDER BY pg_total_relation_size(c.oid) DESC; -- Sort by largest object size

-- List object count by object type
SELECT
    DISTINCT current_database() AS database,
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
    COUNT (1),
    now() AT TIME ZONE 'America/Los_Angeles'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
-- AND NOT c.relispartition -- Uncomment to filter out Child Partitions
GROUP BY c.relkind
ORDER BY object_type;

-- List object count by schema and object type
SELECT
    DISTINCT current_database() AS database,
    n.nspname AS schema_name,
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
    COUNT (1),
    now() AT TIME ZONE 'America/Los_Angeles'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
-- AND NOT c.relispartition -- Uncomment to filter out Child Partitions
GROUP BY schema_name, c.relkind
ORDER BY schema_name, object_type;

-- Lists tables and table statistics [Partitioned Tables (p) and Tables (r) only, no Materialized Views (m)]
SELECT s.*
FROM pg_stat_user_tables s
JOIN pg_class c 
ON s.relid = c.oid
WHERE c.relkind IN ('p', 'r') -- Comment out to show all tables + materialized views 
AND NOT c.relispartition -- Filters out Child Partitions
ORDER BY schemaname, relname;

-- List tables and table owner
SELECT t.*
FROM pg_tables t
JOIN pg_namespace n ON t.schemaname = n.nspname
JOIN pg_class c ON t.tablename = c.relname AND c.relnamespace = n.oid
WHERE t.schemaname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
AND NOT c.relispartition -- Filters out Child Partitions
ORDER BY t.schemaname, t.tablename;
