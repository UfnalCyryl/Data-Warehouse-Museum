# Museum Data Warehouse Solution 

An end-to-end Data Engineering project demonstrating a full Business Intelligence stack for museum operations. The solution transforms raw operational data into an analytical OLAP cube

## Architecture & Data Flow

The project follows a standard BI architectural pattern:
1. **Source Layer:** Relational database (SQL Server) containing operational museum data.
2. **ETL Layer:** SSIS packages responsible for extracting, transforming, and loading data into the Data Warehouse.
3. **Storage Layer:** Data Warehouse designed for optimized analytical performance.
4. **Semantic Layer:** SSAS Multidimensional Model providing high-performance query capabilities.

---

## Project Structure
* **`00_generate_data/`**: Contains python scripts generating data.
* **`01_database_setup/`**: Contains SQL scripts for initializing the source operational database and seeding it with sample data.
* **`02_dw_setup/`**: Definition of the Data Warehouse schema (Fact and Dimension tables).
* **`03_etl_ssis/`**: SQL Server Integration Services (SSIS) project containing the ETL pipelines.
* **`04_ssas_model/`**: SQL Server Analysis Services (SSAS) project defining the Multidimensional Cube and Dimensions.
* **`docs/`**: Business requirement specifications and process descriptions.


## Technology Stack

- **Database:** Microsoft SQL Server
- **ETL:** SQL Server Integration Services (SSIS)
- **OLAP:** SQL Server Analysis Services (SSAS) - Multidimensional Mode
- **Languages:** T-SQL, MDX

---

## How to Run
0.  **Data:** Execute gen1 in `00_generate_data`
1.  **Database:** Adjust file path, execute scripts in `01_database_setup` to create the source DB, then `02_dw_setup` for the warehouse schema.
2.  **ETL:** Open the `.dtproj` in Visual Studio (with SSIS extensions), adjust file path and run the packages to migrate data.
3.  **Analytics:** Deploy the SSAS project in `04_ssas_model` to your Analysis Services instance to browse the cube.

---
## Authors

* **Cyryl Ufnal**
* **Jakub Paprocki**
  
*Developed during Datawarehouse classes 
