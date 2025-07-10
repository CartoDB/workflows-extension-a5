DECLARE procedures STRING;
DECLARE proceduresArray ARRAY<STRING>;
DECLARE i INT64 DEFAULT 0;

CREATE TABLE IF NOT EXISTS @@workflows_temp@@.WORKFLOWS_EXTENSIONS (
    name STRING,
    metadata STRING,
    procedures STRING
);

-- remove procedures from previous installations

SET procedures = (
    SELECT procedures
    FROM @@workflows_temp@@.WORKFLOWS_EXTENSIONS
    WHERE name = 'geospatial-extension'
);
IF (procedures IS NOT NULL) THEN
    SET proceduresArray = SPLIT(procedures, ',');
    LOOP
        SET i = i + 1;
        IF i > ARRAY_LENGTH(proceduresArray) THEN
            LEAVE;
        END IF;
        EXECUTE IMMEDIATE 'DROP PROCEDURE @@workflows_temp@@.' || proceduresArray[ORDINAL(i)];
    END LOOP;
END IF;

DELETE FROM @@workflows_temp@@.WORKFLOWS_EXTENSIONS
WHERE name = 'geospatial-extension';

-- create procedures

CREATE OR REPLACE PROCEDURE @@workflows_temp@@.`__proc_template_79081302`(
    input_table STRING,
    value STRING,
    output_table STRING,
    dry_run BOOLEAN,
    env_vars STRING
)
BEGIN
    DECLARE __parsed JSON default PARSE_JSON(env_vars);
    IF (dry_run) THEN
        BEGIN
        -- This is the sample code for the BigQuery dryrun.
        -------------------------------------------------------
        EXECUTE IMMEDIATE '''
        CREATE TABLE IF NOT EXISTS ''' || output_table || '''
        OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
        AS SELECT *, \'''' || value || '''\' AS fixed_value_col
        FROM ''' || input_table || '''
        WHERE 1 = 0;
        ''';
        -- This is the sample code for the Snowflake dryrun.
        ---------------------------------------------------------
        /*
        EXECUTE IMMEDIATE '
        CREATE TABLE IF NOT EXISTS ' || :output_table || '
        AS SELECT *, ''' || :value || ''' AS fixed_value_col
        FROM ' || :input_table || '
        WHERE 1 = 0;
        ';
        */
        END;
    ELSE
        BEGIN
        -- This is the sample code for the BigQuery fullrun.
        -------------------------------------------------------
        EXECUTE IMMEDIATE '''
        CREATE TABLE IF NOT EXISTS ''' || output_table || '''
        OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
        AS SELECT *, \'''' || value || '''\' AS fixed_value_col
        FROM ''' || input_table;
        -- This is the sample code for the Snowflake fullrun.
        ---------------------------------------------------------
        /*
        EXECUTE IMMEDIATE '
        CREATE TABLE IF NOT EXISTS ' || :output_table || '
        AS SELECT *, ''' || :value || ''' AS fixed_value_col
        FROM ' || :input_table ;
        */
        END;
    END IF;
END;
CREATE OR REPLACE PROCEDURE @@workflows_temp@@.`__proc_h3_geotoh3_59060835`(
    input_table STRING,
    latitude_column STRING,
    longitude_column STRING,
    resolution FLOAT64,
    output_column_name STRING,
    output_table STRING,
    dry_run BOOLEAN,
    env_vars STRING
)
BEGIN
    DECLARE __parsed JSON default PARSE_JSON(env_vars);
    IF (dry_run) THEN
        BEGIN
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
        END;
    ELSE
        BEGIN
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
        END;
    END IF;
