################################################################################
# Script to Update KPI Table and Generate Sickness & Turnover Reports
################################################################################

# 1. Function: Check Column Types ----------------------------------------------
check_column_types <- function(main_df, df_to_check) {
  common_columns <- intersect(names(main_df), names(df_to_check))
  
  if (length(common_columns) == 0) {
    message("No common columns.")
    return(FALSE)
  }
  
  main_types <- sapply(main_df[common_columns], class)
  check_types <- sapply(df_to_check[common_columns], class)
  
  if (!all(main_types == check_types)) {
    message("Mismatched column types.")
    return(FALSE)
  }
  
  return(TRUE)
}

# 2. Function: Join Tables -----------------------------------------------------
join_tables <- function(main_df, df_to_join) {
  if (!check_column_types(main_df, df_to_join)) {
    message("Column type mismatch. Cannot join data frames.")
    return(NULL)
  }
  
  # Harmonize column names
  all_columns <- union(names(main_df), names(df_to_join))
  main_df[setdiff(all_columns, names(main_df))] <- NA
  df_to_join[setdiff(all_columns, names(df_to_join))] <- NA
  
  # Bind rows and add Load_Date
  result_df <- rbind(main_df, df_to_join) %>%
    mutate(Load_Date = Sys.Date())
  
  message("Rows bound. Resulting data frame length: ", nrow(result_df))
  return(result_df)
}

# 3. Update KPI Table ----------------------------------------------------------

# Filter existing KPI data
KPI_data <- joined_tables[[5]] %>%
  filter(!`Workforce KPI` %in% c(
    "All Staff Turnover  - 12 month rolling rate %",
    "Sickness Absence Rate  - 12 month rolling %"
  ))

# Read sickness and turnover data
Sickness_data <- read_excel(file.path(directory_path, "data/workforce_returns/Staff_Turnover_Sickness_Rates.xlsx"),
                            sheet = "Staff Sickness Rate")
Turnover_data <- read_excel(file.path(directory_path, "data/workforce_returns/Staff_Turnover_Sickness_Rates.xlsx"),
                            sheet = "Staff Turnover Rate")

# Combine and transform sickness and turnover data
Sickness_Turnover <- bind_rows(
  Sickness_data %>% mutate(`Workforce KPI` = "Sickness Absence Rate  - 12 month rolling %",
                           Maincode = "KPI0140",
                           `Reference Sheet` = "Staff Sickness Rate"),
  Turnover_data %>% mutate(`Workforce KPI` = "All Staff Turnover  - 12 month rolling rate %",
                           Maincode = "KPI0100",
                           `Reference Sheet` = "Staff Turnover Rate")
) %>%
  pivot_longer(names_to = "Provider", cols = 2:6, values_to = "Value") %>%
  mutate(
    Yearmonth = as.integer(str_remove(str_sub(as.character(Date), 1, 7), "-")),
    Type = case_when(
      `Workforce KPI` == "All Staff Turnover  - 12 month rolling rate %" ~ "Turnover Rate",
      `Workforce KPI` == "Sickness Absence Rate  - 12 month rolling %" ~ "Sickness Rate"
    ),
    LoadDate = Sys.Date()
  ) %>%
  select(Maincode, Yearmonth, Provider, Value, LoadDate, `Workforce KPI`, `Reference Sheet`)

# Update KPI table
updated_KPI <- bind_rows(KPI_data, Sickness_Turnover) %>%
  filter(Yearmonth <= latest_month)

dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1236_KPI")
dbWriteTable(conn = sql_connection, name = "##BSOL_1236_KPI", value = updated_KPI, overwrite = TRUE)

# 4. Sickness & Turnover Conditional Reports -----------------------------------

# Read planned activity data
planned_data <- read_excel(file.path(directory_path, "Reference/FY24_25_Planned_Activity.xlsx"),
                           sheet = "Planned Sickness & Turnover") %>%
  mutate(Yearmonth = as.integer(Yearmonth))

# Generate sickness and turnover report with variance
Sickness_Turnover_Report <- Sickness_Turnover %>%
  select(Provider, Yearmonth, `Reference Sheet`, Value) %>%
  rename(Actual = Value) %>%
  left_join(
    planned_data %>% select(-Date),
    by = c("Provider", "Yearmonth", "Reference Sheet" = "Type"),
    relationship = "many-to-many"
  ) %>%
  mutate(
    Variance = Actual - Plan,
    `% Difference` = Variance / Plan
  ) %>%
  pivot_longer(cols = c(Actual, Plan, Variance, `% Difference`),
               names_to = "Metric", values_to = "Value") %>%
  filter(Yearmonth <= latest_month)

# Write sickness & turnover report to SQL
dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1236_Sickness_Turnover")
dbWriteTable(conn = sql_connection, name = "##BSOL_1236_Sickness_Turnover", 
             value = Sickness_Turnover_Report, overwrite = TRUE)

################################################################################
