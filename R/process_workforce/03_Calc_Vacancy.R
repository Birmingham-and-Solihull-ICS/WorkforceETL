################################################################################
# Script to calculate vacancy rates, staffing plans vs actuals, and HCSW data.
################################################################################

# 1. Define Input Data ---------------------------------------------------------

WTE_overall <- joined_tables[[1]]   # Overall WTE data
WTE_staff_group <- joined_tables[[2]]  # Staff group data
Vacancy <- joined_tables[[6]]       # Vacancy data
HCSW_table <- joined_tables[[12]]   # HCSW table

# 2. Vacancy Rate Calculations ------------------------------------------------

## Function to calculate vacancy rates
calculate_vacancy <- function(substantive_data, vacancy_data, staff_group_filter, type_label) {
  substantive <- substantive_data %>%
    filter(`Staff Group` == staff_group_filter, `Staff Type` == "Total") %>%
    select(Provider, Yearmonth, Substantive = Value)
  
  vacancy <- vacancy_data %>%
    filter(`Staff Group` == staff_group_filter, `Staff Type` == "Total") %>%
    select(Provider, Yearmonth, Vacancy = Value)
  
  result <- inner_join(substantive, vacancy, by = c("Provider", "Yearmonth")) %>%
    mutate(Total = Vacancy + Substantive,
           Rate = Vacancy / Total,
           Type = type_label)
  return(result)
}

# 2.1 Main Vacancies
Main_Vacancy <- calculate_vacancy(
  WTE_overall %>% filter(`Summary Staff WTE Detail` == "Total WTE Substantive Staff"),
  Vacancy %>% filter(`Staff Group` == "All Roles"),
  "All Roles", "Main Vacancy"
)

# 2.2 Nursing & Midwifery Vacancies
Nursing_Vacancy <- calculate_vacancy(
  WTE_staff_group,
  Vacancy,
  "Nursing, midwifery and HV", "Nursing, Midwifery and HV Vacancy"
)

# 2.3 BSOL System-wide Vacancies
aggregate_vacancies <- function(data, value_col, label) {
  data %>%
    group_by(Yearmonth) %>%
    summarise(Value = sum({{ value_col }})) %>%
    mutate(Provider = "BSOL Total ICS")
}

BSOL_Vacancy <- inner_join(
  aggregate_vacancies(WTE_overall, Value, "Total WTE Substantive Staff"),
  aggregate_vacancies(Vacancy, Value, "All Roles"),
  by = c("Provider", "Yearmonth")
) %>%
  mutate(Total = Value.x + Value.y,
         Rate = Value.y / Total,
         Type = "Main Vacancy") %>%
  select(Provider, Yearmonth, Vacancy = Value.y, Substantive = Value.x, Total, Rate, Type)

# 2.4 BSOL Nursing & Midwifery Vacancies
BSOL_Nursing_Vacancy <- inner_join(
  aggregate_vacancies(WTE_staff_group %>% filter(`Staff Group` == "Nursing, midwifery and HV"), Value, "Nursing WTE"),
  aggregate_vacancies(Vacancy %>% filter(`Staff Group` == "Nursing, midwifery and HV"), Value, "Nursing Vacancy"),
  by = c("Provider", "Yearmonth")
) %>%
  mutate(Total = Value.x + Value.y,
         Rate = Value.y / Total,
         Type = "Nursing, Midwifery and HV Vacancy") %>%
  select(Provider, Yearmonth, Vacancy = Value.y, Substantive = Value.x, Total, Rate, Type)

# Combine all vacancy calculations
joined_vacancies <- bind_rows(Main_Vacancy, Nursing_Vacancy, BSOL_Vacancy, BSOL_Nursing_Vacancy) %>%
  mutate_all(~ifelse(is.na(.), NA_real_, .))

# 3. Write Vacancy Data to SQL -------------------------------------------------

dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1236_Vacancy_Rate_Calc")
dbWriteTable(sql_connection, "##BSOL_1236_Vacancy_Rate_Calc", joined_vacancies, overwrite = TRUE)

# 4. Planned vs Actual Staffing Calculations -----------------------------------

## Function to summarize planned staffing data
get_plan <- function(planned_data, type, BSOL = FALSE) {
  result <- planned_data %>%
    filter(if (!BSOL) Type == type else TRUE) %>%
    group_by(Yearmonth) %>%
    summarise(Plan = sum(Plan, na.rm = TRUE)) %>%
    mutate(Provider = ifelse(BSOL, "BSOL Total ICS", Provider)) %>%
    select(Yearmonth, Provider, Plan)
  return(result)
}

## Function to compare actual vs planned data
compare_plan_actual <- function(actual, plan) {
  actual %>%
    full_join(plan, by = c("Provider", "Yearmonth")) %>%
    mutate(Difference_WTE = Substantive - Plan,
           Percentage_Difference = Difference_WTE / Plan) %>%
    select(Yearmonth, Provider, Substantive, Plan, Difference_WTE, Percentage_Difference)
}

# Main Staffing vs Plan
planned_data <- read_xlsx(file.path(directory_path, "Reference/FY24_25_Planned_Activity.xlsx"),
                          sheet = "Planned Staff") %>%
  mutate(Yearmonth = as.integer(Yearmonth))

main_plan <- get_plan(planned_data, "Substantive Plan")
main_actual <- compare_plan_actual(Main_Vacancy, main_plan)

# Combine all planned vs actual results
final_plan <- bind_rows(main_actual) %>%
  mutate(Type = "Staffing Post Vs Plan Substantive")

# Write to SQL
dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1236_Staffing_Actual_Plan")
dbWriteTable(sql_connection, "##BSOL_1236_Staffing_Actual_Plan", final_plan, overwrite = TRUE)

# 5. HCSW Vacancy Rate ---------------------------------------------------------

HCSW_Vacancy_Rate <- HCSW_table %>%
  filter(`Measure Detail` %in% c("Health Care Support Worker reported Vacancy rate",
                                 "Maternity Support Worker reported Vacancy rate")) %>%
  filter(Yearmonth <= latest_month)

# Write HCSW Vacancy Rate to SQL
dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1236_HCSW_Vacancy_Rate")
dbWriteTable(sql_connection, "##BSOL_1236_HCSW_Vacancy_Rate", HCSW_Vacancy_Rate, overwrite = TRUE)

# Update HCSW table to exclude vacancy rates
HCSW_table_updated <- HCSW_table %>%
  filter(!`Measure Detail` %in% c("Health Care Support Worker reported Vacancy rate",
                                  "Maternity Support Worker reported Vacancy rate"))

dbExecute(sql_connection, "DROP TABLE IF EXISTS ##BSOL_1236_HCSW")
dbWriteTable(sql_connection, "##BSOL_1236_HCSW", HCSW_table_updated, overwrite = TRUE)

################################################################################
