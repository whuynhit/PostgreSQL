-- ============================================================================
-- 1. INITIAL INFRASTRUCTURE SETUP (Run once)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Define the connection to the source database
CREATE SERVER IF NOT EXISTS source_db_link
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5432', dbname 'source_db');

-- Map your destination database user to the source database credentials
CREATE USER MAPPING IF NOT EXISTS FOR current_user
SERVER source_db_link
OPTIONS (user 'your_source_username', password 'your_source_password');

-- ============================================================================
-- 2. CREATE A LINK TO THE SOURCE TABLE
-- ============================================================================
-- Create a dedicated local staging schema to hold the foreign definition.
-- This ensures the foreign table definition doesn't conflict with your actual table.
CREATE SCHEMA IF NOT EXISTS fdw_staging;

-- Clear any old definitions if you've run this before
DROP FOREIGN TABLE IF EXISTS fdw_staging.source_table_link;

-- Import the remote table metadata directly into your staging schema
IMPORT FOREIGN SCHEMA source_schema
LIMIT TO (identical_table)
FROM SERVER source_db_link
INTO fdw_staging;

-- Rename the mapped table locally so its purpose is clear
ALTER FOREIGN TABLE fdw_staging.identical_table 
RENAME TO source_table_link;

-- ============================================================================
-- 3. THE TRANSFER DATA EXECUTABLE (Run whenever you need to sync)
-- ============================================================================
-- This copies data cleanly from the source database link into your existing table
INSERT INTO target_schema.identical_table
SELECT * FROM fdw_staging.source_table_link;
