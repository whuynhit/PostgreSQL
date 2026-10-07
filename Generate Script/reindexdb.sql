-- Generate cmdlet script to connect to a database with reindexdb utility
-- Provide the following connection details 
-- Then run the output in Windows CMD
SET LOCAL util.dir = 'D:\Program Files\PostgreSQL\17\bin\reindexdb.exe'; -- %1$s
SET LOCAL util.host = '[hostname]'; -- %2$s
SET LOCAL util.port = '[port]'; -- %3$s
SET LOCAL util.username = '[username]'; -- %4$s
SET LOCAL util.database = '[database_name]'; -- %5$s
SET LOCAL util.jobs = '8'; -- %6$s
SET LOCAL util.char = '^'; -- %7$s

SELECT
format($$"%1$s" %7$s
-h %2$s %7$s
-p %3$s %7$s
-U %4$s %7$s
-d %5$s %7$s
-j %6$s %7$s
--concurrently %7$s
-v$$
,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.jobs'),
current_setting('util.char')
) AS "REINDEX CONCURRENTLY using reindexdb (SLOWER) - Run in WIN CMD",
format($$"%1$s" %7$s
-h %2$s %7$s
-p %3$s %7$s
-U %4$s %7$s
-d %5$s %7$s
-j %6$s %7$s
-v$$
,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.jobs'),
current_setting('util.char')
) AS "REINDEX using reindexdb (FASTER) - Run in WIN CMD";
