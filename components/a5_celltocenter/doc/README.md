# A5 Cell to Center Component

This component adds a new column containing the geospatial center coordinates of A5 cells using the A5 library.

## Parameters

- **input_table**: The table containing the A5 cell identifier column
- **cell_column**: The column containing A5 cell identifiers (e.g., 'a5_cell')
- **output_column_name**: Name for the output center coordinate column (default: 'a5_center')

## Output

The component adds a new column with the center coordinate for each A5 cell, as a string in the format 'longitude,latitude'.

## Example

Input table:
```
| a5_cell      |
|--------------|
| 1234567890   |
| 9876543210   |
```

Output table:
```
| a5_cell      | a5_center         |
|--------------|------------------|
| 1234567890   | -2.6,51.5        |
| 9876543210   | -2.7,51.6        |
```

## Usage Notes

- The cell column must contain valid A5 cell identifiers (as strings)
- The output is a string representing the center coordinate as 'longitude,latitude'
- The function uses the A5 library and supports all valid A5 cell identifiers 