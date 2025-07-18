# A5 Cell to Boundary Component

This component converts A5 cell identifiers to their boundary coordinates using the A5 library.

## Functionality

The `cellToBoundary` function returns the vertices that define the boundary of an A5 cell. It takes an A5 cell identifier and optional configuration parameters to return an array of coordinates defining the cell boundary.

## Parameters

- **cell_column**: The column containing A5 cell identifiers (string values)
- **output_column_name**: Name for the output boundary coordinates column (default: 'a5_boundary')

## Output

The component adds a new column containing WKT (Well-Known Text) strings representing the A5 cell boundaries. Each boundary is converted from the A5 cell identifier to WKT format that can be used with spatial functions like ST_GEOGFROMTEXT.

## Example

Input table with A5 cell identifiers:
```
| a5_cell_id |
|------------|
| 1234567890 |
| 9876543210 |
```

Output table with geography objects:
```
| a5_cell_id | a5_boundary                                    |
|------------|------------------------------------------------|
| 1234567890 | POLYGON((-122.5 37.5, -122.4 37.5, -122.4 37.6, -122.5 37.6, -122.5 37.5)) |
| 9876543210 | POLYGON((-74.0 40.7, -73.9 40.7, -73.9 40.8, -74.0 40.8, -74.0 40.7)) |
```

## Usage Notes

- The cell identifiers should be valid A5 cell values in string format
- The output is a WKT string that can be converted to geography using ST_GEOGFROMTEXT
- Invalid cell identifiers will return null values
- The function uses hardcoded options: closedRing=true and segments='auto'
- Use ST_GEOGFROMTEXT in your workflow to convert the WKT to geography objects 