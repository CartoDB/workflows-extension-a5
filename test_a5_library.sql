-- Test script for the new A5 library integration
-- Tests the updated library URL and A5.fun() syntax

-- Test the A5 lonLatToCell function with new library
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

-- Test with sample coordinates
SELECT 
    'New York' as city,
    -74.0060 as longitude,
    40.7128 as latitude,
    9.0 as resolution,
    lonLatToCell(-74.0060, 40.7128, 9.0) as a5_cell
UNION ALL
SELECT 
    'Los Angeles' as city,
    -118.2437 as longitude,
    34.0522 as latitude,
    2.0 as resolution,
    lonLatToCell(-118.2437, 34.0522, 2.0) as a5_cell
UNION ALL
SELECT 
    'London' as city,
    -0.1278 as longitude,
    51.5074 as latitude,
    5.5 as resolution,
    lonLatToCell(-0.1278, 51.5074, 5.5) as a5_cell; 