-- See who is blocking is blocking who
WITH blocked AS (
  SELECT bl.locktype, bl.database, bl.relation, bl.page, bl.tuple, bl.virtualxid, bl.transactionid,
         bl.pid AS blocked_pid
  FROM pg_locks bl
  WHERE NOT bl.granted
)
SELECT b.blocked_pid,
       a.usename         AS blocked_user,
       a.client_addr     AS blocked_client,
       a.application_name,
       a.query           AS blocked_query,
       now() - a.query_start AS blocked_query_age,
       kl.pid            AS blocking_pid,
       ka.usename        AS blocking_user,
       ka.client_addr    AS blocking_client,
       ka.application_name AS blocking_app,
       ka.query          AS blocking_query,
       now() - ka.query_start AS blocking_query_age
FROM blocked b
JOIN pg_stat_activity a ON a.pid = b.blocked_pid
JOIN pg_locks kl ON (kl.transactionid = b.transactionid OR (kl.locktype = b.locktype AND kl.tuple = b.tuple))
JOIN pg_stat_activity ka ON ka.pid = kl.pid
ORDER BY blocked_query_age DESC;
