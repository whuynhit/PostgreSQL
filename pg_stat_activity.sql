-- View pg_stat_activity for specific Update Statement
SELECT pid, usename, application_name, state,
       now() - xact_start AS xact_age,
       query
FROM pg_stat_activity
WHERE state != 'idle'
  AND query ILIKE 'update%'
ORDER BY xact_age DESC;
