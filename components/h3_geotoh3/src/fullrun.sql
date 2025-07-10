-- H3 Geo to H3 Index Component
-- Converts geographic coordinates to H3 index using the H3 library

-- Create the H3 geoToH3 function
CREATE TEMP FUNCTION geoToH3(lat FLOAT64, lng FLOAT64, res INT64)
RETURNS STRING
LANGUAGE js
OPTIONS (
    library = ["gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_h3.js"]
)
AS r"""
    if (lat === null || lng === null || res === null) {
        return null;
    }
    return h3Lib.geoToH3(lat, lng, res);
""";

-- Create the output table with H3 index column
EXECUTE IMMEDIATE '''
CREATE TABLE IF NOT EXISTS ''' || output_table || '''
OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
AS SELECT *, 
    geoToH3(CAST(''' || latitude_column || ''' AS FLOAT64), 
            CAST(''' || longitude_column || ''' AS FLOAT64), 
            ''' || resolution || ''') AS ''' || output_column_name || '''
FROM ''' || input_table || ''';
'''; 