-- Generate cmdlet script to extract Query Plan Node Cost
-- Provide the following connection details and query
-- Then run the output in Windows CMD
SET util.dir = 'D:\Program Files\PostgreSQL\17\bin\psql.exe'; -- %1$s
SET util.host = '[host]'; -- %2$s
SET util.port = '[port]'; -- %3$s
SET util.username = '[user]'; -- %4$s
SET util.database = '[database]'; -- %5$s
SET util.char = '^'; -- %6$s
SET util.query = $SQL$<multi-line query here>$SQL$; -- %7$s

SELECT
format($$"%1$s" %6$s
-h %2$s %6$s
-p %3$s %6$s
-U %4$s %6$s
-d %5$s %6$s
--pset=pager=off %6$s
-c %7$I | findstr "cost="$$
,
current_setting('util.dir'),
current_setting('util.host'),
current_setting('util.port'),
current_setting('util.username'),
current_setting('util.database'),
current_setting('util.char'),
regexp_replace(current_setting('util.query'), E'\n', ' ', 'g')
);


/*============
-- OLD Version
=============*/
SET util.dir = 'D:\Program Files\PostgreSQL\17\bin\psql.exe';
SET util.host = '[host]';
SET util.port = '[port]';
SET util.username = '[user]';
SET util.database = '[database]';
SET util.char = '^';
SET util.query = $SQL$<multi-line query here>$SQL$;

SELECT 
	'"' || current_setting('util.dir') || '"' || ' ' || current_setting('util.char')
	|| chr(10) || '-h '||current_setting('util.host') || ' ' || current_setting('util.char')
	|| chr(10) || '-p '||current_setting('util.port') || ' ' || current_setting('util.char')
	|| chr(10) || '-U '||current_setting('util.username') || ' ' || current_setting('util.char')
	|| chr(10) || '-d '||current_setting('util.database') || ' ' || current_setting('util.char')
	|| chr(10) || '--pset=pager=off' || ' ' || current_setting('util.char') -- Display all results instead of paginated results
	|| chr(10) || '-c "' || regexp_replace(current_setting('util.query'), E'\n', ' ', 'g') || '"' || ' | findstr "cost="' -- Collapse multi-line query into 1 line
;
