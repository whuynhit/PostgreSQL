-- Generate cmdlet script to pg_restore a database
-- Provide the following connection details, utility directory, backup file directory, & log file directory 
-- Then run the output in Windows CMD
SET LOCAL util.dir = 'D:\Program Files\PostgreSQL\17\bin\pg_restore.exe'; -- %1$s
SET LOCAL util.host = '[hostname]'; -- %2$s
SET LOCAL util.port = '[port]'; -- %3$s
SET LOCAL util.username = '[username]'; -- %4$s
SET LOCAL util.database = '[database_name]'; -- %5$s
SET LOCAL util.backup_dir = 'path\database_backup_schema'; -- %6$s
SET LOCAL util.log_dir = 'path\logs\pg_restore\database_backup_schema_restore.log'; -- %7$s

SELECT
format($$powershell -Command "Measure-Command { & '%1$s' -h %2$s -p %3$s -U %4$s -d %5$s -j 4 --verbose '%6$s' }" 2> "%7$s"$$,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.backup_dir'),
current_setting('util.log_dir')
) AS "RESTORE - Run Output in Windows CMD";
