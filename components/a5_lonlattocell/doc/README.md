# A5 Longitude Latitude to Cell

This component converts geographic coordinates (longitude, latitude) to A5 cell index at a specified resolution using the A5 library.

## Overview

The A5 library provides a geospatial indexing system that partitions the world into cells. This component wraps the `lonLatToCell` function from the A5 library to convert longitude/latitude coordinates to A5 cell indices.

## Inputs

- **Input table**: The table containing longitude and latitude columns
- **Longitude column**: The column containing longitude values in decimal degrees
- **Latitude column**: The column containing latitude values in decimal degrees  
- **Resolution**: The A5 resolution level to index at (0-20)
- **Output column name**: Name for the output A5 cell index column (default: "a5_cell")

## Outputs

- **Output table**: The input table with an additional A5 cell index column

## A5 Resolution Levels

A5 uses a hierarchical resolution system where higher resolution numbers provide finer granularity. The resolution range is typically 0-20, where:

- **Lower resolutions (0-5)**: Coarse cells covering large areas
- **Medium resolutions (6-12)**: Medium-sized cells suitable for regional analysis
- **Higher resolutions (13-20)**: Fine cells for detailed local analysis

## Example

Input table with coordinates:
```
| longitude | latitude | name     |
|-----------|----------|----------|
| -74.0060  | 40.7128  | NYC      |
| -118.2437 | 34.0522  | LA       |
| -0.1278   | 51.5074  | London   |
```

Output table with A5 cell index (resolution 9):
```
| longitude | latitude | name     | a5_cell           |
|-----------|----------|----------|-------------------|
| -74.0060  | 40.7128  | NYC      | 1234567890123456 |
| -118.2437 | 34.0522  | LA       | 9876543210987654 |
| -0.1278   | 51.5074  | London   | 5555666677778888 |
```

## Technical Details

This component uses the A5 library hosted at `gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_a5.js` and creates a BigQuery JavaScript UDF that wraps the `a5Lib.lonLatToCell()` function.

The function:
1. Takes longitude and latitude as separate parameters
2. Creates a coordinate array `[longitude, latitude]` as expected by the A5 library
3. Calls `a5Lib.lonLatToCell(coordinate, resolution)`
4. Converts the returned bigint to a string for BigQuery compatibility
5. Handles null values gracefully by returning null when any input parameter is null

## Function Signature

The wrapped function follows the original A5 library signature:
```javascript
lonLatToCell(coordinate: [longitude: number, latitude: number], resolution: number): bigint
```

## References

- [A5 Library Documentation](https://github.com/uber/h3-js)
- [CARTO Analytics Toolbox](https://docs.carto.com/analytics-toolbox-bigquery/)
- [Geospatial Indexing Systems](https://en.wikipedia.org/wiki/Geospatial_indexing) 