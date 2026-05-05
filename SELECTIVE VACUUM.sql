/*
Option 1: Using psql (Recommended)
You can use the \gexec command in the psql terminal. 
This command takes the output of your query and executes every line as a separate SQL command.
*/

-- VACUUM FULL VERBOSE ANALYZE on user schema.tables only
SELECT 'VACUUM FULL VERBOSE ANALYZE "' || schemaname || '"."' || relname || '";'
FROM pg_stat_user_tables
\gexec

-- VACUUM FULL VERBOSE ANALYZE on information_schema schema only
SELECT 'VACUUM FULL VERBOSE ANALYZE "' || schemaname || '"."' || relname || '";'
FROM pg_stat_all_tables
WHERE schemaname = 'information_schema'
\gexec


-- VACUUM FULL VERBOSE ANALYZE on pg_toast schema only
SELECT 'VACUUM FULL VERBOSE ANALYZE "' || schemaname || '"."' || relname || '";'
FROM pg_stat_all_tables
WHERE schemaname = 'pg_toast'
\gexec

-- VACUUM FULL VERBOSE ANALYZE on pg_catalog schema only
SELECT 'VACUUM FULL VERBOSE ANALYZE "' || schemaname || '"."' || relname || '";'
FROM pg_stat_all_tables
WHERE schemaname = 'pg_catalog'
\gexec

/*
Option 2: Using the Command Line
If you are working from a terminal (Bash/Zsh), you can pipe the generated list of commands directly back into psql. 
This is the standard way to "script" a vacuum for all user tables.

-t: Only print rows (no headers).
-A: Unaligned mode (no extra whitespace).
*/

psql -t -A -c "SELECT 'VACUUM FULL \"' || schemaname || '\".\"' || relname || '\";' FROM pg_stat_user_tables" | psql
