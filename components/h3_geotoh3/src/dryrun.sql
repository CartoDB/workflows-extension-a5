-- H3 Geo to H3 Index Component - Dry Run
-- Creates the output schema without executing the H3 function

EXECUTE IMMEDIATE '''
CREATE TABLE IF NOT EXISTS ''' || output_table || '''
OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
AS SELECT *, 
    "h3_index_string" AS ''' || output_column_name || '''
FROM ''' || input_table || '''
WHERE 1 = 0;
'''; 