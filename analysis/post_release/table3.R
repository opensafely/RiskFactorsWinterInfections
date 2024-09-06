# Start excel workbook ----

wb <- openxlsx::createWorkbook()

# Add table3s to workbook ----

for (cohort in c("winter2021","winter2019")) {
  for (outcome in c("adm","stay","readm","death")) {
    for (infection in c("COVID-19","Influenza","Pneumonia","RSV")) {

      
      table3 <- paste0("output/post_release/table3_",cohort,"_",outcome,"_",infection,".csv")
      
      if (table3 %in% list.files(path = "output/post_release", full.names = TRUE)) {
        tmp <- data.table::fread(table3, data.table = FALSE)
        openxlsx::addWorksheet(wb, paste(cohort, outcome, infection, sep = "_"))
        openxlsx::writeData(wb, paste(cohort, outcome, infection, sep = "_"), tmp)
      }
      
    }
  }
}

# Save excel workbook ----

openxlsx::saveWorkbook(wb, file = "output/post_release/table3.xlsx", overwrite = TRUE)