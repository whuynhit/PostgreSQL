--TEMPLATE
--Create Read-only role for $databaseName db and assign Read-only permissions in public schema
CREATE ROLE $databaseName_ro;
GRANT CONNECT ON DATABASE $databaseName TO $databaseName_ro;
GRANT USAGE ON SCHEMA public TO $databaseName_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $databaseName_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO $databaseName_ro;

-- Grants Read-only permissions to $customSchema schema from $databaseName db
GRANT USAGE ON SCHEMA $customSchema TO $databaseName_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA $customSchema TO $databaseName_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA $customSchema
GRANT SELECT ON TABLES TO $databaseName_ro;


--Create Read/Write role for $databaseName db
CREATE ROLE $databaseName_rw;
GRANT CONNECT ON DATABASE $databaseName TO $databaseName_rw;
GRANT USAGE ON SCHEMA public TO $databaseName_rw;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO $databaseName_rw;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $databaseName_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $databaseName_rw;

-- Grants Read/Write permissions to $customSchema schema from $databaseName db
GRANT USAGE ON SCHEMA $customSchema TO $databaseName_rw;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA $customSchema TO $databaseName_rw;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA $customSchema TO $databaseName_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA $customSchema
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $databaseName_rw;
