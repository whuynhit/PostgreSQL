# -----------------------------
# Configuration
# -----------------------------
$PsqlPath     = "D:\Program Files\PostgreSQL\18\bin\psql.exe"
$EndpointFile = "endpoints.txt"
$ErrorLogFile = "D:\failed_endpoints.log"

$DbUser       = "myuser"
$DbPassword   = "mypassword"
$MaintenanceDb = "postgres"

$env:PGPASSWORD = $DbPassword

Remove-Item $ErrorLogFile -ErrorAction SilentlyContinue

$endpoints = Get-Content $EndpointFile | Where-Object { $_.Trim() -ne "" }

# -----------------------------
# SQL snippets
# -----------------------------
$dbListSql = @"
SELECT datname
FROM pg_database
WHERE datallowconn
  AND datname NOT IN ('postgres','rdsadmin','template0','template1')
ORDER BY datname;
"@

$schemaListSql = @"
SELECT nspname
FROM pg_namespace
WHERE nspname NOT LIKE 'pg_%'
  AND nspname <> 'information_schema'
ORDER BY nspname;
"@

# -----------------------------
# Main loop: endpoints
# -----------------------------
foreach ($ep in $endpoints) {

    if ($ep.ToLower() -eq $env:COMPUTERNAME.ToLower() -or
        $ep.ToLower() -eq "$($env:COMPUTERNAME).cmv.com".ToLower()) {
        $epUse = "localhost"
    } else {
        $epUse = $ep
    }

    Write-Host "`n=== Processing endpoint: $epUse ==="

    try {
        # -----------------------------
        # Get databases
        # -----------------------------
        $databases = & $PsqlPath `
            "host=$epUse user=$DbUser dbname=$MaintenanceDb connect_timeout=5" `
            -t -A `
            -c $dbListSql 2>&1

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to list databases. Output: $databases"
        }

        $databases = $databases | Where-Object { $_ -ne "" }

        foreach ($db in $databases) {

            Write-Host "  Database: $db"

            $roRole = "${db}_ro"
            $rwRole = "${db}_rw"

            # -----------------------------
            # Create roles + DB grants
            # -----------------------------
            $dbLevelSql = @"
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$roRole') THEN
        CREATE ROLE $roRole;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$rwRole') THEN
        CREATE ROLE $rwRole;
    END IF;
END
\$\$;

GRANT CONNECT ON DATABASE $db TO $roRole;
GRANT CONNECT ON DATABASE $db TO $rwRole;
"@

            & $PsqlPath `
                "host=$epUse user=$DbUser dbname=$MaintenanceDb connect_timeout=5" `
                -v ON_ERROR_STOP=1 `
                -c $dbLevelSql 2>&1

            if ($LASTEXITCODE -ne 0) {
                throw "Failed DB-level grants for $db"
            }

            # -----------------------------
            # Get schemas
            # -----------------------------
            $schemas = & $PsqlPath `
                "host=$epUse user=$DbUser dbname=$db connect_timeout=5" `
                -t -A `
                -c $schemaListSql 2>&1

            if ($LASTEXITCODE -ne 0) {
                throw "Failed schema list for $db"
            }

            $schemas = $schemas | Where-Object { $_ -ne "" }

            # -----------------------------
            # Schema-level grants
            # -----------------------------
            foreach ($schema in $schemas) {

                Write-Host "    Schema: $schema"

                $schemaSql = @"
-- Read-only role
GRANT USAGE ON SCHEMA $schema TO $roRole;
GRANT SELECT ON ALL TABLES IN SCHEMA $schema TO $roRole;
ALTER DEFAULT PRIVILEGES IN SCHEMA $schema
GRANT SELECT ON TABLES TO $roRole;

-- Read/Write role
GRANT USAGE ON SCHEMA $schema TO $rwRole;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA $schema TO $rwRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA $schema TO $rwRole;
ALTER DEFAULT PRIVILEGES IN SCHEMA $schema
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $rwRole;
"@

                & $PsqlPath `
                    "host=$epUse user=$DbUser dbname=$db connect_timeout=5" `
                    -v ON_ERROR_STOP=1 `
                    -c $schemaSql 2>&1

                if ($LASTEXITCODE -ne 0) {
                    throw "Failed schema grants for $db.$schema"
                }
            }
        }
    }
    catch {
        Write-Warning "Endpoint failed: $epUse"
        "$epUse - $($_.Exception.Message)" |
            Out-File -Append -Encoding utf8 $ErrorLogFile
        continue
    }
}

Remove-Item Env:PGPASSWORD

Write-Host "`nDone."
Write-Host "Failed endpoints logged to $ErrorLogFile"
