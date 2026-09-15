-- List roles and their comment description 
SELECT
r.rolname,
CASE
WHEN r.rolname ~ 'pg_' THEN
format($$COMMENT ON ROLE %1$I IS 'SYSTEM DEFAULT ROLE';$$,
r.rolname
)
ELSE
format($$COMMENT ON ROLE %1$I IS 'insert comment here';$$,
r.rolname
) 
END ASadd_comment,
d.description
FROM pg_roles r
LEFT JOIN pg_shdescription d 
ON r.oid = d.objoid
ORDER BY rolname;
