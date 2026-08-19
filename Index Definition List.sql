/*
* List existing indexes and their index definitions.
* Optional: Add UNION ALL
* If you want to list more than 1 schema or want to separate list by parent and child partitioned tables.
*/
SELECT schemaname, tablename, indexname, indexdef || ';'
FROM pg_indexes
WHERE schemaname = 'schemaname'
AND tablename IN (
	'tablename'
)
  
UNION ALL

SELECT schemaname, tablename, indexname, indexdef || ';'
FROM pg_indexes
WHERE schemaname = 'schemaname'
AND tablename IN (
	'tablename'
)
ORDER BY schemaname, tablename;
