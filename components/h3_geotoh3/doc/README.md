# H3 Geo to H3 Index

This component converts geographic coordinates (latitude, longitude) to H3 index at a specified resolution using the H3 library.

## Overview

The H3 library provides a hierarchical geospatial indexing system that partitions the world into hexagonal cells. This component wraps the `geoToH3` function from the H3 library to convert latitude/longitude coordinates to H3 indices.

## Inputs

- **Input table**: The table containing latitude and longitude columns
- **Latitude column**: The column containing latitude values in decimal degrees
- **Longitude column**: The column containing longitude values in decimal degrees  
- **Resolution**: The H3 resolution (0-15, where 0 is coarsest and 15 is finest)
- **Output column name**: Name for the output H3 index column (default: "h3_index")

## Outputs

- **Output table**: The input table with an additional H3 index column

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

## Example

Input table with coordinates:
```
| latitude | longitude | name     |
|----------|-----------|----------|
| 40.7128  | -74.0060  | NYC      |
| 34.0522  | -118.2437 | LA       |
| 51.5074  | -0.1278   | London   |
```

Output table with H3 index (resolution 9):
```
| latitude | longitude | name     | h3_index        |
|----------|-----------|----------|-----------------|
| 40.7128  | -74.0060  | NYC      | 8928308280fffff |
| 34.0522  | -118.2437 | LA       | 89283082837ffff |
| 51.5074  | -0.1278   | London   | 8928308280fffff |
```

## Technical Details

This component uses the H3 library hosted at `gs://spatialextension_os/carto/libs/carto_analytics_toolbox_core_h3.js` and creates a BigQuery JavaScript UDF that wraps the `h3Lib.geoToH3()` function.

The function handles null values gracefully by returning null when any input parameter is null.

## References

- [H3 Library Documentation](https://h3geo.org/)
- [H3 Resolution Table](https://h3geo.org/docs/core-library/restable/)
- [CARTO Analytics Toolbox](https://docs.carto.com/analytics-toolbox-bigquery/) 