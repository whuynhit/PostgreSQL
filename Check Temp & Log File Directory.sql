-- Check temp file generation by database
SELECT
	datname,
	temp_files,
	temp_bytes,
	pg_size_pretty(temp_bytes) AS temp_size
FROM pg_stat_database;

-- Check temp file count, file size and other relevant query information by query PID
SELECT 
    t.pid,  
    t.count, 
    t.sum_size, 
    t.pretty_size,
	a.usename,
	a.datname,
	a.application_name,
	a.backend_type,
	a.client_addr,
	a.wait_event_type,
	a.wait_event,
    a.state,
	a.query,
	now() - a.xact_start AS xact_age,
	now() - a.query_start AS query_age
FROM (
	SELECT
		REPLACE(LEFT(name, strpos(name, '.') - 1), 'pgsql_tmp', '')::integer as pid, 
		COUNT(*) AS count, 
		SUM(size) AS sum_size,
		pg_size_pretty(SUM(size)) AS pretty_size
	FROM pg_ls_tmpdir() 
	GROUP BY pid
) t
JOIN pg_stat_activity a ON t.pid = a.pid;

-- Check temp file count & size by PID
SELECT
	REPLACE(LEFT(name, strpos(name, '.')-1),'pgsql_tmp','') as pid, 
	COUNT(*), 
	SUM(size),
	pg_size_pretty(SUM(size))
FROM pg_ls_tmpdir() 
GROUP BY pid;

-- Check temp File directory for temp files, and their size (Consumes FreeLocalStorage)
SELECT 
	name,
	size AS size_bytes,
	pg_size_pretty(size) AS size,
	modification
FROM pg_ls_tmpdir()
ORDER BY size_bytes DESC;

-- Check total size of temp files in directory
SELECT pg_size_pretty(SUM(size)) AS temp_files_total_size
FROM pg_ls_tmpdir();

-- Check log File directory for log files, and their size (Consumes FreeLocalStorage)
SELECT 
	name,
	size AS size_bytes,
	pg_size_pretty(size) AS size,
	modification
FROM pg_ls_logdir()
ORDER BY size_bytes DESC;

-- Check total size of log files in directory
SELECT pg_size_pretty(SUM(size)) AS log_files_total_size
FROM pg_ls_logdir();
