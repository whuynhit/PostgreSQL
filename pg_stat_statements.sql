SELECT query, calls, total_exec_time, rows, mean_exec_time
FROM pg_stat_statements
WHERE queryid = '<queryid_from_PI>';
