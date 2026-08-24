-- Convert Single-Line Comment (--) to Multi-Line Comment (/*...*/)
-- 1. Set your input query using dollar quoting ($SQL$)
SET util.query = $SQL$
SELECT id, name -- Fetch primary user keys
-- Test comment - customer_list is a view
FROM customer_list
WHERE notes = 'active' AND country = 'Japan'; -- Filter out deactivated accounts
$SQL$;

-- 2. Run the conversion script
DO $$
DECLARE
    input_query text := current_setting('util.query', true);
    output_query text;
BEGIN
    -- Regex explanation:
    -- (--+) matches the double dashes
    -- ([^\n]*) matches everything following them up to the newline
    -- \/\* \2 \*\/ wraps the matched comment group in /* ... */
    output_query := regexp_replace(
        input_query, 
        '--+([^\n]*)', 
        '/*\1 */', 
        'g'
    );
    
    -- Raise a notice or store it for verification
    RAISE NOTICE 'Converted Query:%', chr(10) || output_query;
END $$;
