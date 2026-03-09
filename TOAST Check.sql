-- You can see all TOAST tables related to your table with:
SELECT relname AS toast_table
FROM pg_class
WHERE reltoastrelid = (
    SELECT oid FROM pg_class WHERE relname = 'my_table'
);

-- Check Sizes
SELECT
    c.relname AS toast_table,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
WHERE c.relkind = 't' -- TOAST table
AND c.oid = (
    SELECT reltoastrelid
    FROM pg_class
    WHERE relname = 'my_table'
);

-- Estimate TOAST Bloat
SELECT
    pg_size_pretty(pg_total_relation_size(relid)) AS toast_total,
    pg_relation_size(relid) AS toast_heap,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS toast_indexes
FROM pg_class
WHERE oid = (SELECT reltoastrelid FROM pg_class WHERE relname = 'my_table');
