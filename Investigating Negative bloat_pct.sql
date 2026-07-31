-- Queries about specific table and column for indexes that return negative bloat_pct
SELECT
    reltuples::bigint,
    relpages
FROM pg_class
WHERE oid =
'schema_name.table_name'::regclass;

SELECT
    null_frac,
    n_distinct,
    avg_width
FROM pg_stats
WHERE schemaname='schema_name'
AND tablename='table_name'
AND attname='column_name';
