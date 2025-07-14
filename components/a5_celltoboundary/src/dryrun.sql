-- A5 Cell to Boundary Component - Dry Run
-- Creates the output schema without executing the A5 function

EXECUTE IMMEDIATE '''
CREATE TABLE IF NOT EXISTS ''' || output_table || '''
OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
AS SELECT *, 
    "boundary_coordinates_json" AS ''' || output_column_name || '''
FROM ''' || input_table || '''
WHERE 1 = 0;
'''; 