-- Query Parititoned Tables by Parent Tables
WITH RECURSIVE table_hierarchy AS (
    -- Anchor member: Find the parent table by name
    SELECT oid AS table_oid
    FROM pg_class
    WHERE relname = 'parent_table_name' 
      AND relnamespace = 'public'::regnamespace  -- Change 'public' to your schema if needed
    
    UNION ALL
    
    -- Recursive member: Find all child partitions/inherited tables
    SELECT i.inhrelid
    FROM pg_inherits i
    JOIN table_hierarchy h ON i.inhparent = h.table_oid
)
SELECT stat.*
FROM pg_stat_user_tables stat
WHERE stat.relid IN (SELECT table_oid FROM table_hierarchy);
