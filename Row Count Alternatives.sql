-- Hash Aggregate Checksum
SELECT
COUNT(*) AS row_count,
SUM(hashtext(t::text)) AS table_checksum
FROM schema.my_table t;

-- Sample Hash
SELECT
COUNT(*),
SUM(hashtext(t::text))
FROM schema.my_table TABLESAMPLE SYSTEM (1) t;

-- Range Hashing
SELECT
SUM(hashtext(t::text))
FROM schema.my_table t
WHERE id BETWEEN 1 AND 10000000;

-- Checksum on Primary Key & Columns
SELECT
COUNT(*),
SUM(hashtext(id || col1 || col2 || col3))
FROM schema.my_table;
