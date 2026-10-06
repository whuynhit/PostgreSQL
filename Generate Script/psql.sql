-- Generate cmdlet script to connect to a database with psql utility
-- Provide the following connection details 
-- Then run the output in Windows CMD
SET LOCAL util.dir = 'D:\Program Files\PostgreSQL\17\bin\psql.exe'; -- %1$s
SET LOCAL util.host = '[hostname]'; -- %2$s
SET LOCAL util.port = '[port]'; -- %3$s
SET LOCAL util.username = '[username]'; -- %4$s
SET LOCAL util.database = '[database_name]'; -- %5$s
SET LOCAL util.char = '^'; -- %6$s

SELECT
format($$"%1$s" %6$s
-h %2$s %6$s
-p %3$s %6$s
-U %4$s %6$s
-d %5$s$$
,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.char')
) AS "Login using psql - Run Output in Windows CMD";
