-- View Connection Count by Database and IP Address
SELECT 
datname AS database,
client_addr, 
COUNT(*) AS connection_count,
SUM(COUNT(1)) OVER() AS total_connections,
now() AT TIME ZONE 'America/Los_Angeles'
FROM pg_stat_activity
WHERE client_addr IS NOT NULL
GROUP BY datname, client_addr
ORDER BY connection_count DESC;
