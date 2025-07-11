# A5 Cell to Boundary Component

This component converts A5 cell identifiers to their boundary coordinates using the A5 library.

## Functionality

The `cellToBoundary` function returns the vertices that define the boundary of an A5 cell. It takes an A5 cell identifier and optional configuration parameters to return an array of coordinates defining the cell boundary.

## Parameters

- **cell_column**: The column containing A5 cell identifiers (bigint values)
- **closed_ring**: Boolean flag to close the ring by repeating the first point at the end (default: true)
- **segments**: Number of segments to use for each edge. Use 'auto' for resolution-appropriate value (default: 'auto')
- **output_column_name**: Name for the output boundary coordinates column (default: 'a5_boundary')

## Output

The component adds a new column containing JSON-formatted boundary coordinates. Each boundary is represented as an array of [longitude, latitude] coordinate pairs.

## Example

Input table with A5 cell identifiers:
```
| a5_cell_id |
|------------|
| 1234567890 |
| 9876543210 |
```

Output table with boundary coordinates:
```
| a5_cell_id | a5_boundary                                    |
|------------|------------------------------------------------|
| 1234567890 | [[-122.5, 37.5], [-122.4, 37.5], [-122.4, 37.6], [-122.5, 37.6], [-122.5, 37.5]] |
| 9876543210 | [[-74.0, 40.7], [-73.9, 40.7], [-73.9, 40.8], [-74.0, 40.8], [-74.0, 40.7]] |
```

## Usage Notes

- The cell identifiers should be valid A5 cell values
- The boundary coordinates are returned as JSON strings for easy parsing
- Invalid cell identifiers will return null values
- The function handles both numeric and string representations of cell identifiers 