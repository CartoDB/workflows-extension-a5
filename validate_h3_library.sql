-- Validation script for H3 library
-- This script tests if the H3 library can be loaded and the geoToH3 function works

-- Test 1: Basic library loading
CREATE TEMP FUNCTION test_library_load()
RETURNS STRING
LANGUAGE js
OPTIONS (library = ['gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_h3.js'])
AS r"""
  return 'Library loaded successfully';
""";

-- Test 2: Function availability
CREATE TEMP FUNCTION test_function_availability()
RETURNS STRING
LANGUAGE js
OPTIONS (library = ['gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_h3.js'])
AS r"""
  try {
    if (typeof h3Lib.geoToH3 === 'function') {
      return 'geoToH3 function available';
    } else {
      return 'geoToH3 function not found in library';
    }
  } catch (error) {
    return 'Error: ' + error.message;
  }
""";

-- Test 3: Actual function call
CREATE TEMP FUNCTION test_geoToH3(lat FLOAT64, lng FLOAT64, res INT64)
RETURNS STRING
LANGUAGE js
OPTIONS (library = ['gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_h3.js'])
AS r"""
  if (lat === null || lng === null || res === null) {
    return null;
  }
  return h3Lib.geoToH3(lat, lng, res);
""";

-- Execute tests
SELECT 'Library Load Test' as test_name, test_library_load() as result
UNION ALL
SELECT 'Function Availability Test' as test_name, test_function_availability() as result
UNION ALL
SELECT 'geoToH3 Test (NYC, res=9)' as test_name, test_geoToH3(40.7128, -74.0060, 9) as result
UNION ALL
SELECT 'geoToH3 Test (LA, res=2)' as test_name, test_geoToH3(34.0522, -118.2437, 2) as result; 