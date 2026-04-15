-- Database Size breakdown
SELECT datname, pg_size_pretty(pg_database_size(datname))
FROM pg_database
ORDER BY pg_database_size(datname) DESC;

-- Largest table by size
SELECT
    schemaname,
    relname,
    pg_size_pretty(pg_total_relation_size(relid)) AS size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 20;

-- Check replication slots for WAL Bloat
SELECT * FROM pg_replication_slots;

-- Check for WAL accumulation and Table bloat
SELECT relname, n_dead_tup
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;

-- Bulk load/runaway job
SELECT datname, temp_files, pg_size_pretty(temp_bytes) AS temp_size
FROM pg_stat_database
ORDER BY temp_bytes DESC;

/* Find the Actual Offending Query

What to look for:
    Highest temp_bytes
    Long runtime
    state = active
    Suspicious query patterns:
        Large ORDER BY
        JOIN without indexes
        SELECT * on huge tables
        ETL jobs 
*/
SELECT
    pid,
    usename,
    application_name,
    state,
    wait_event_type,
    wait_event,
    now() - query_start AS runtime,
    query
FROM pg_stat_activity;

-- Catch Long-Running / Heavy Queries
SELECT
    pid,
    usename,
    application_name,
    now() - query_start AS runtime,
    state,
    query
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY runtime DESC
LIMIT 20;

-- Look for Sort/Hash Spills (Indirect Signal)
SELECT
    query,
    calls,
    total_exec_time,
    temp_blks_written,
    temp_blks_read
FROM pg_stat_statements
ORDER BY temp_blks_written DESC
LIMIT 10;

-- Kill the Right Query (Safely)
SELECT pg_terminate_backend(<pid>);

-- Long-running transaction blocking vacuum
SELECT pid, now() - xact_start AS duration, query
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY duration DESC;

-- Check if specific user's connections are using SSL/TLS based on matching pid
SELECT 
	a.pid,
	a.usename,
	a.datname,
	a.client_addr,
	a.application_name,
	a.state,
	s.ssl,
	s.version as ssl_version,
	s.cipher,
	query_start,
	now() - query_start as duration
FROM pg_stat_activity a
INNER JOIN pg_stat_ssl s
ON a.pid = s.pid
WHERE usename = 'username'
ORDER BY s.pid;
