# A5 Geospatial Extension for CARTO Workflows

This extension provides A5 geospatial indexing functions for BigQuery through CARTO Workflows. It wraps the A5 library to enable conversion of geographic coordinates to A5 cell indices.

## Components

### A5 Longitude Latitude to Cell (`a5_lonlattocell`)

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

### A5 Library
- **URL**: `gs://carto-workflows-extension-a5/a5.umd.js`
- **Function**: `A5.lonLatToCell([lng, lat], res)`

## A5 Resolution Levels

A5 uses a hierarchical resolution system where higher resolution numbers provide finer granularity:

- **Lower resolutions (0-5)**: Coarse cells covering large areas
- **Medium resolutions (6-12)**: Medium-sized cells suitable for regional analysis
- **Higher resolutions (13-20)**: Fine cells for detailed local analysis

## Example Usage

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

### A5 Component
```sql
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
```

## A5 Features

| Feature | A5 |
|---------|----|
| **Cell Shape** | Variable (depends on implementation) |
| **Coordinate Order** | [lng, lat] |
| **Resolution Range** | 0-20 |
| **Return Type** | String |
| **Library Function** | `A5.lonLatToCell([lng, lat], res)` |

## Testing

The A5 component includes comprehensive test fixtures:

- **Test 1**: Resolution 9 (fine detail)
- **Test 2**: Resolution 2 (coarse detail)

Test data includes coordinates for major cities: New York, Los Angeles, London, Paris, and Tokyo.

## Validation

Validation scripts are included for the A5 library:
- `validate_a5_library.sql` - Tests A5 library loading and function execution

## Installation

1. Ensure you have the CARTO Workflows extension framework set up
2. Deploy the extension to your BigQuery project
3. Both components will be available in the CARTO Workflows interface

## Use Cases

### A5 Use Cases
- **Alternative indexing**: Different spatial partitioning for specific use cases
- **Custom geospatial workflows**: When A5's indexing scheme is preferred
- **Spatial analysis**: Efficient location indexing and clustering

## References

- [A5 Library Documentation](https://github.com/uber/h3-js)
- [CARTO Analytics Toolbox](https://docs.carto.com/analytics-toolbox-bigquery/)
- [CARTO Workflows Extensions](https://docs.carto.com/carto-user-manual/workflows/extension-packages/)

## Development

To modify or extend this extension:

1. Edit component metadata in `components/a5_lonlattocell/metadata.json`
2. Update SQL logic in `components/a5_lonlattocell/src/fullrun.sql` and `dryrun.sql`
3. Modify tests in `components/a5_lonlattocell/test/`
4. Update documentation in `components/a5_lonlattocell/doc/README.md`
5. Run `python carto_extension.py check` to validate the structure
6. Run `python carto_extension.py test` to test the component
7. Run `python carto_extension.py package` to create a distributable package 