-- View Long-Running Transaction
SELECT --'SELECT pg_terminate_backend(' || pid || ');',
	pid, usename, datname, application_name, backend_type, client_addr, 
	wait_event_type || ':' || wait_event AS wait_event, state, query,
	now() - xact_start AS xact_age, now() - query_start AS query_age
FROM pg_stat_activity
WHERE xact_start IS NOT NULL --AND backend_type != 'parallel worker' 
ORDER BY query_age DESC, backend_type
LIMIT 50;
