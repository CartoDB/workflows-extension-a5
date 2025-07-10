# Geospatial Indexing Extension for CARTO Workflows

This extension provides both H3 and A5 geospatial indexing functions for BigQuery through CARTO Workflows. It wraps the H3 and A5 libraries to enable conversion of geographic coordinates to geospatial indices.

## Components

### 1. H3 Geo to H3 Index (`h3_geotoh3`)

Converts geographic coordinates (latitude, longitude) to H3 index at a specified resolution.

**Inputs:**
- **Input table**: Table containing latitude and longitude columns
- **Latitude column**: Column with latitude values (decimal degrees)
- **Longitude column**: Column with longitude values (decimal degrees)
- **Resolution**: H3 resolution (0-15, where 0 is coarsest and 15 is finest)
- **Output column name**: Name for the output H3 index column (default: "h3_index")

**Outputs:**
- **Output table**: Input table with additional H3 index column

### 2. A5 Longitude Latitude to Cell (`a5_lonlattocell`)

Converts geographic coordinates (longitude, latitude) to A5 cell index at a specified resolution.

**Inputs:**
- **Input table**: Table containing longitude and latitude columns
- **Longitude column**: Column with longitude values (decimal degrees)
- **Latitude column**: Column with latitude values (decimal degrees)
- **Resolution**: A5 resolution level to index at (0-20)
- **Output column name**: Name for the output A5 cell index column (default: "a5_cell")

**Outputs:**
- **Output table**: Input table with additional A5 cell index column

## Library Integration

### H3 Library
- **URL**: `gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_h3.js`
- **Function**: `h3Lib.geoToH3(lat, lng, res)`

### A5 Library
- **URL**: `gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_a5.js`
- **Function**: `a5Lib.lonLatToCell([lng, lat], res)`

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

## A5 Resolution Levels

A5 uses a hierarchical resolution system where higher resolution numbers provide finer granularity:

- **Lower resolutions (0-5)**: Coarse cells covering large areas
- **Medium resolutions (6-12)**: Medium-sized cells suitable for regional analysis
- **Higher resolutions (13-20)**: Fine cells for detailed local analysis

## Example Usage

### H3 Example

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

### A5 Example

Input table:
```
| longitude | latitude | name     |
|-----------|----------|----------|
| -74.0060  | 40.7128  | NYC      |
| -118.2437 | 34.0522  | LA       |
| -0.1278   | 51.5074  | London   |
```

Output table (resolution 9):
```
| longitude | latitude | name     | a5_cell           |
|-----------|----------|----------|-------------------|
| -74.0060  | 40.7128  | NYC      | 1234567890123456 |
| -118.2437 | 34.0522  | LA       | 9876543210987654 |
| -0.1278   | 51.5074  | London   | 5555666677778888 |
```

## Technical Implementation

### H3 Component
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

### A5 Component
```sql
CREATE TEMP FUNCTION lonLatToCell(lng FLOAT64, lat FLOAT64, res INT64)
RETURNS STRING
LANGUAGE js
OPTIONS (
    library = ["gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_a5.js"]
)
AS r"""
    if (lng === null || lat === null || res === null) {
        return null;
    }
    const coordinate = [lng, lat];
    const result = a5Lib.lonLatToCell(coordinate, res);
    return result.toString();
""";
```

## Key Differences Between H3 and A5

| Feature | H3 | A5 |
|---------|----|----|
| **Cell Shape** | Hexagonal | Variable (depends on implementation) |
| **Coordinate Order** | [lat, lng] | [lng, lat] |
| **Resolution Range** | 0-15 | 0-20 |
| **Return Type** | String | BigInt (converted to String) |
| **Library Function** | `h3Lib.geoToH3(lat, lng, res)` | `a5Lib.lonLatToCell([lng, lat], res)` |

## Testing

Both components include comprehensive test fixtures:

- **Test 1**: Resolution 9 (fine detail)
- **Test 2**: Resolution 2 (coarse detail)

Test data includes coordinates for major cities: New York, Los Angeles, London, Paris, and Tokyo.

## Validation

Validation scripts are included for both libraries:
- `validate_h3_library.sql` - Tests H3 library loading and function execution
- `validate_a5_library.sql` - Tests A5 library loading and function execution

## Installation

1. Ensure you have the CARTO Workflows extension framework set up
2. Deploy the extension to your BigQuery project
3. Both components will be available in the CARTO Workflows interface

## Use Cases

### H3 Use Cases
- **Ride-sharing**: Hexagonal grid for efficient driver-rider matching
- **Geospatial analysis**: Hierarchical spatial indexing for analytics
- **Location-based services**: Precise location indexing and clustering

### A5 Use Cases
- **Alternative indexing**: Different spatial partitioning for specific use cases
- **Custom geospatial workflows**: When A5's indexing scheme is preferred
- **Comparative analysis**: Compare different indexing systems

## References

- [H3 Library Documentation](https://h3geo.org/)
- [H3 Resolution Table](https://h3geo.org/docs/core-library/restable/)
- [A5 Library Documentation](https://github.com/uber/h3-js)
- [CARTO Analytics Toolbox](https://docs.carto.com/analytics-toolbox-bigquery/)
- [CARTO Workflows Extensions](https://docs.carto.com/carto-user-manual/workflows/extension-packages/)

## Development

To modify or extend this extension:

1. Edit component metadata in `components/<component_name>/metadata.json`
2. Update SQL logic in `components/<component_name>/src/fullrun.sql` and `dryrun.sql`
3. Modify tests in `components/<component_name>/test/`
4. Update documentation in `components/<component_name>/doc/README.md`
5. Run `python carto_extension.py check` to validate the structure
6. Run `python carto_extension.py test` to test the components
7. Run `python carto_extension.py package` to create a distributable package 