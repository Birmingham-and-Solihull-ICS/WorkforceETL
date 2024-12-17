################################################################################
# Script to Process Agency Returns and Update Database
################################################################################

# 1. Setup and Library Imports -------------------------------------------------

rm(list = ls())

library(dplyr)
library(readxl)
library(DBI)
library(odbc)
library(stringr)
library(janitor)
library(lubridate)
library(fs)
library(purrr)

# Database connection
sql_connection <- dbConnect(
  odbc(),
  Driver = "SQL Server",
  Server = "MLCSU-BI-SQL",
  Database = "EAT_Reporting_BSOL",
  Trusted_Connection = "True"
)

# Define the latest month
latest_month <- as.integer(format(Sys.Date() %m-% months(1), "%Y%m"))

# Define directories
data_directory <- "data/agency_returns/"
new_data_directory <- paste0(data_directory, "new_data/")
old_data_directory <- paste0(data_directory, "old_data/")

# 2. Functions -----------------------------------------------------------------

## 2.1 Process Excel Files -----------------------------------------------------
process_excel_data <- function(file_path) {
  sheet_names <- excel_sheets(file_path)[2:3]  # Sheets to read
  
  read_sheet <- function(sheet_name) {
    read_excel(file_path, sheet = sheet_name) %>%
      mutate(sheet_name = sheet_name)
  }
  
  # Read and clean data
  final_data <- map_df(sheet_names, read_sheet) %>%
    select(-1) %>%
    slice(-1:-15)
  
  # Bank Data
  bank_data <- final_data %>%
    filter(sheet_name == sheet_names[1]) %>%
    slice(2:8) %>%
    select(StaffGroupMapped = 1, Shifts = 3) %>%
    mutate(StaffCategory = "Bank", `Bank Shifts` = as.numeric(Shifts))
  
  # Agency Data
  agency_data <- final_data %>%
    filter(sheet_name == sheet_names[2]) %>%
    slice(11:n()) %>%
    select(price_cap_override = 2, framework_override = 3,
           StaffGroupMapped = 15, Shifts = 16) %>%
    mutate(StaffCategory = "Agency", `Agency Shifts` = as.numeric(Shifts)) %>%
    filter(!StaffGroupMapped %in% c("Core", "Unsocial", "Grand Total"))
  
  bind_rows(bank_data, agency_data)
}

## 2.2 Add Missing Columns -----------------------------------------------------
add_missing_columns <- function(df_to_update, reference_df) {
  missing_columns <- setdiff(names(reference_df), names(df_to_update))
  for (col in missing_columns) df_to_update[[col]] <- NA
  df_to_update <- df_to_update[, names(reference_df)]  # Reorder columns
  return(df_to_update)
}

## 2.3 Extract Provider Name ---------------------------------------------------
extract_provider <- function(filename) {
  group_1 <- c("UHB", "BSMHFT", "ROH", "BWCH", "BCHC")
  group_2 <- c("RRK", "RXT", "RRJ", "RQ3", "RYW")
  
  matches <- unlist(regmatches(filename, gregexpr(paste(c(group_1, group_2), collapse = "|"), filename)))
  if (length(matches[matches %in% group_1]) > 0) return(matches[1])
  if (length(matches[matches %in% group_2]) > 0) return(group_1[match(matches[1], group_2)])
  return("No provider abbreviation found")
}

## 2.4 Process All Providers ---------------------------------------------------
process_all_providers <- function(main_directory) {
  excel_files <- list.files(main_directory, pattern = "\\.xlsx$", full.names = TRUE)
  
  all_data <- map_dfr(excel_files, function(file_path) {
    provider <- extract_provider(basename(file_path))
    process_excel_data(file_path) %>%
      mutate(Provider = provider, Yearmonth = latest_month)
  })
  
  file_move(excel_files, old_data_directory)
  return(all_data)
}

## 2.5 Update and Write to Database --------------------------------------------
update_database_table <- function(table_name, new_data, main_df) {
  updated_data <- bind_rows(main_df, new_data)
  dbWriteTable(sql_connection, Id(schema = "Development", table = table_name), 
               updated_data, overwrite = TRUE)
}

get_row_count <- function(message) {
  count <- dbGetQuery(sql_connection, "SELECT COUNT(*) AS TotalRows FROM [EAT_Reporting_BSOL].[Development].[BSOL_1264_Agency_Workforce]")$TotalRows
  message(message, count)
}

# 3. Main Execution ------------------------------------------------------------

# Step 1: Process new agency data
agency_data <- process_all_providers(new_data_directory) %>%
  filter(StaffCategory == "Agency")

# Step 2: Retrieve and clean previous data
main_df <- dbGetQuery(sql_connection, 
                      "SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1264_Agency_Workforce]") %>%
  as_tibble() %>%
  mutate(StaffGroupMapped = case_when(
    StaffGroupMapped == "Healthcare Assistant & Other Support" ~ "Healthcare Assistants & Other Support",
    StaffGroupMapped == "Scientific, Therapeutic & Technical (AHPS)" ~ "Scientific, Therapeutic & Technical",
    TRUE ~ StaffGroupMapped
  ))

# Step 3: Retrieve date and organization mappings
date_mapping <- dbGetQuery(sql_connection, "
  SELECT HCSCalendarMonthYearLongName AS MonthYear, HCCSReconciliationPoint AS Yearmonth
  FROM Reference.dbo.DIM_tbDate
  WHERE HCSFinancialYearName >= '2022-23'
") %>% as_tibble()

org_mapping <- dbGetQuery(sql_connection, "
  SELECT Legacy_OrgCode AS NHSCode, Current_OrgName_Short AS Provider
  FROM EAT_Reporting_BSOL.Reference.tbOrgLookUp
  WHERE Legacy_OrgCode IN ('RRK00', 'RRJ00', 'RQ300', 'RXT00', 'RYW00')
") %>% as_tibble()

# Step 4: Transform agency data
updated_agency_data <- agency_data %>%
  inner_join(date_mapping, by = "Yearmonth") %>%
  inner_join(org_mapping, by = "Provider") %>%
  mutate(
    RegionDesc = "Midlands", STPName = "Birmingham and Solihull STP",
    OrganisationType = "FT", NHSCode = substr(NHSCode, 1, 3),
    SectorType = case_when(
      NHSCode == "RRK" ~ "Acute", NHSCode == "RYW" ~ "Community",
      NHSCode == "RXT" ~ "Mental Health", TRUE ~ "Specialist"
    ),
    `Sub Region` = "West", ICS = "Birmingham and Solihull",
    Date = as.Date(paste0("01-", MonthYear), format = "%d-%b-%Y"),
    Yearmonth = as.integer(format(Date, "%Y%m"))
  ) %>%
  add_missing_columns(reference_df = main_df)

# Step 5: Update database table
get_row_count("Total rows before updating table: ")
update_database_table("BSOL_1264_Agency_Workforce", updated_agency_data, main_df)
get_row_count("Total rows after updating table: ")

# Step 6: Create global temp table
dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1264_Agency_Workforce")
dbExecute(sql_connection, "
  SELECT * INTO ##BSOL_1264_Agency_Workforce 
  FROM [Development].[BSOL_1264_Agency_Workforce]
")

################################################################################
