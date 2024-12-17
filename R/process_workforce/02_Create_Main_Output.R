################################################################################
# Script to join raw data with reference data and write to database tables
################################################################################

# 1. Read the main data (historic and current data) ----------------------------
data <- dbGetQuery(sql_connection, 
                   "SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main]")

# 2. Define the path for reference data ----------------------------------------
reference_path <- file.path(directory_path, "data/workforce_returns/FY24_25_Occupation_Reference.xlsx")

# 3. Function to join raw data with reference sheets ---------------------------
join_data <- function(data, reference_path) {
  # Read all sheets from the reference file into a list of data frames
  reference_list <- map(excel_sheets(reference_path), 
                        ~ read_excel(reference_path, sheet = .x))
  
  # Join raw data with each reference sheet
  table_list <- map(reference_list, function(ref_data) {
    data %>%
      inner_join(ref_data, by = "Maincode", relationship = "many-to-many") %>%
      mutate(Value = ifelse(!is.na(Value), as.numeric(Value), 0)) %>% 
      replace_na(list(Value = 0))
  })
  
  return(table_list)
}

# 4. Call the function ---------------------------------------------------------
joined_tables <- join_data(data, reference_path)

# Combine bank and agency staff tables into a single table
joined_tables[[13]] <- bind_rows(joined_tables[[3]], joined_tables[[4]])

for(i in 1:length(joined_tables)){
  print(unique(joined_tables[[i]]$`Reference Sheet`))
}


# joined_tables[[1]] = Overall
# joined_tables[[2]] = Staff_Group
# joined_tables[[3]] = Bank_Staff
# joined_tables[[4]] = Agency_Staff
# joined_tables[[5]] = KPI
# joined_tables[[6]] = Vacancy
# joined_tables[[7]] = International_Recruitment
# joined_tables[[8]] = AHP_IR
# joined_tables[[9]] = Maternity
# joined_tables[[10]] = PNA
# joined_tables[[11]] = PMA
# joined_tables[[12]] = HCSW
# joined_tables[[13]] = Bank_Agency_Staff

# Default all values in vacancy table as positives -----------------------------

joined_tables[[6]] <- joined_tables[[6]] %>%
  mutate(Value = abs(Value))

# #8. Write global temporary tables ----------------------------------------------
print("Writing global temp tables...")


temp_table_names <- c("##BSOL_1236_Overall", "##BSOL_1236_Staff_Group", "##BSOL_1236_Bank_Staff", "##BSOL_1236_Agency_Staff",
                      "##BSOL_1236_KPI", "##BSOL_1236_Vacancy", "##BSOL_1236_IR", "##BSOL_1236_AHP_IR", "##BSOL_1236_Maternity",
                      "##BSOL_1236_PNA", "##BSOL_1236_PMA", "##BSOL_1236_HCSW", "##BSOL_1236_Bank_Agency")



for(i in seq_along(temp_table_names)){
  dbExecute(sql_connection, paste0("DROP TABLE IF EXISTS ", temp_table_names[i]))

  dbWriteTable(conn = sql_connection, name = temp_table_names[i],
               value = joined_tables[[i]],
               overwrite = TRUE)
}

print("Finished writing global temp tables!")

