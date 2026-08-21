# Query Plan Node Cost Extraction

# Part 1: Convert multi-line query to single-line query
# Paste multi-line query in sql.query variable
# Run the following in pgadmin 4
# Copy/Paste result into [Part 2]

SET sql.query = '<multi-line query here>';
--SHOW sql.query; -- Optional: check sql.query value
--SELECT current_setting('sql.query'); -- Optional: check sql.query value as variable
SELECT regexp_replace(
	current_setting('sql.query'),
	E'\n',
	' ',
	'g')
;

# Part 2: Extract Query Plan Node Cost
# Run the following in Windows cmd

"C:\Program Files\PostgreSQL\15\bin\psql.exe" ^
-h [host] ^
-p [port] ^
-U [user] ^
-d [database] ^
--pset=pager=off ^
-c "<single_line_query>" | findstr "cost="
