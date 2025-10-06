-- Summary of lock counts by relation
SELECT c.relname, count(*) AS locks_held
FROM pg_locks l
LEFT JOIN pg_class c ON l.relation = c.oid
GROUP BY c.relname
ORDER BY locks_held DESC
LIMIT 30;
