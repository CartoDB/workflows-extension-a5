-- A5 Cell to Boundary Component
-- Returns the vertices that define the boundary of an A5 cell using the A5 library

-- Create the A5 cellToBoundary function
CREATE TEMP FUNCTION cellToBoundary(cell STRING)
RETURNS STRING
LANGUAGE js
OPTIONS (
    library = ["gs://carto-workflows-extension-a5/a5.umd.js"]
)
AS r"""
    if (cell === null) {
        return null;
    }
    
    const options = { closedRing: true, segments: 'auto' };
    try {
        const boundary = A5.cellToBoundary(BigInt(cell), options);
        return JSON.stringify(boundary);
    } catch (error) {
        return null;
    }
""";

-- Create the output table with A5 cell boundary coordinates column
EXECUTE IMMEDIATE '''
CREATE TABLE IF NOT EXISTS ''' || output_table || '''
OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
AS SELECT *, 
    cellToBoundary(CAST(''' || cell_column || ''' AS STRING), 
                   ''' || closed_ring || ''', 
                   ''' || segments || ''') AS ''' || output_column_name || '''
FROM ''' || input_table || ''';
'''; 