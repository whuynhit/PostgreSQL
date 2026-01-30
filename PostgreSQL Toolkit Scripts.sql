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

-- Lists storage usage for all tables within current database.
SELECT 
	schemaname AS schema,	
	relname AS table,
	pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY schemaname, relname;

-- Check current database storage usage.
SELECT pg_size_pretty(pg_database_size(current_database()));

-- Check specific database's storage usage.
SELECT pg_size_pretty(pg_database_size('database_name'));

-- Check specific table storage usage
SELECT pg_size_pretty(pg_total_relation_size('table_name'));

-- Check associated sequence of a specific table column
SELECT pg_get_serial_sequence('schema_name.table_name','column_name');

-- Check for which users are currently connected.
SELECT * FROM pg_stat_activity;
