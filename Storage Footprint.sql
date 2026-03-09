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
-- 1️⃣ Set your table and schema as session variables
SET my.table = 'my_table';
SET my.schema = 'my_schema';

-- 2️⃣ Single query using current_setting()
WITH main_table AS (
    SELECT
        c.oid AS relid,
        c.relname AS name,
        'heap' AS type,
        pg_relation_size(c.oid) AS heap_size,
        pg_total_relation_size(c.oid) AS total_size
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = current_setting('my.table')
      AND n.nspname = current_setting('my.schema')
      AND c.relkind = 'r'
),
toast_table AS (
    SELECT
        c.oid AS relid,
        c.relname AS name,
        'toast' AS type,
        pg_relation_size(c.oid) AS heap_size,
        pg_total_relation_size(c.oid) AS total_size
    FROM pg_class c
    WHERE c.oid = (
        SELECT reltoastrelid
        FROM pg_class c2
        JOIN pg_namespace n2 ON n2.oid = c2.relnamespace
        WHERE c2.relname = current_setting('my.table')
          AND n2.nspname = current_setting('my.schema')
    )
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
    JOIN pg_class c ON c.oid = i.indrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = current_setting('my.table')
      AND n.nspname = current_setting('my.schema')
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
