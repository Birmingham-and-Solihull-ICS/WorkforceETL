# Workforce ETL

This git repository contains scripts written in R to process:
1. **Monthly Provider Workforce Returns**
2. **Temporary (Agency) Staffing Returns**

The scripts automate data cleaning, transformation, and loading into a database, from which reports can be automatically generated.


# Folder Structure

```text
WorkforceETL/
|
|
├── data/
│   ├── workforce/
│   │   ├── new_data/
│   │   └── old_data/
│   ├── agency/
│       ├── new_data/
│       └── old_data/
|
|
├── R/
│   ├── process_workforce/
│   │   ├── 01_Extract_Raw_Files.R
│   │   ├── 02_Create_Main_Output.R
│   │   ├── 03_Calc_Vacancy.R
│   │   ├── 04_Modify_Table.R
│   │   ├── 05_Main_Overview.R
│   │   └── RUN_MASTER_SCRIPT.R
|
│   ├── process_agency/
│       └── process_agency.R
|
|
├── SQL/
│   ├── CREATE_TABLE.sql
│   └── INSERT_INTO.sql
|
|
├── output/
|
|
├── doc/
|
|
└── README.md
```




This repository is dual licensed under the [Open Government v3]([https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) & MIT. All code can outputs are subject to Crown Copyright.
