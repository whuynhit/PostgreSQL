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
