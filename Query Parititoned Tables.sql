-- Query Parititoned Tables by Parent Tables
WITH RECURSIVE table_hierarchy AS (
    -- Anchor member: Find the parent table by name
    SELECT c.oid AS table_oid
    FROM pg_class c
	JOIN pg_namespace n ON c.relnamespace = n.oid 
    WHERE n.nspname = 'public'  -- Change 'public' to your schema if needed 
    AND relname IN ('parent_table_name')
    
    UNION ALL
    
    -- Recursive member: Find all child partitions/inherited tables
    SELECT i.inhrelid
    FROM pg_inherits i
    JOIN table_hierarchy h ON i.inhparent = h.table_oid
)
SELECT stat.*
FROM pg_stat_user_tables stat
WHERE stat.relid IN (SELECT table_oid FROM table_hierarchy)
ORDER BY relname;