END;
CREATE OR REPLACE PROCEDURE @@workflows_temp@@.`__proc_a5_lonlattocell_70297858`(
    input_table STRING,
    longitude_column STRING,
    latitude_column STRING,
    resolution FLOAT64,
    output_column_name STRING,
    output_table STRING,
    dry_run BOOLEAN,
    env_vars STRING
)
BEGIN
    DECLARE __parsed JSON default PARSE_JSON(env_vars);
    IF (dry_run) THEN
        BEGIN
        -- A5 Longitude Latitude to Cell Component - Dry Run
        -- Creates the output schema without executing the A5 function
        EXECUTE IMMEDIATE '''
        CREATE TABLE IF NOT EXISTS ''' || output_table || '''
        OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
        AS SELECT *, 
            "a5_cell_string" AS ''' || output_column_name || '''
        FROM ''' || input_table || '''
        WHERE 1 = 0;
        '''; 
        END;
    ELSE
        BEGIN
        -- A5 Longitude Latitude to Cell Component
        -- Converts geographic coordinates to A5 cell index using the A5 library
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
            return A5.lonLatToCell([lng, lat], res);
        """;
        -- Create the output table with A5 cell index column
        EXECUTE IMMEDIATE '''
        CREATE TABLE IF NOT EXISTS ''' || output_table || '''
        OPTIONS (expiration_timestamp = TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
        AS SELECT *, 
            lonLatToCell(CAST(''' || longitude_column || ''' AS FLOAT64), 
                         CAST(''' || latitude_column || ''' AS FLOAT64), 
                         ''' || resolution || ''') AS ''' || output_column_name || '''
        FROM ''' || input_table || ''';
        '''; 
        END;
    END IF;
END;

-- add to extensions table

INSERT INTO @@workflows_temp@@.WORKFLOWS_EXTENSIONS (name, metadata, procedures)
VALUES ('geospatial-extension', '''{"name": "geospatial-extension", "title": "Geospatial Indexing Extension", "industry": "Geospatial", "description": "Extension providing H3 and A5 geospatial indexing functions for BigQuery", "icon": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAiIGhlaWdodD0iODAiIHZpZXdCb3g9IjAgMCA4MCA4MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggb3BhY2l0eT0iMC44IiBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTMzLjMzMzMgMzBDMzEuNDkyNCAzMCAzMCAzMS40OTI0IDMwIDMzLjMzMzNWNjYuNjY2N0MzMCA2OC41MDc2IDMxLjQ5MjQgNzAgMzMuMzMzMyA3MEg2Ni42NjY3QzY4LjUwNzYgNzAgNzAgNjguNTA3NiA3MCA2Ni42NjY3VjMzLjMzMzNDNzAgMzEuNDkyNCA2OC41MDc2IDMwIDY2LjY2NjcgMzBIMzMuMzMzM1pNNTAgNjVDNTguMjg0MyA2NSA2NSA1OC4yODQzIDY1IDUwQzY1IDQxLjcxNTcgNTguMjg0MyAzNSA1MCAzNUM0MS43MTU3IDM1IDM1IDQxLjcxNTcgMzUgNTBDMzUgNTguMjg0MyA0MS43MTU3IDY1IDUwIDY1WiIgZmlsbD0iIzAzNkZFMiIvPgo8cGF0aCBkPSJNNDguOTgzNiA2MS42NjY3VjUyLjVMNTEuMjUwMiA0Ny41SDU2LjI1MDJMNDguOTgzNiA2MS42NjY3WiIgZmlsbD0iIzAyNEQ5RSIvPgo8cGF0aCBkPSJNNDMuNzUgNTIuNTAwN0w1MS4yNSAzOC4zMzRWNDcuNTAwN0w0OC45ODMzIDUyLjUwMDdINDMuNzVaIiBmaWxsPSIjMDM2RkUyIi8+CjxwYXRoIG9wYWNpdHk9IjAuMyIgZD0iTTEzLjMzMzMgMTBDMTEuNDkyNCAxMCAxMCAxMS40OTI0IDEwIDEzLjMzMzNWNDYuNjY2N0MxMCA0OC41MDc2IDExLjQ5MjQgNTAgMTMuMzMzMyA1MEgyMFYyMy4zMzMzQzIwIDIxLjQ5MjQgMjEuNDkyNCAyMCAyMy4zMzMzIDIwSDUwVjEzLjMzMzNDNTAgMTEuNDkyNCA0OC41MDc2IDEwIDQ2LjY2NjcgMTBIMTMuMzMzM1oiIGZpbGw9IiMwMzZGRTIiLz4KPHBhdGggb3BhY2l0eT0iMC41IiBkPSJNMjMuMzMzMyAyMEMyMS40OTI0IDIwIDIwIDIxLjQ5MjQgMjAgMjMuMzMzM1Y1Ni42NjY3QzIwIDU4LjUwNzYgMjEuNDkyNCA2MCAyMy4zMzMzIDYwSDMwVjMzLjMzMzNDMzAgMzEuNDkyNCAzMS40OTI0IDMwIDMzLjMzMzMgMzBINjBWMjMuMzMzM0M2MCAyMS40OTI0IDU4LjUwNzYgMjAgNTYuNjY2NyAyMEgyMy4zMzMzWiIgZmlsbD0iIzAzNkZFMiIvPgo8L3N2Zz4K", "version": "1.0.0", "lastUpdate": "2024-01-31", "provider": "bigquery", "author": {"value": "CARTO", "link": {"label": "CARTO", "href": "https://carto.com"}}, "license": {"value": "CARTO Proprietary", "link": {"label": "CARTO Proprietary", "href": "https://carto.com/legal"}}, "details": [{"name": "Optional detail", "link": {"label": "Whatever", "href": "https://carto.com/"}}], "components": [{"name": "template", "title": "Fixed value column", "description": "This component adds a fixed value column to a table", "version": "1.0.0", "icon": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggb3BhY2l0eT0iMC4yIiBkPSJNMzUgMjBDMzUgMjguMjg0MyAyOC4yODQzIDM1IDIwIDM1QzExLjcxNTcgMzUgNSAyOC4yODQzIDUgMjBDNSAxMS43MTU3IDExLjcxNTcgNSAyMCA1QzI4LjI4NDMgNSAzNSAxMS43MTU3IDM1IDIwWiIgZmlsbD0iIzAzNkZFMiIvPgo8cGF0aCBkPSJNMTguOTgzNCAzMS42NjY3VjIyLjVMMjEuMjUgMTcuNUgyNi4yNUwxOC45ODM0IDMxLjY2NjdaIiBmaWxsPSIjMDI0RDlFIi8+CjxwYXRoIGQ9Ik0xMy43NSAyMi41MDA3TDIxLjI1IDguMzMzOThWMTcuNTAwN0wxOC45ODMzIDIyLjUwMDdIMTMuNzVaIiBmaWxsPSIjMDM2RkUyIi8+Cjwvc3ZnPgo=", "cartoEnvVars": [], "inputs": [{"name": "input_table", "title": "Input table", "description": "The table to add the column to", "type": "Table"}, {"name": "value", "title": "Column value", "description": "The value to add to the column", "type": "String", "mode": "multiline", "placeholder": "The value\\nto add to the column"}], "outputs": [{"name": "output_table", "title": "Output table", "description": "The table with the column added", "type": "Table"}], "group": "Geospatial Indexing Extension", "procedureName": "__proc_template_79081302"}, {"name": "h3_geotoh3", "title": "H3 Geo to H3 Index", "description": "Converts geographic coordinates (latitude, longitude) to H3 index at specified resolution using the H3 library", "version": "1.0.0", "icon": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggb3BhY2l0eT0iMC4yIiBkPSJNMzUgMjBDMzUgMjguMjg0MyAyOC4yODQzIDM1IDIwIDM1QzExLjcxNTcgMzUgNSAyOC4yODQzIDUgMjBDNSAxMS43MTU3IDExLjcxNTcgNSAyMCA1QzI4LjI4NDMgNSAzNSAxMS43MTU3IDM1IDIwWiIgZmlsbD0iIzAzNkZFMiIvPgo8cGF0aCBkPSJNMTguOTgzNCAzMS42NjY3VjIyLjVMMjEuMjUgMTcuNUgyNi4yNUwxOC45ODM0IDMxLjY2NjdaIiBmaWxsPSIjMDI0RDlFIi8+CjxwYXRoIGQ9Ik0xMy43NSAyMi41MDA3TDIxLjI1IDguMzMzOThWMTcuNTAwN0wxOC45ODMzIDIyLjUwMDdIMTMuNzVaIiBmaWxsPSIjMDM2RkUyIi8+Cjwvc3ZnPgo=", "cartoEnvVars": [], "inputs": [{"name": "input_table", "title": "Input table", "description": "The table containing latitude and longitude columns", "type": "Table"}, {"name": "latitude_column", "title": "Latitude column", "description": "The column containing latitude values (decimal degrees)", "type": "Column", "parent": "input_table", "dataType": ["float64", "int64", "numeric"]}, {"name": "longitude_column", "title": "Longitude column", "description": "The column containing longitude values (decimal degrees)", "type": "Column", "parent": "input_table", "dataType": ["float64", "int64", "numeric"]}, {"name": "resolution", "title": "H3 resolution", "description": "The H3 resolution (0-15, where 0 is coarsest and 15 is finest)", "type": "Number", "min": 0, "max": 15, "default": 9}, {"name": "output_column_name", "title": "Output column name", "description": "Name for the output H3 index column", "type": "String", "default": "h3_index", "placeholder": "h3_index"}], "outputs": [{"name": "output_table", "title": "Output table", "description": "The table with H3 index column added", "type": "Table"}], "group": "Geospatial Indexing Extension", "procedureName": "__proc_h3_geotoh3_59060835"}, {"name": "a5_lonlattocell", "title": "A5 Longitude Latitude to Cell", "description": "Converts geographic coordinates (longitude, latitude) to A5 cell index at specified resolution using the A5 library", "version": "1.0.0", "icon": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggb3BhY2l0eT0iMC4yIiBkPSJNMzUgMjBDMzUgMjguMjg0MyAyOC4yODQzIDM1IDIwIDM1QzExLjcxNTcgMzUgNSAyOC4yODQzIDUgMjBDNSAxMS43MTU3IDExLjcxNTcgNSAyMCA1QzI4LjI4NDMgNSAzNSAxMS43MTU3IDM1IDIwWiIgZmlsbD0iIzAzNkZFMiIvPgo8cGF0aCBkPSJNMTguOTgzNCAzMS42NjY3VjIyLjVMMjEuMjUgMTcuNUgyNi4yNUwxOC45ODM0IDMxLjY2NjdaIiBmaWxsPSIjMDI0RDlFIi8+CjxwYXRoIGQ9Ik0xMy43NSAyMi41MDA3TDIxLjI1IDguMzMzOThWMTcuNTAwN0wxOC45ODMzIDIyLjUwMDdIMTMuNzVaIiBmaWxsPSIjMDM2RkUyIi8+Cjwvc3ZnPgo=", "cartoEnvVars": [], "inputs": [{"name": "input_table", "title": "Input table", "description": "The table containing longitude and latitude columns", "type": "Table"}, {"name": "longitude_column", "title": "Longitude column", "description": "The column containing longitude values (decimal degrees)", "type": "Column", "parent": "input_table", "dataType": ["float64", "int64", "numeric"]}, {"name": "latitude_column", "title": "Latitude column", "description": "The column containing latitude values (decimal degrees)", "type": "Column", "parent": "input_table", "dataType": ["float64", "int64", "numeric"]}, {"name": "resolution", "title": "A5 resolution", "description": "The A5 resolution level to index at", "type": "Number", "min": 0, "max": 20, "default": 9, "step": 0.1}, {"name": "output_column_name", "title": "Output column name", "description": "Name for the output A5 cell index column", "type": "String", "default": "a5_cell", "placeholder": "a5_cell"}], "outputs": [{"name": "output_table", "title": "Output table", "description": "The table with A5 cell index column added", "type": "Table"}], "group": "Geospatial Indexing Extension", "procedureName": "__proc_a5_lonlattocell_70297858"}]}''', '__proc_template_79081302,__proc_h3_geotoh3_59060835,__proc_a5_lonlattocell_70297858');