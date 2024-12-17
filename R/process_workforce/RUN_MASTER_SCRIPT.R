################################################################################
# Script to Run Master Workflow for Workforce Data Processing
################################################################################

# 1. Library Imports -----------------------------------------------------------
library(readxl)
library(tidyverse)
library(fs)
library(purrr)
library(odbc)
library(DBI)
library(janitor)
library(stringr)
library(lubridate)

# 2. Environment Setup --------------------------------------------------------

# Clear current working environment
rm(list = ls())

# Define working directory (update with your directory path)
directory_path <- ""  # Set parent directory path here
setwd(directory_path)

# Establish database connection
sql_connection <- dbConnect(
  odbc(),
  Driver = "SQL Server",
  Server = "MLCSU-BI-SQL",
  Database = "Working",
  Trusted_Connection = "True"
)

# Define the latest month (previous month as YYYYMM format)
latest_month <- as.integer(format(Sys.Date() %m-% months(1), "%Y%m"))

# 3. Function to Run All Scripts -----------------------------------------------

run_master_script <- function() {
  start_time <- Sys.time()
  
  # Define a helper function to source R scripts with messages
  source_script <- function(script_name, description) {
    message(paste("Starting:", description))
    source(file.path(directory_path, "R/process_workforce", script_name))
    message(paste("Finished:", description))
  }
  
  # Run scripts in sequence
  source_script("01_Extract_Raw_Files.R", "Extracting Raw Data")
  source_script("02_Create_Main_Output.R", "Creating Main Output & Temp Tables")
  source_script("03_Calc_Vacancy.R", "Calculating Vacancies")
  source_script("04_Modify_Table.R", "Modifying KPI, Turnover, and Sickness Tables")
  source_script("05_Main_Overview.R", "Creating Dataset for Main Overview Page")
  
  # Run SQL script to insert data into the database
  message("Starting: Inserting Data into Database")
  sql_script <- read_file("SQL/INSERT_INTO.sql")  # Read SQL script
  dbExecute(sql_connection, sql_script)  # Execute SQL script
  message("Finished: Inserting Data into Database")
  
  # Print total time taken
  time_taken <- Sys.time() - start_time
  message("Process completed!")
  message(paste("Total time taken to run all scripts:", round(time_taken, 2), "seconds"))
}

# 4. Run the Master Script -----------------------------------------------------
run_master_script()
