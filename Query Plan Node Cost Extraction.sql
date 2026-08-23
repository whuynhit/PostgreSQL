-- Generate cmdlet script to extract Query Plan Node Cost
-- Provide the following connection details and query
-- Then run the output in Windows CMD
SET util.dir = 'C:\Program Files\PostgreSQL\15\bin\psql.exe';
SET util.host = '[host]';
SET util.port = '[port]';
SET util.username = '[user]';
SET util.database = '[database]';
SET util.space = ' ';
SET util.char = '^';
SET util.query = $SQL$<multi-line query here>$SQL$;

SELECT 
	'"' || current_setting('util.dir') || '"' ||current_setting('util.space') || current_setting('util.char')
	|| chr(10) || '-h '||current_setting('util.host') || current_setting('util.space') || current_setting('util.char')
	|| chr(10) || '-p '||current_setting('util.port') || current_setting('util.space') || current_setting('util.char')
	|| chr(10) || '-U '||current_setting('util.username') || current_setting('util.space') || current_setting('util.char')
	|| chr(10) || '-d '||current_setting('util.database') || current_setting('util.space') || current_setting('util.char')
	|| chr(10) || '--pset=pager=off' || current_setting('util.space') || current_setting('util.char') -- Display all results instead of paginated results
	|| chr(10) || '-c "' || regexp_replace(current_setting('util.query'), E'\n', ' ', 'g') || '"' || ' | findstr "cost="' -- Collapse multi-line query into 1 line
;
