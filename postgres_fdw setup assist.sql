-- List any existing foreign servers used for postgres_fdw
SELECT *
FROM pg_foreign_server;

-- List any existing foreign tables from foreign servers
SELECT *
FROM information_schema.foreign_tables;

-- Generate script to CREATE fdw schema to store foreign tables
SELECT 'CREATE SCHEMA IF NOT EXISTS ' || nspname || '_fdw_<database_name>;'
FROM pg_namespace
WHERE nspowner = 16400
ORDER BY nspname;

-- Generate script to DROP fdw schema holding foreign tables, as needed
SELECT 'DROP SCHEMA IF EXISTS ' || nspname || '_fdw_<database_name>' || ' CASCADE;'
FROM pg_namespace
WHERE nspowner = 16400
ORDER BY nspname;

-- Generate script to IMPORT FOREIGN SCHEMA from source to destination fdw schema
SELECT 
	'IMPORT FOREIGN SCHEMA ' || nspname || chr(10) ||
	'FROM SERVER ' || '<foreign_server_name>' || chr(10) ||
	'INTO ' || nspname || '_fdw_<database_name>;'
FROM pg_namespace
WHERE nspowner = 16400
ORDER BY nspname;
