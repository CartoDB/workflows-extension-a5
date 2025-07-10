# CARTO Workflows Extension Template - Codebase Overview

This repository is a template for creating extension packages for CARTO Workflows, which extend the core functionality with custom components tailored to specific use cases.

## 🏗️ Repository Structure

### Root Level Files
- **`carto_extension.py`** (34KB, 980 lines) - Main Python script that handles:
  - Extension packaging and deployment
  - BigQuery and Snowflake integration
  - Component testing and validation
  - SQL procedure generation
  - Metadata processing and icon encoding

- **`metadata.json`** - Extension-level metadata defining:
  - Extension name, title, industry, description
  - Version and provider information
  - Author and license details
  - List of included components

- **`requirements.txt`** - Python dependencies for the extension framework
- **`README.md`** - Main documentation with links to detailed guides

### 📁 Core Directories

#### `/components/` - Extension Components
Contains individual workflow components that can be added to CARTO Workflows:

- **`template/`** - Example component demonstrating the structure:
  - `metadata.json` - Component-specific metadata and configuration
  - `src/` - SQL source files:
    - `fullrun.sql` - Main execution logic
    - `dryrun.sql` - Validation/preview logic
  - `test/` - Testing infrastructure:
    - `test.json` - Test configuration
    - `fixtures/` - Test data files
    - `table1.ndjson` - Sample test data

#### `/doc/` - Documentation
Comprehensive documentation for extension development:

- **`anatomy_of_an_extension.md`** - Core concepts and structure
- **`build_your_extension.md`** - Step-by-step development guide
- **`component_metadata.md`** - Detailed component configuration
- **`extension_metadata.md`** - Extension-level configuration
- **`procedure.md`** - SQL procedure development guide
- **`running_tests.md`** - Testing framework documentation
- **`tooling.md`** - Development tools and utilities
- **`icons.md`** - Icon requirements and guidelines
- **`img/`** - Documentation images and examples

#### `/icons/` - Visual Assets
- **`component-default.svg`** - Default component icon
- **`extension-default.svg`** - Default extension icon

## 🔧 Key Functionality

### Extension Framework (`carto_extension.py`)
The main Python script provides several core functions:

1. **Deployment Functions**:
   - `deploy()` - Deploy extension to BigQuery or Snowflake
   - `deploy_bq()` - BigQuery-specific deployment
   - `deploy_sf()` - Snowflake-specific deployment

2. **Testing Functions**:
   - `test()` - Run component tests
   - `capture()` - Capture test results
   - `check()` - Validate extension structure

3. **Packaging Functions**:
   - `package()` - Create distributable extension package
   - `create_metadata()` - Process and encode metadata
   - `_encode_image()` - Convert icons to base64

4. **SQL Generation**:
   - `get_procedure_code_bq()` - Generate BigQuery procedures
   - `get_procedure_code_sf()` - Generate Snowflake procedures
   - `create_sql_code_bq()` - Create BigQuery installation script
   - `create_sql_code_sf()` - Create Snowflake installation script

### Component Structure
Each component follows a standardized structure:

```
component_name/
├── metadata.json    # Component configuration
├── src/
│   ├── fullrun.sql  # Main execution logic
│   └── dryrun.sql   # Validation logic
└── test/
    ├── test.json    # Test configuration
    ├── fixtures/    # Test data
    └── *.ndjson     # Sample data files
```

## 🎯 Development Workflow

1. **Setup**: Use the template structure to create new components
2. **Development**: Write SQL procedures in `src/` directory
3. **Testing**: Configure tests in `test/` directory
4. **Validation**: Use `carto_extension.py` to test and validate
5. **Packaging**: Create distributable extension package
6. **Deployment**: Deploy to BigQuery or Snowflake environments

## 🔗 Integration Points

- **CARTO Workflows**: Extensions integrate with the main Workflows application
- **BigQuery**: Native support for BigQuery data warehouses
- **Snowflake**: Native support for Snowflake data warehouses
- **Environment Variables**: Configuration via `.env` files for database connections

## 📋 Key Features

- **Multi-provider Support**: Works with both BigQuery and Snowflake
- **Automated Testing**: Built-in testing framework with fixtures
- **Icon Support**: SVG and PNG icon encoding
- **Metadata Management**: Structured metadata for extensions and components
- **SQL Procedure Generation**: Automatic procedure creation with proper namespacing
- **Package Distribution**: Create distributable extension packages

This template provides a complete framework for developing, testing, and distributing custom CARTO Workflows extensions with proper structure and tooling. 