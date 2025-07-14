-- A5 Cell to Center Component
-- Returns the geospatial coordinate at the center of an A5 cell using the A5 library

-- Create the A5 cellToLonLat function
CREATE TEMP FUNCTION cellToLonLat(cell STRING)
RETURNS STRING
LANGUAGE js
OPTIONS (
    library = ["gs://carto-workflows-extension-a5/a5.umd.js"]
)
AS r"""
    if (cell === null) {
        return null;
    }
    try {
        const center = A5.cellToLonLat(A5.hexToBigInt(cell));
        return 'POINT(' + center[0] + ' ' + center[1] + ')';
    } catch (error) {
        return null;
    }
""";

-- Create the output table with A5 cell center coordinate column
EXECUTE IMMEDIATE '''
CREATE TABLE IF NOT EXISTS ''' || output_table || '''
OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
AS SELECT *, 
    cellToLonLat(CAST(''' || cell_column || ''' AS STRING)) AS ''' || output_column_name || '''
FROM ''' || input_table || ''';
'''; 