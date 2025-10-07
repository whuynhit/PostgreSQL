SELECT pid, state, query, wait_event_type, wait_event, backend_type, query_start
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY query_start ASC;
