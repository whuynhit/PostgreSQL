-- Show all users including the first default user, excluding users managed and created by RDS.
SELECT * FROM pg_catalog.pg_user
WHERE usename NOT LIKE 'rds%';

-- Count all users including the first default user, excluding users managed and created by RDS.
SELECT COUNT(*) FROM pg_catalog.pg_user
WHERE usename NOT LIKE 'rds%';

-- Lists all databases in RDS Server Cluster/Instance
SELECT 
	inet_server_addr() AS ip_address,
	datname AS database_name,
	CASE
	WHEN datname IN ('postgres','rdsadmin') THEN 'System DB'
	ELSE 'User DB'
	END AS database_type
FROM pg_database
WHERE datname NOT IN ('template0','template1')
ORDER BY database_name;

-- Lists storage usage for all databases in Server/Instance.
SELECT 
	inet_server_addr() AS ip_address,
	datname AS database_name,
	pg_size_pretty(pg_database_size(datname)) as database_size,
	CASE
	WHEN datname IN ('postgres','rdsadmin') THEN 'System DB'
	ELSE 'User DB'
	END AS database_type
FROM pg_database
WHERE datname NOT IN ('template0','template1')
ORDER BY database_type, database_name;

-- List storage size of all schema in currnet database.
SELECT
    n.nspname AS schema_name,
    pg_size_pretty(SUM(pg_total_relation_size(c.oid))::bigint) AS total_size
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
GROUP BY n.nspname
ORDER BY SUM(pg_total_relation_size(c.oid)) DESC;

-- List storage size of all user schema in currnet database.
SELECT
    nspname AS schema_name,
    pg_size_pretty(SUM(pg_total_relation_size(c.oid))::bigint) AS total_size
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
AND c.relkind IN ('r', 'i', 'mv', 't') -- r: table, i: index, mv: materialized view, t: toast table
GROUP BY nspname
ORDER BY SUM(pg_total_relation_size(c.oid)) DESC;

-- Lists storage usage for all tables within current database.
SELECT 
	schemaname AS schema,	
	relname AS table,
	pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY schemaname, relname;

-- Lists storage usage of tables and indexes by tables within current database.
SELECT
	schemaname,
	relname AS table_name, 
	pg_size_pretty(pg_relation_size(relid)) AS table_size,
	pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS index_size,
	pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- List all objects and their size within current database.
SELECT 
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
    END AS type,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY pg_total_relation_size(c.oid) DESC;

-- Check current database storage usage.
SELECT pg_size_pretty(pg_database_size(current_database()));

-- Check sum of the size of all objects from all schema within current database.
SELECT
	pg_size_pretty(SUM(pg_relation_size(c.oid))::bigint) AS total_size
FROM pg_class c

-- Check specific database's storage usage.
SELECT pg_size_pretty(pg_database_size('database_name'));

-- Check specific table storage usage
SELECT pg_size_pretty(pg_total_relation_size('table_name'));

-- Check table size & estimated row count
SELECT 
    pg_size_pretty(pg_total_relation_size(oid)) AS current_size,
    reltuples::bigint AS estimated_row_count
FROM pg_class
WHERE oid = 'table_name'::regclass;

-- Check associated sequence of a specific table column
SELECT pg_get_serial_sequence('schema_name.table_name','column_name')

-- Check for which users are currently connected.
SELECT * FROM pg_stat_activity;
