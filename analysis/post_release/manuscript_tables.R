# Specify paths ----

source("analysis/post_release/specify_paths.R")
source("analysis/post_release/utility.R")
source("analysis/post_release/table1.R")

# Make manuscript table 1 ---

winter2019 <- data.table::fread("output/post_release/table1_winter2019.csv")
N_winter2019 <- as.numeric(winter2019[winter2019$category=="All",all])
winter2021 <- data.table::fread("output/post_release/table1_winter2021.csv")
N_winter2021 <- as.numeric(winter2021[winter2021$category=="All",all])

winter2019 <- dplyr::rename(winter2019,
                            "all_winter2019" = "all",
                            "flu_winter2019" = "flu",
                            "pneu_winter2019" = "pneu",
                            "rsv_winter2019" = "rsv")

winter2021 <- dplyr::rename(winter2021,
                            "all_winter2021" = "all",
                            "covid_winter2021" = "covid",
                            "flu_winter2021" = "flu",
                            "pneu_winter2021" = "pneu",
                            "rsv_winter2021" = "rsv")

table1 <- merge(winter2019, winter2021, by = c("category","characteristic","order"))

table1 <- table1[order(table1$order),c("category","characteristic",
                                       "all_winter2019","flu_winter2019","pneu_winter2019","rsv_winter2019",
                                       "all_winter2021","covid_winter2021","pneu_winter2021")]

# Remove order from cohort table 1s ----

for (cohort in c("winter2019","winter2021")) {
  tmp <- data.table::fread(paste0("output/post_release/table1_",cohort,".csv"))
  tmp$order <- NULL
  data.table::fwrite(tmp, paste0("output/post_release/table1_",cohort,".csv"))
}

# Make manuscript table 1 add-on ---

table2 <- NULL

for (cohort in c("winter2019","winter2021")) {
  
  path_table2 <- get(paste0("path_table2_",cohort))
  
  tmp <- data.table::fread(path_table2,
                           select = c("infection",
                                      "eventcount_risktime_adm_r",
                                      "eventcount_risktime_readm_r",
                                      "eventcount_risktime_death_r"))
  
  tmp <- tidyr::pivot_longer(tmp,
                             cols = c("eventcount_risktime_adm_r",
                                      "eventcount_risktime_readm_r",
                                      "eventcount_risktime_death_r"))
  
  tmp$name <- gsub("_r","",gsub("eventcount_risktime_","",tmp$name))
  tmp$value <- as.numeric(gsub("\\/.*","",tmp$value))
  tmp$value <- paste0(tmp$value," (", display(100*tmp$value/N_winter2019), ")")
  tmp$cohort <- cohort
  table2 <- rbind(table2, tmp)
}

table2 <- tidyr::pivot_wider(table2, names_from = c("infection","cohort"), values_from = "value")

table2$characteristic <- ""
table2$characteristic <- ifelse(table2$name=="adm","Hospital admissions",table2$characteristic)
table2$characteristic <- ifelse(table2$name=="readm","Hospital readmissions",table2$characteristic)
table2$characteristic <- ifelse(table2$name=="death","Deaths",table2$characteristic)
table2$category <- "Outcomes"
table2$all_winter2019 <- ""
table2$all_winter2021 <- ""

table2 <- table2[,colnames(table1)]

# Save final table ----

manuscript_table1<- rbind(table1[1:26,], table2)
data.table::fwrite(manuscript_table1, paste0("output/post_release/manuscript_table1.csv"))
