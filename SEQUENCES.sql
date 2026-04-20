-- Copy last value of SEQUENCES
SELECT 'SELECT setval(' || quote_literal(quote_ident(schemaname) || '.' || quote_ident(sequencename)) || 
       ', ' || last_value || ');' 
FROM pg_sequences;

-- Sync with table data: Use this to fix "out of sync" primary keys
SELECT setval('table_name_id_seq', (SELECT MAX(id) FROM table_name));

--Set the current value: The next nextval call will return the value after this number
SELECT setval('my_sequence_name', 100);

--Set the next value directly: By adding false as the third parameter, the next nextval call will return exactly this number
SELECT setval('my_sequence_name', 100, false);
