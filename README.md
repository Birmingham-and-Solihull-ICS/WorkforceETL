# Workforce ETL

This git repository contains scripts written in R to process:
1. **Monthly Provider Workforce Returns**
2. **Temporary (Agency) Staffing Returns**

The scripts automate data cleaning, transformation, and loading into a database, from which reports can be automatically generated.

# Folder Structure

WorkforceETL/
│
├── data/                       # Raw input data
│   ├── workforce/              # Workforce returns (monthly submissions)
│   │   ├── new_data/           # New data files to process
│   │   └── old_data/           # Archived data files already processed
│   │
│   ├── agency/                 # Temporary staffing returns
│       ├── new_data/           # New data files to process
│       └── old_data/           # Archived data files already processed
│
├── R/                          # R scripts for processing
│   ├── process_workforce/      # Workforce processing scripts
│   │   ├── 01_Extract_Raw_Files.R
│   │   ├── 02_Create_Main_Output.R
│   │   ├── 03_Calc_Vacancy.R
│   │   ├── 04_Modify_Table.R
│   │   ├── 05_Main_Overview.R
│   │   └── RUN_MASTER_SCRIPT.R
│   │
│   ├── process_agency/         # Agency processing scripts
│       └── process_agency.R
│
├── SQL/                        # SQL scripts
│   ├── CREATE_TABLE.sql        # Script to create necessary database tables
│   ├── INSERT_INTO.sql         # Script to insert processed data into the database
│
├── output/                     # Processed outputs
│
├── doc/                        # Documentation
│
└── README.md                   # Main project documentation


This repository is dual licensed under the [Open Government v3]([https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) & MIT. All code can outputs are subject to Crown Copyright.
