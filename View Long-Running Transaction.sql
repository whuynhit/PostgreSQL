-- View Long-Running Transaction
SELECT pid, usename, application_name, client_addr, state, query,
       now() - xact_start AS xact_age, now() - query_start AS query_age
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY xact_age DESC
LIMIT 50;
