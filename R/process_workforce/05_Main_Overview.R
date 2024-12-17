################################################################################
# Script to Generate Main Overview Metrics and Write to SQL Table
################################################################################

# 1. Define Input Variables ----------------------------------------------------

metric <- c("Substantive Staff In Post", "Bank Usage", "Agency Usage", 
            "Vacancies", "Vacancy Rate", "Sickness Rate", "Turnover Rate", 
            "Total Staff In Post")

staffGroup <- c("All Staff", "Ambulance Service Staff", "Any Other Staff", 
                "Clinical Support", "Medical and dental", 
                "NHS infrastructure support", "Nursing, midwifery and HV", 
                "Scientific, therapeutic and technical")

system <- c("ICS", "UHB", "BWCH", "ROH", "BCHC", "BSMHFT")

period <- seq(from = as.Date("2021-04-01"), to = as.Date("2025-03-01"), by = "month") %>%
  str_sub(1, 7) %>%
  str_replace_all("-", "") %>%
  as.integer()

combinations <- expand.grid(Metric = metric,
                            `Staff Group` = staffGroup,
                            System = system,
                            Period = period,
                            stringsAsFactors = FALSE)

# 2. Function: Update Metrics --------------------------------------------------

update_metric <- function(data, metric_filter, join_table, join_conditions, filters = NULL, group_by = NULL) {
  combinations %>%
    filter(Metric == metric_filter, filters) %>%
    left_join(
      join_table %>%
        select(all_of(join_conditions$select_cols)) %>%
        { if (!is.null(filters)) filter(., filters) else . } %>%
        { if (!is.null(group_by)) group_by(across(all_of(group_by))) %>%
            summarise(Value = sum(Value), .groups = 'drop') else . },
      by = join_conditions$by
    )
}

# 3. Generate Metrics ----------------------------------------------------------

# All Staff Metrics
metric1 <- update_metric("Substantive Staff In Post", joined_tables[[1]], 
                         list(select_cols = c("Yearmonth", "Provider", "Value", "Summary Staff WTE Detail"),
                              by = c("System" = "Provider", "Period" = "Yearmonth")),
                         filters = `Summary Staff WTE Detail` == "Total WTE Substantive Staff")

metric2 <- update_metric("Bank Usage", joined_tables[[13]], 
                         list(select_cols = c("Yearmonth", "Provider", "Value", "Bank/Agency", "Staff Type"),
                              by = c("System" = "Provider", "Period" = "Yearmonth")),
                         filters = `Bank/Agency` == "Bank" & `Staff Type` == "Total",
                         group_by = c("Yearmonth", "Provider"))

metric3 <- update_metric("Agency Usage", joined_tables[[13]], 
                         list(select_cols = c("Yearmonth", "Provider", "Value", "Bank/Agency", "Staff Type"),
                              by = c("System" = "Provider", "Period" = "Yearmonth")),
                         filters = `Bank/Agency` == "Agency" & `Staff Type` == "Total",
                         group_by = c("Yearmonth", "Provider"))

metric4 <- update_metric("Vacancies", joined_tables[[6]], 
                         list(select_cols = c("Yearmonth", "Provider", "Value", "Staff Group", "Staff Type"),
                              by = c("System" = "Provider", "Period" = "Yearmonth")),
                         filters = `Staff Group` == "All Roles" & `Staff Type` == "Total")

metric5 <- update_metric("Vacancy Rate", joined_vacancies, 
                         list(select_cols = c("Yearmonth", "Provider", "Rate", "Type"),
                              by = c("System" = "Provider", "Period" = "Yearmonth")),
                         filters = Type == "Main Vacancy") %>%
  rename(Value = Rate)

metric6 <- update_metric("Sickness Rate", Sickness_Turnover2, 
                         list(select_cols = c("Yearmonth", "Provider", "Metric", "Reference Sheet", "Value"),
                              by = c("System" = "Provider", "Period" = "Yearmonth")),
                         filters = `Reference Sheet` == "Staff Sickness Rate" & Metric == "Actual")

