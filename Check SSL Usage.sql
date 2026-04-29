-- Check if specific user is connected using SSL/TLS.
SELECT 
  a.pid,
  a.usename,
  a.datname,
  a.client_addr,
  a.application_name,
  a.state,
  s.ssl,
  s.version as ssl_version,
  s.cipher,
  query_start,
  now() - query_start as duration
FROM pg_stat_activity a
INNER JOIN pg_stat_ssl s
ON a.pid = s.pid
WHERE usename = 'username'
ORDER BY s.pid;
