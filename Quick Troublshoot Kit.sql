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
SELECT datname, tempfiles, pg_size_pretty(temp_bytes) AS temp_size
FROM pg_stat_database;

-- Long-running transaction blocking vacuum
SELECT pid, now() - xact_start AS duration, query
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY duration DESC;