metric7 <- update_metric("Turnover Rate", Sickness_Turnover2, 
                         list(select_cols = c("Yearmonth", "Provider", "Metric", "Reference Sheet", "Value"),
                              by = c("System" = "Provider", "Period" = "Yearmonth")),
                         filters = `Reference Sheet` == "Staff Turnover Rate" & Metric == "Actual")

metric8 <- update_metric("Total Staff In Post", joined_tables[[1]], 
                         list(select_cols = c("Yearmonth", "Provider", "Value", "Summary Staff WTE Detail"),
                              by = c("System" = "Provider", "Period" = "Yearmonth")),
                         filters = `Summary Staff WTE Detail` == "Total WTE all Staff")

# Other Staff Groups Metrics
metric9 <- update_metric("Substantive Staff In Post", joined_tables[[2]], 
                         list(select_cols = c("Yearmonth", "Provider", "Value", "Staff Group", "Staff Type"),
                              by = c("System" = "Provider", "Period" = "Yearmonth", "Staff Group")),
                         filters = `Staff Type` == "Total" & !`Staff Group` %in% c("Obs & Gynae"),
                         group_by = c("Provider", "Yearmonth", "Staff Group"))

metric10 <- update_metric("Bank Usage", joined_tables[[13]], 
                          list(select_cols = c("Yearmonth", "Provider", "Value", "Bank/Agency", "Staff Group", "Staff Type"),
                               by = c("System" = "Provider", "Period" = "Yearmonth", "Staff Group")),
                          filters = `Bank/Agency` == "Bank" & `Staff Type` == "Total")

metric11 <- update_metric("Agency Usage", joined_tables[[13]], 
                          list(select_cols = c("Yearmonth", "Provider", "Value", "Bank/Agency", "Staff Group", "Staff Type"),
                               by = c("System" = "Provider", "Period" = "Yearmonth", "Staff Group")),
                          filters = `Bank/Agency` == "Agency" & `Staff Type` == "Total")

metric12 <- update_metric("Vacancies", joined_tables[[6]], 
                          list(select_cols = c("Yearmonth", "Provider", "Value", "Staff Group", "Staff Type"),
                               by = c("System" = "Provider", "Period" = "Yearmonth", "Staff Group")),
                          filters = `Staff Type` == "Total" & !`Staff Group` %in% c("All Roles", "Advanced Care", "CC/ICU Nursing"))

# Combine All Metrics
main_overview <- bind_rows(metric1, metric2, metric3, metric4, metric5, metric6,
                           metric7, metric8, metric9, metric10, metric11, metric12)

# 4. Calculate ICS Aggregates --------------------------------------------------

sums_ICS <- main_overview %>%
  filter(System != "ICS") %>%
  group_by(Period, `Staff Group`, Metric) %>%
  summarise(Sum_Value = sum(Value, na.rm = TRUE), .groups = 'drop') %>%
  mutate(Sum_Value = ifelse(Metric %in% c("Vacancy Rate", "Sickness Rate", "Turnover Rate"), NA, Sum_Value))

# Update with ICS values
updated_main_overview <- main_overview %>%
  left_join(sums_ICS, by = c("Period", "Staff Group", "Metric")) %>%
  mutate(Value = ifelse(System == "ICS", Sum_Value, Value)) %>%
  select(-Sum_Value) %>%
  mutate(Date = as.Date(paste0(substr(Period, 1, 4), "-", substr(Period, 5, 6), "-01"))) %>%
  filter(Period <= latest_month)

# 5. Write Final Table to SQL --------------------------------------------------

dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1236_Main_Overview")
dbWriteTable(conn = sql_connection, name = "##BSOL_1236_Main_Overview", 
             value = updated_main_overview, overwrite = TRUE)

################################################################################
