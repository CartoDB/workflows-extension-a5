# A5 Geography to Cell Component

This component converts a GEOGRAPHY column to an A5 cell index at a specified resolution using the A5 library.

## Parameters

- **input_table**: The table containing the GEOGRAPHY column
- **geo_column**: The column containing GEOGRAPHY values (e.g., 'geom')
- **resolution**: The A5 resolution level to index at (default: 9)
- **output_column_name**: Name for the output A5 cell index column (default: 'a5_cell')

## Output

The component adds a new column with the A5 cell index for each row, calculated from the longitude and latitude of the GEOGRAPHY column.

## Example

Input table:
```
| geom                        |
|-----------------------------|
| POINT(-2.6 51.5)            |
| POINT(-2.7 51.6)            |
```

Output table:
```
| geom            | a5_cell      |
|-----------------|-------------|
| POINT(-2.6 51.5)| 1234567890   |
| POINT(-2.7 51.6)| 9876543210   |
```

## Usage Notes

- The GEOGRAPHY column must contain valid POINT geometries
- The output is a string representing the A5 cell index
- The function uses the A5 library and supports resolutions 0-20 