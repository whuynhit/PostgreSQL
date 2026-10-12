-- Generate cmdlet script to pg_dump (Schema-only) a database using powershell
-- Provide the following connection details, utility directory, backup file directory, & log file directory 
-- Then run the output in Windows CMD
SET LOCAL util.dir = 'D:\Program Files\PostgreSQL\17\bin\pg_dump.exe'; -- %1$s
SET LOCAL util.host = '[hostname]'; -- %2$s
SET LOCAL util.port = '[port]'; -- %3$s
SET LOCAL util.username = '[username]'; -- %4$s
SET LOCAL util.database = '[database_name]'; -- %5$s
SET LOCAL util.jobs = '4'; -- %6$s
SET LOCAL util.backup_dir = 'path\database_backup_schema'; -- %7$s
SET LOCAL util.log_dir = 'path\logs\pg_dump\database_backup_schema_dump.log'; -- %8$s

SELECT
format($$powershell -Command "Measure-Command { & '%1$s' -h %2$s -p %3$s -U %4$s -d %5$s -j %6$s --schema-only --verbose -F d -f '%7$s' }" 2> "%8$s"$$,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.jobs'),
current_setting('util.backup_dir'),
current_setting('util.log_dir')
) AS "BACKUP (Schema-only) - Run in WIN CMD";
