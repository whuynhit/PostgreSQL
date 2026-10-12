-- Generate cmdlet script to run vacuumlo utility on database
-- Provide the following connection details 
-- Then run the output in Windows CMD
SET LOCAL util.dir = 'D:\Program Files\PostgreSQL\17\bin\vacuumlo.exe'; -- %1$s
SET LOCAL util.host = '[hostname]'; -- %2$s
SET LOCAL util.port = '[port]'; -- %3$s
SET LOCAL util.username = '[username]'; -- %4$s
SET LOCAL util.database = '[database_name]'; -- %5$s
SET LOCAL util.char = '^'; -- %6$s

SELECT
format($$"%1$s" -n -h %2$s -p %3$s -U %4$s -v %5$s$$
,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.char')
) AS "vacuumlo (dry-run) - Run in WIN CMD",
format($$"%1$s" -h %2$s -p %3$s -U %4$s -v %5$s$$
,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.char')
) AS "vacuumlo (actual run) - Run in WIN CMD";
