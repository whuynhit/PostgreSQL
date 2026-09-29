-- Generate cmdlet script to pg_dump a database
-- Provide the following connection details, utility directory, backup file directory, & log file directory 
-- Then run the output in Windows CMD
SET LOCAL util.dir = 'D:\Program Files\PostgreSQL\17\bin\pg_dump.exe'; -- %1$s
SET LOCAL util.host = '[host]'; -- %2$s
SET LOCAL util.port = '[port]'; -- %3$s
SET LOCAL util.username = '[user]'; -- %4$s
SET LOCAL util.database = '[database]'; -- %5$s
SET LOCAL util.char = '^'; -- %6$s
SET LOCAL util.backup_dir = 'path\backup\db_backup_schema'; -- %7$s
SET LOCAL util.log_dir = 'path\logs\pg_dump\db_backup_schema_dump.log'; -- %8$s

SELECT
format($$"%1$s" %6$s
-h %2$s %6$s
-p %3$s %6$s
-U %4$s %6$s
-d %5$s %6$s
--schema-only %6$s
-j 4 %6$s
--verbose %6$s
-F d %6$s
-f "%7$s"$$
,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.char'),
current_setting('util.backup_dir')
) AS "BACKUP - Run Output in Windows CMD";
