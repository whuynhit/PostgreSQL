-- Data Masking Functions (HMAC)

-- All functions created here are dependent on functions provided by pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create a separate schema to store mask functions
CREATE SCHEMA IF NOT EXISTS mask;

-- REQUIRED DEPENDENCY (First/Last Name Tables)
-- These are needed for deterministic name substitution.

-- First Name table
CREATE TABLE IF NOT EXISTS mask.first_names (
    id   serial PRIMARY KEY,
    name text NOT NULL UNIQUE
);

-- Example First Name data
INSERT INTO mask.first_names (name) VALUES
('James'), ('Mary'), ('John'), ('Patricia'),
('Robert'), ('Jennifer'), ('Michael'), ('Linda'),
('William'), ('Elizabeth'), ('David'), ('Barbara'),
('Richard'), ('Susan'), ('Joseph'), ('Jessica'),
('Thomas'), ('Sarah'), ('Charles'), ('Karen');

-- Last Name table
CREATE TABLE IF NOT EXISTS mask.last_names (
    id   serial PRIMARY KEY,
    name text NOT NULL UNIQUE
);

-- Example Last Name data
INSERT INTO mask.last_names (name) VALUES
('Smith'), ('Johnson'), ('Williams'), ('Brown'),
('Jones'), ('Garcia'), ('Miller'), ('Davis'),
('Rodriguez'), ('Martinez'), ('Hernandez'), ('Lopez'),
('Gonzalez'), ('Wilson'), ('Anderson'), ('Thomas'),
('Taylor'), ('Moore'), ('Jackson'), ('Martin');


-- Helper function
-- mask_hmac retrieves Secret Key from configuration parameter then hashes column with user-provided secret key
-- Run the following example before running your masking job
-- Example:
-- SET mask.secret = 'your-very-long-random-secret';
--
CREATE OR REPLACE FUNCTION mask.hmac(p_value text)
RETURNS text
LANGUAGE sql
STABLE
STRICT
AS $$
SELECT encode(
    hmac(
        p_value,
        current_setting('mask.secret'),
        'sha512'
    ),
    'hex'
);
$$;

-- Email function
CREATE OR REPLACE FUNCTION mask.email(p_email text)
RETURNS text
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
SELECT lower(substr(mask.hmac(p_email),1,16)) || '@example.test';
$$;

-- Phone function
CREATE OR REPLACE FUNCTION mask.phone(p_phone text)
RETURNS text
LANGUAGE plpgsql
STABLE
STRICT
AS $$
DECLARE
    h text;
    n bigint;
BEGIN
    h := substr(mask.hmac(p_phone),1,15);
    n := ('x' || h)::bit(60)::bigint;

    RETURN
        lpad((200 + (n % 800))::text, 3, '0')
        || '-'
        || lpad(((n / 1000) % 1000)::text, 3, '0')
        || '-'
        || lpad((n % 10000)::text, 4, '0');
END;
$$;

-- SSN function
CREATE OR REPLACE FUNCTION mask.ssn(p_ssn text)
RETURNS text
LANGUAGE plpgsql
STABLE
STRICT
AS $$
DECLARE
    h text;
    n bigint;
BEGIN
    h := substr(mask.hmac(p_ssn),1,15);
    n := ('x' || h)::bit(60)::bigint;

    RETURN
        lpad((100 + (n % 900))::text, 3, '0')
        || '-'
        || lpad((10 + ((n / 1000) % 90))::text, 2, '0')
        || '-'
        || lpad((n % 10000)::text, 4, '0');
END;
$$;

-- ZIP Code function
CREATE OR REPLACE FUNCTION mask.zip(p_zip text)
RETURNS text
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
SELECT lpad(
    (
        (('x'||substr(mask.hmac(p_zip),1,8))::bit(32)::bigint % 90000)
        + 10000
    )::text,
    5,
    '0'
);
$$;

-- First Name function (Requires First Name table)
CREATE OR REPLACE FUNCTION mask.first_name(p_name text)
RETURNS text
LANGUAGE sql
STABLE
STRICT
AS $$
SELECT name
FROM mask.first_names
ORDER BY id
OFFSET (
    (('x'||substr(mask.hmac(p_name),1,8))::bit(32)::bigint)
    % (SELECT count(*) FROM mask.first_names)
)
LIMIT 1;
$$;

-- Last Name function (Requires Last Name table)
CREATE OR REPLACE FUNCTION mask.last_name(p_name text)
RETURNS text
LANGUAGE sql
STABLE
STRICT
AS $$
SELECT name
FROM mask.last_names
ORDER BY id
OFFSET (
    (('x'||substr(mask.hmac(p_name),1,8))::bit(32)::bigint)
    % (SELECT count(*) FROM mask.last_names)
)
LIMIT 1;
$$;

-- Full Name function
CREATE OR REPLACE FUNCTION mask.full_name(p_first text, p_last text)
RETURNS text
LANGUAGE sql
STABLE
STRICT
AS $$
SELECT mask.first_name(p_first) || ' ' || mask.last_name(p_last);
$$;

-- Date of Birth function
CREATE OR REPLACE FUNCTION mask.dob(p_dob date)
RETURNS date
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
SELECT p_dob +
(
    (
        ('x'||substr(mask.hmac(p_dob::text),1,8))::bit(32)::bigint % 3650
    ) - 1825
)::int;
$$;
