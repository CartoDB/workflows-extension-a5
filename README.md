# A5 Geospatial Extension

A5 is an open-source, next-generation hierarchical spatial index for geospatial data. It enables fast, scalable, and precise spatial analytics by dividing the world into a grid of pentagonal cells at multiple resolutions. A5 cells have equal area, minimal distortion, and are well-suited for spatial analysis and aggregation.  
Learn more at [a5geo.org](https://a5geo.org/).

<img src="https://a5geo.org/assets/images/a5-preview-0b9f90a150c8affef7bf1211935d9916.png" alt="A5 Logo" width="120"/>

## Extension Functions

| Icon | Name | Description |
|------|------|-------------|
| <img src="icons/a5-boundary.svg" width="32"/> | **A5 Cell to Boundary** | Returns the vertices that define the boundary of an A5 cell. |
| <img src="icons/a5-center.svg" width="32"/> | **A5 Cell to Center** | Returns the geospatial coordinate at the center of an A5 cell. |
| <img src="icons/a5-frompoint.svg" width="32"/> | **A5 Geography to Cell** | Converts a GEOGRAPHY column to an A5 cell index at the specified resolution using the A5 library. |

## Installation

Download the latest release of the extension as a zip package:

[Download extension.zip](https://raw.githubusercontent.com/CartoDB/workflows-extension-a5/refs/heads/master/extension.zip)

Then, follow the instructions in the CARTO Workflows documentation to upload and install the extension in your environment.