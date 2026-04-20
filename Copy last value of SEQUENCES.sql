-- Copy last value of SEQUENCES
SELECT 'SELECT setval(' || quote_literal(quote_ident(schemaname) || '.' || quote_ident(sequencename)) || 
       ', ' || last_value || ');' 
FROM pg_sequences;
