CREATE SCHEMA IF NOT EXISTS  test;

-- Sample Fake PII Table
CREATE TABLE IF NOT EXISTS test.customers (
    customer_id  serial PRIMARY KEY,
    first_name   text,
    last_name    text,
    email        text,
    phone        text,
    ssn          text,
    birth_date   date,
    zip_code     text
);

-- Sample Fake PII Data
INSERT INTO test.customers (
    first_name, last_name, email, phone, ssn, birth_date, zip_code
) VALUES
('John', 'Smith', 'john.smith@gmail.com', '213-555-0198', '123-45-6789', '1985-04-12', '90001'),
('Mary', 'Johnson', 'mary.johnson@yahoo.com', '310-555-0147', '987-65-4321', '1990-11-03', '10001'),
('Robert', 'Williams', 'robert.williams@outlook.com', '415-555-0172', '456-78-9012', '1978-06-25', '60601'),
('Patricia', 'Brown', 'patricia.brown@gmail.com', '212-555-0133', '321-54-9876', '1995-02-18', '73301'),
('Michael', 'Jones', 'michael.jones@gmail.com', '305-555-0199', '654-32-1098', '1982-09-30', '33101'),
('Linda', 'Garcia', 'linda.garcia@yahoo.com', '619-555-0188', '789-12-3456', '1975-12-05', '92101'),
('William', 'Miller', 'william.miller@outlook.com', '702-555-0166', '147-25-3698', '1988-07-14', '85001'),
('Elizabeth', 'Davis', 'elizabeth.davis@gmail.com', '512-555-0111', '258-36-1479', '1993-03-22', '73344'),
('David', 'Rodriguez', 'david.rodriguez@gmail.com', '305-555-0155', '369-47-2581', '1980-10-10', '33130'),
('Barbara', 'Martinez', 'barbara.martinez@yahoo.com', '213-555-0122', '741-85-9632', '1998-08-08', '90011');

-- JOIN Test Dataset (Important for Validation)
-- This verifies deterministic behavior
-- Create 2nd sample table
CREATE TABLE IF NOT EXISTS test.orders (
    order_id serial PRIMARY KEY,
    customer_email text,
    amount numeric
);

-- Create 2nd sample data
INSERT INTO test.orders (customer_email, amount) VALUES
('john.smith@gmail.com', 120.50),
('mary.johnson@yahoo.com', 89.99),
('robert.williams@outlook.com', 42.00),
('patricia.brown@gmail.com', 310.10),
('michael.jones@gmail.com', 18.75);

/*
-- Full Table-Level Masking (Overwrite Pattern)
-- If you want to permanently mask data:
UPDATE test.customers
SET
    test.first_name = mask.first_name(first_name),
    test.last_name  = mask.last_name(last_name),
    test.email      = mask.email(email),
    test.phone      = mask.phone(phone),
    test.ssn        = mask.ssn(ssn),
    test.birth_date = mask.dob(birth_date),
    test.zip_code   = mask.zip(zip_code);
*/

-- Example Masking Test Query
-- See data_mask_function_hmac.sql
-- See data_mask_function_sha512.sql
SELECT
    customer_id,
    mask.first_name(tc.first_name) AS masked_first_name,
    mask.last_name(tc.last_name)   AS masked_last_name,
    mask.email(tc.email)           AS masked_email,
    mask.phone(tc.phone)           AS masked_phone,
    mask.ssn(tc.ssn)               AS masked_ssn,
    mask.dob(tc.birth_date)        AS masked_birth_date,
    mask.zip(tc.zip_code)          AS masked_zip
FROM test.customers tc;

-- Test deterministic join after masking:
SELECT
    o.order_id,
    o.amount,
    mask.email(o.customer_email) AS masked_email,
    c.customer_id
FROM test.orders o
JOIN test.customers c
    ON mask.email(o.customer_email) = mask.email(c.email);
