-- Grant Connect Database to db_monitor role (inherits from pg_monitor) for all databases except template0, template1, rdsadmin
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT datname
        FROM pg_database
        WHERE datname NOT IN ('template0', 'template1', 'rdsadmin')
    LOOP
        EXECUTE format(
            'GRANT CONNECT ON DATABASE %I TO db_monitor',
            r.datname
        );
    END LOOP;
END
$$;
