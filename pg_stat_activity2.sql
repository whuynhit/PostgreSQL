SELECT
    a.pid,
    a.usename,
    a.datname,
    a.client_addr,
    a.application_name,
    a.state,
    a.wait_event_type,
    a.wait_event,
    now() - a.query_start AS query_duration,
    a.backend_type,
    a.query,
    bl.blocking_pid,
    bl.blocking_user,
    bl.blocking_query_start,
    now() - bl.blocking_query_start AS blocking_duration,
    bl.blocking_query
FROM pg_stat_activity a
LEFT JOIN LATERAL (
    SELECT
        w.pid AS blocking_pid,
        w.usename AS blocking_user,
        w.query AS blocking_query,
        w.query_start AS blocking_query_start
    FROM pg_stat_activity w
    JOIN pg_locks wl ON w.pid = wl.pid
    JOIN pg_locks l  ON wl.locktype = l.locktype
                     AND wl.database IS NOT DISTINCT FROM l.database
                     AND wl.relation IS NOT DISTINCT FROM l.relation
                     AND wl.page IS NOT DISTINCT FROM l.page
                     AND wl.tuple IS NOT DISTINCT FROM l.tuple
                     AND wl.virtualxid IS NOT DISTINCT FROM l.virtualxid
                     AND wl.transactionid IS NOT DISTINCT FROM l.transactionid
                     AND wl.classid IS NOT DISTINCT FROM l.classid
                     AND wl.objid IS NOT DISTINCT FROM l.objid
                     AND wl.objsubid IS NOT DISTINCT FROM l.objsubid
    WHERE NOT wl.granted
      AND l.pid = a.pid
) bl ON TRUE
WHERE a.state IN ('active', 'idle in transaction')
ORDER BY query_duration DESC;
