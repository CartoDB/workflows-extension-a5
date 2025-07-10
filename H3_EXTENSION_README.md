# H3 Geospatial Extension for CARTO Workflows

This extension provides H3 geospatial indexing functions for BigQuery through CARTO Workflows. It wraps the H3 library to enable conversion of geographic coordinates to H3 indices.

## Components

### H3 Geo to H3 Index (`h3_geotoh3`)

Converts geographic coordinates (latitude, longitude) to H3 index at a specified resolution.

**Inputs:**
- **Input table**: Table containing latitude and longitude columns
- **Latitude column**: Column with latitude values (decimal degrees)
- **Longitude column**: Column with longitude values (decimal degrees)
- **Resolution**: H3 resolution (0-15, where 0 is coarsest and 15 is finest)
- **Output column name**: Name for the output H3 index column (default: "h3_index")

**Outputs:**
- **Output table**: Input table with additional H3 index column

## Library Integration

The extension uses the H3 library hosted at:
```
gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_h3.js
```

The component creates a BigQuery JavaScript UDF that wraps the `h3Lib.geoToH3()` function:

```sql
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
```

## H3 Resolution Levels

| Resolution | Average Hexagon Edge Length | Average Hexagon Area |
|------------|----------------------------|---------------------|
| 0          | 110.7 km                   | 4,250,547.17 km²    |
| 1          | 41.8 km                    | 607,221.02 km²      |
| 2          | 15.8 km                    | 86,745.86 km²       |
| 3          | 6.0 km                     | 12,392.27 km²       |
| 4          | 2.2 km                     | 1,770.32 km²        |
| 5          | 0.8 km                     | 252.90 km²          |
| 6          | 0.3 km                     | 36.13 km²           |
| 7          | 0.1 km                     | 5.16 km²            |
| 8          | 0.04 km                    | 0.74 km²            |
| 9          | 0.015 km                   | 0.11 km²            |
| 10         | 0.006 km                   | 0.015 km²           |
| 11         | 0.002 km                   | 0.002 km²           |
| 12         | 0.0008 km                  | 0.0003 km²          |
| 13         | 0.0003 km                  | 0.00004 km²         |
| 14         | 0.0001 km                  | 0.000006 km²        |
| 15         | 0.00004 km                 | 0.0000009 km²       |

## Example Usage

Input table:
```
| latitude | longitude | name     |
|----------|-----------|----------|
| 40.7128  | -74.0060  | NYC      |
| 34.0522  | -118.2437 | LA       |
| 51.5074  | -0.1278   | London   |
```

Output table (resolution 9):
```
| latitude | longitude | name     | h3_index        |
|----------|-----------|----------|-----------------|
| 40.7128  | -74.0060  | NYC      | 8928308280fffff |
| 34.0522  | -118.2437 | LA       | 89283082837ffff |
| 51.5074  | -0.1278   | London   | 8928308280fffff |
```

## Testing

The extension includes test fixtures with sample data for validation:

- **Test 1**: Resolution 9 (fine detail)
- **Test 2**: Resolution 2 (coarse detail)

Test data includes coordinates for major cities: New York, Los Angeles, London, Paris, and Tokyo.

## Validation

A validation script (`validate_h3_library.sql`) is included to test:
1. Library loading capability
2. Function availability
3. Actual function execution with sample coordinates

## Installation

1. Ensure you have the CARTO Workflows extension framework set up
2. Deploy the extension to your BigQuery project
3. The component will be available in the CARTO Workflows interface

## References

- [H3 Library Documentation](https://h3geo.org/)
- [H3 Resolution Table](https://h3geo.org/docs/core-library/restable/)
- [CARTO Analytics Toolbox](https://docs.carto.com/analytics-toolbox-bigquery/)
- [CARTO Workflows Extensions](https://docs.carto.com/carto-user-manual/workflows/extension-packages/)

## Development

To modify or extend this extension:

1. Edit the component metadata in `components/h3_geotoh3/metadata.json`
2. Update the SQL logic in `components/h3_geotoh3/src/fullrun.sql` and `dryrun.sql`
3. Modify tests in `components/h3_geotoh3/test/`
4. Update documentation in `components/h3_geotoh3/doc/README.md`
5. Run `python carto_extension.py check` to validate the structure
6. Run `python carto_extension.py test` to test the component
7. Run `python carto_extension.py package` to create a distributable package 