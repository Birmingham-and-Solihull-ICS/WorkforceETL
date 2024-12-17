################################################################################
# Script to process raw data from monthly submissions and load into a database.
# Main function: read_and_process_data()
################################################################################

# Function to extract provider abbreviations from filenames
extract_provider <- function(filename) {
  group_1 <- c("UHB", "BSMHFT", "ROH", "BWCH", "BCHC")
  group_2 <- c("RRK", "RXT", "RRJ", "RQ3", "RYW")
  all_providers <- c(group_1, group_2)
  
  matches <- unlist(regmatches(filename, gregexpr(paste(all_providers, collapse = "|"), filename)))
  if (any(matches %in% group_1)) return(matches[matches %in% group_1][1])
  if (any(matches %in% group_2)) return(group_1[match(matches[matches %in% group_2][1], group_2)])
  
  return("No provider abbreviation found")
}

# Function to process individual Excel sheets
pull_excel_data <- function(data, provider, yearmonth) {
  data %>%
    select(6:17, 19) %>%
    filter(!is.na(Maincode) & !Maincode %in% c("Subcode", "Maincode")) %>%
    rename_with(~yearmonth, .cols = 1:12) %>%
    pivot_longer(cols = all_of(1:12), names_to = "Yearmonth", values_to = "Value") %>%
    mutate(Provider = provider)
}

# Main function to process all Excel files in a directory
read_and_process_data <- function(directory, yearmonth) {
  excel_files <- list.files(path = directory, full.names = TRUE)
  data_list <- list()
  
  for (file_path in excel_files) {
    provider <- extract_provider(basename(file_path))
    sheet_names <- excel_sheets(file_path)
    
    sheet_data <- lapply(3:9, function(i) {
      data <- read_excel(file_path, sheet = sheet_names[i], skip = 1)
      pull_excel_data(data, provider, yearmonth)
    })
    
    data_list[[length(data_list) + 1]] <- bind_rows(sheet_data)
  }
  
  combined_data <- bind_rows(data_list) %>%
    mutate(Load_Date = Sys.Date()) %>%
    filter(Yearmonth <= latest_month) # Assuming `latest_month` is predefined
  
  # Move processed files
  file_move(dir_ls(directory), file.path(directory_path, "data/workforce_returns/old_data", basename(dir_ls(directory))))
  
  return(combined_data)
}

# Execution --------------------------------------------------------------------

start_time <- Sys.time()

# Process raw data
df_all <- read_and_process_data(
  directory = paste0(directory_path, "data/workforce_returns/new_data"),
  yearmonth = c("202404", "202405", "202406", "202407", "202408", "202409", 
                "202410", "202411", "202412", "202501", "202502", "202503")
)

# Clean data for database insertion
data_2425 <- df_all %>%
  filter(grepl("^-?\\d*(\\.\\d+)?$", Value)) %>%
  mutate(LoadDate = as.Date(Load_Date, format = "%Y-%m-%d"),
         Value = as.numeric(Value)) %>%
  filter(!is.na(Maincode)) %>%
  select(Maincode, Yearmonth, Provider, Value, LoadDate)


# Load data into database ------------------------------------------------------

dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1236_PWR_New_Raw_Data")

dbWriteTable(
  conn = sql_connection,
  name = "##BSOL_1236_PWR_New_Raw_Data",
  overwrite = TRUE,
  value = data_2425
)

dbExecute(sql_connection, "
INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main] (
    Maincode, Yearmonth, Provider, Value, LoadDate
)
SELECT DISTINCT Maincode, Yearmonth, Provider, Value, LoadDate
FROM ##BSOL_1236_PWR_New_Raw_Data src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
)
")

end_time <- Sys.time()
print(paste("Total time taken: ", round(end_time - start_time, 2), "seconds"))
