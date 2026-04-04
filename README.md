# Data Warehouse and Analytics Project
Welcome to the Data Warehouse and analytics project repository. 
The project demonstrate a comprehensive data warehousing and analytics solution. From building a warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---

### This project involves:
1. Data Architecture: Designing a modern Data Warehouse using Medalion Architeture Bronze, Silver and Gold layers.
2. ETL Pipeline: Extracting, transforming and Loading data from source systems into the warehous.
3. Data Modeling: Developing facts and dimension tables optimized for analytical queries.
4. Analytics and Reporting: Creating SQL-based reports and dashboards for actionable insights.

This repository is an excellent resource for professionals and students looking to showcase expertise in 
* SQL developments
* Data architects
* Data engineering
* ETL pipeline development
  
---

## Project Requirements

### Building the Data Warehouse (Data Engineering)
Develop a modern data warehouse using SQL Server to consolidate sales data, analytical reporting and informed decision making. 

### Specifications
* Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
* Data Quality: Cleanse and resolve data quality issues prior to analysis.
* Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
* Scope: Focus on latest datasets only; historization of data is not required.
* Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

## Data Analytics (BI Analytics and Reporting)
### Objective:
Develop SQL-based analysis to deliver basic insights into: 
* Customer behavior
* Product performance
* Sales trends

These insights empower stakeholders with key business performance metrics, enabling strategic decision making.
For more details refer to [requirements.md](https://github.com/ANDREWOLAITANTOLUTAIWO/DataWarehouse/blob/main/requirements.txt) 

---

## Data Architecture
The data architrecture for this project follows Medalion Architecture Bronze, Silver and Gold layers.

<img width="821" height="534" alt="Warehouse Architecture" src="https://github.com/user-attachments/assets/dc7270ae-ff84-40d7-b150-9b44a968a8bd" />


1. Bronze layer: Stores raw data as-is from the source system
2. Silver layer: This layer includes data cleansing, standardization and normalization processes to prepare data for analysis.
3. Gold layer: Houses business-ready data modeled into the star schema required for reporting and analysis

---

## Repository Structure

# 📁 Repository Structure

```id="tree001"
data-warehouse-project/
│
├── datasets/                         # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                             # Project documentation and architecture details  
│   ├── etl.drawio                    # Draw.io files showing all different techniques and methods of ETL  
│   ├── data_architecture.drawio      # Draw.io file showing DW project architecture  
│   ├── data_catalog.md               # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio              # Draw.io file for the data flow design   
│   ├── data_models.drawio            # Draw.io file for data models (star schema)  
│   ├── naming_conventions.md         # Consistent naming guidelines for tables, columns, and files  
│
├── scripts/                           # SQL scripts for ETL and transformations  
│   ├── bronze/                        # Scripts for extracting and loading raw data  
│   ├── silver/                        # Scripts for cleaning and transforming data  
│   ├── gold/                          # Scripts for creating analytical models 
│
├── tests/                             # Test scripts and quality files  
│
├── README.md                           # Project overview and instructions  
│
├── LICENSE                             # License information for the repository  
│
├── .gitignore                          # Files and directories to be ignored by Git  
│
└── requirements.txt                    # Dependencies and requirements for the DW project  

```

---

## License
This project is licenced under the [MIT License](https://github.com/ANDREWOLAITANTOLUTAIWO/DataWarehouse/blob/main/LICENSE). You are free to use, modify and share this project with proper attribution.

---

## About Me
Hi, my name is **Tolu Taiwo**. I am a geospatial data scientist. I help people and businesses make profit from data. You are free to connect with me.
[Linkedin](https://www.linkedin.com/in/andrew-tolu-taiwo-7515b0191/) tolutaiwo75@gmail.com
