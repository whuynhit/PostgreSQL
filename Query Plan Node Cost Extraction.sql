--Query Plan Node Cost Extraction
-- Provide the following connection details and query
SET psql.dir = 'C:\Program Files\PostgreSQL\15\bin\psql.exe';
SET psql.host = '[host]';
SET psql.port = '[port]';
SET psql.username = '[user]';
SET psql.database = '[database]';
SET psql.space = ' ';
SET psql.char = '^';
SET psql.query = '<multi-line query here>';

SELECT 
	'"' || current_setting('psql.dir') || '"' ||current_setting('psql.space') || current_setting('psql.char')
	|| chr(10) || '-h '||current_setting('psql.host') || current_setting('psql.space') || current_setting('psql.char')
	|| chr(10) || '-p '||current_setting('psql.port') || current_setting('psql.space') || current_setting('psql.char')
	|| chr(10) || '-U '||current_setting('psql.username') || current_setting('psql.space') || current_setting('psql.char')
	|| chr(10) || '-d '||current_setting('psql.database') || current_setting('psql.space') || current_setting('psql.char')
	|| chr(10) || '--pset=pager=off' || current_setting('psql.space') || current_setting('psql.char') -- Display all results instead of paginated results
	|| chr(10) || '-c "' || regexp_replace(current_setting('psql.query'), E'\n', ' ', 'g') || '"' || ' | findstr "cost="' -- Collapse multi-line query into 1 line
;
