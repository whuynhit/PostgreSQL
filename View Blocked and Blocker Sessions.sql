-- View Blocked and Blocker Sessions
SELECT
    blocked.pid AS blocked_pid,
	blocked.datname AS blocked_db,
	blocked.usename AS blocked_user,
	blocked.client_addr AS blocked_ip,
    blocked.query AS blocked_query,
	now() - blocked.query_start blocked_age,
    blocker.pid AS blocker_pid,
	blocker.datname AS blocker_db,
	blocker.usename AS blocker_user,
	blocker.client_addr AS blocker_ip,
    blocker.query AS blocker_query,
	now() - blocker.query_start blocker_age
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocker
    ON blocker.pid = ANY(pg_blocking_pids(blocked.pid));
