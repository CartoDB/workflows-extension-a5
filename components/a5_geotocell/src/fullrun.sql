-- A5 Geography to Cell Component
-- Converts a GEOGRAPHY column to an A5 cell index using the A5 library

-- Create the A5 lonLatToCell function
CREATE TEMP FUNCTION lonLatToCell(lng FLOAT64, lat FLOAT64, res FLOAT64)
RETURNS STRING
LANGUAGE js
OPTIONS (
    library = ["gs://carto-workflows-extension-a5/a5.umd.js"]
)
AS r"""
    if (lng === null || lat === null || res === null) {
        return null;
    }
    return A5.bigIntToHex(A5.lonLatToCell([lng, lat], res));
""";

-- Create the output table with A5 cell index column
EXECUTE IMMEDIATE '''
CREATE TABLE IF NOT EXISTS ''' || output_table || '''
OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
AS SELECT *, 
    lonLatToCell(ST_X(''' || geo_column || '''), ST_Y(''' || geo_column || '''), ''' || resolution || ''') AS ''' || output_column_name || '''
FROM ''' || input_table || ''';
'''; 