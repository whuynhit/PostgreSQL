SET my.app_hostname = 'rds-identifier.cluster-abc123.us-west-2.rds.amazonaws.com';

SELECT
	split_part(current_setting('my.app_hostname'), '.', 1) AS rds_name,
    current_setting('my.app_hostname') AS rds_endpoint,
    inet_server_addr() AS ip_address,
    CASE
		WHEN split_part(current_setting('my.app_hostname'), '.', 1) SIMILAR TO '%P[0-9][0-9]' THEN 'PRD'
        WHEN split_part(current_setting('my.app_hostname'), '.', 1) SIMILAR TO '%p[0-9][0-9]' THEN 'PRD'
        WHEN split_part(current_setting('my.app_hostname'), '.', 1) SIMILAR TO '%T[0-9][0-9]' THEN 'UAT'
		WHEN split_part(current_setting('my.app_hostname'), '.', 1) SIMILAR TO '%t[0-9][0-9]' THEN 'UAT'
        WHEN split_part(current_setting('my.app_hostname'), '.', 1) SIMILAR TO '%D[0-9][0-9]' THEN 'DEV'
		WHEN split_part(current_setting('my.app_hostname'), '.', 1) SIMILAR TO '%D[0-9]' THEN 'DEV'
		WHEN split_part(current_setting('my.app_hostname'), '.', 1) SIMILAR TO '%d[0-9][0-9]' THEN 'DEV'
        ELSE 'UNKNOWN'
    END AS environment,
	current_setting('server_version')      AS postgres_version,
	datname AS database_name,
	pg_size_pretty(pg_database_size(datname)) AS database_size,
	CASE
	WHEN datname IN ('postgres','rdsadmin') THEN 'System DB'
	ELSE 'User DB'
	END AS database_type
FROM pg_database
WHERE datistemplate = 'false';
