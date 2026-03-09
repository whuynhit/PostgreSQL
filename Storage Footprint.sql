/*
What this query does:
1. Main table: Shows heap and total size (including TOAST & indexes)
2. TOAST table: Shows its heap and total size (including TOAST indexes)
3. Indexes: Lists all main table indexes individually
4. pg_size_pretty: Converts bytes to GB/MB for easier reading
5. Order: Keeps types grouped for clarity

What to look for:
1. Heap size vs total size: confirms how much space main heap vs indexes/TOAST take
2. OAST size: should roughly match expectations based on large columns; smaller than source indicates replication compacted it efficiently
3. Indexes: should not show excessive bloat (if so, consider REINDEX)
*/
WITH main_table AS (
    SELECT
        c.oid AS relid,
        c.relname AS name,
        'heap' AS type,
        pg_relation_size(c.oid) AS heap_size,
        pg_total_relation_size(c.oid) AS total_size
    FROM pg_class c
    WHERE c.relname = 'my_table'
      AND c.relkind = 'r'  -- regular table
),
toast_table AS (
    SELECT
        c.oid AS relid,
        c.relname AS name,
        'toast' AS type,
        pg_relation_size(c.oid) AS heap_size,
        pg_total_relation_size(c.oid) AS total_size
    FROM pg_class c
    WHERE c.oid = (SELECT reltoastrelid FROM pg_class WHERE relname = 'my_table')
),
indexes AS (
    SELECT
        i.indexrelid AS relid,
        ci.relname AS name,
        'index' AS type,
        pg_relation_size(i.indexrelid) AS heap_size,
        pg_total_relation_size(i.indexrelid) AS total_size
    FROM pg_index i
    JOIN pg_class ci ON ci.oid = i.indexrelid
    WHERE i.indrelid = (SELECT oid FROM pg_class WHERE relname = 'my_table')
)
SELECT
    type,
    name,
    pg_size_pretty(heap_size) AS heap_size,
    pg_size_pretty(total_size) AS total_with_indexes
FROM main_table
UNION ALL
SELECT type, name, pg_size_pretty(heap_size), pg_size_pretty(total_size) FROM toast_table
UNION ALL
SELECT type, name, pg_size_pretty(heap_size), pg_size_pretty(total_size) FROM indexes
ORDER BY type, name;
