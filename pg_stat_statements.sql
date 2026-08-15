-- Old query
SELECT query, calls, total_exec_time, rows, mean_exec_time
FROM pg_stat_statements
WHERE queryid = '<queryid_from_PI>';

-- Query for written temp file size
SELECT
    queryid,
    calls,
    temp_blks_written,
    pg_size_pretty(temp_blks_written * 8192) AS temp_written,
    query
FROM pg_stat_statements
ORDER BY temp_blks_written DESC
LIMIT 20;
