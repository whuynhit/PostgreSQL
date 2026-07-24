-- COPY/S3 Import/Export operation progress reporting
SELECT
	c.pid,
	c.datname,
	c.relid::regclass,
	c.command,
	c.type,
	c.bytes_processed,
	pg_size_pretty(c.bytes_processed) AS size_processed,
	c.bytes_total,
	pg_size_pretty(c.bytes_total) AS size_total,
	c.tuples_processed,
	c.tuples_excluded,
	a.usename,
	a.client_addr,
	a.wait_event_type,
	a.wait_event,
	a.state,
	a.query
FROM pg_stat_progress_copy c
INNER JOIN pg_stat_activity a
ON c.pid = a.pid;
