-- Validation script for A5 library
-- This script tests if the A5 library can be loaded and the lonLatToCell function works

-- Test 1: Basic library loading
CREATE TEMP FUNCTION test_library_load()
RETURNS STRING
LANGUAGE js
OPTIONS (library = ['gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_a5.js'])
AS r"""
  return 'Library loaded successfully';
""";

-- Test 2: Function availability
CREATE TEMP FUNCTION test_function_availability()
RETURNS STRING
LANGUAGE js
OPTIONS (library = ['gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_a5.js'])
AS r"""
  try {
    if (typeof a5Lib.lonLatToCell === 'function') {
      return 'lonLatToCell function available';
    } else {
      return 'lonLatToCell function not found in library';
    }
  } catch (error) {
    return 'Error: ' + error.message;
  }
""";

-- Test 3: Actual function call
CREATE TEMP FUNCTION test_lonLatToCell(lng FLOAT64, lat FLOAT64, res INT64)
RETURNS STRING
LANGUAGE js
OPTIONS (library = ['gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_a5.js'])
AS r"""
  if (lng === null || lat === null || res === null) {
    return null;
  }
  const coordinate = [lng, lat];
  const result = a5Lib.lonLatToCell(coordinate, res);
  return result.toString();
""";

-- Execute tests
SELECT 'Library Load Test' as test_name, test_library_load() as result
UNION ALL
SELECT 'Function Availability Test' as test_name, test_function_availability() as result
UNION ALL
SELECT 'lonLatToCell Test (NYC, res=9)' as test_name, test_lonLatToCell(-74.0060, 40.7128, 9) as result
UNION ALL
SELECT 'lonLatToCell Test (LA, res=2)' as test_name, test_lonLatToCell(-118.2437, 34.0522, 2) as result; 