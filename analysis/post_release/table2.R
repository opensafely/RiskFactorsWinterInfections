# Specify paths ----

source("analysis/post_release/specify_paths.R")
source("analysis/post_release/utility.R")

for (cohort in c("winter2019","winter2021")) {
  
  # Read in Table 2 ----
  
  path_table2 <- get(paste0("path_table2_",cohort))
  tmp <- data.table::fread(path_table2)
  
  # Make variables
  
  tmp$median_stay_r <- paste0(tmp$median_stay_r," (",tmp$iqr_stay_r,")")
  tmp$iqr_stay_r <- NULL
  tmp$incidence_adm_r <- round(tmp$incidence_adm_r)
  tmp$incidence_readm_r <- round(tmp$incidence_readm_r)
  tmp$incidence_death_r <- round(tmp$incidence_death_r)
  
  # Transpose data ----
  
  tmp <- data.table::transpose(tmp, keep.names = "value")
  colnames(tmp) <- as.character(tmp[1,])
  tmp <- data.frame(tmp)
  tmp <- tmp[2:nrow(tmp),]
  
  #
  
  tmp$infection <- substr(tmp$infection, 1, nchar(tmp$infection)-2)
  tmp$infection <- gsub("eventcount_risktime","eventcount-risktime",tmp$infection)
  tmp <- tidyr::separate(tmp, infection, into = c("Statistic","Outcome"), sep = "_")
  
  # Rename infections ----
  
  tmp$pneustrep <- NULL
  tmp <- dplyr::rename(tmp,
                       "COVID-19" = "covid",
                       "Influenza" = "flu",
                       "Pneumonia" = "pneu",
                       "RSV" = "rsv")

  # Rename outcomes ----
  
  tmp$Outcome <- ifelse(tmp$Outcome=="adm","Hospital admission",tmp$Outcome)
  tmp$Outcome <- ifelse(tmp$Outcome=="readm","Readmission to hospital within 30 days of discharge",tmp$Outcome)
  tmp$Outcome <- ifelse(tmp$Outcome=="death","Death",tmp$Outcome)
  tmp$Outcome <- ifelse(tmp$Outcome=="stay","Length of hospital admission",tmp$Outcome)
 
  # Rename statistics ----
  
  tmp$Statistic <- ifelse(tmp$Statistic=="eventcount-risktime","Event/person-years",tmp$Statistic)
  tmp$Statistic <- ifelse(tmp$Statistic=="incidence","Incidence rate",tmp$Statistic)
  tmp$Statistic <- ifelse(tmp$Statistic=="median","Median (IQR)",tmp$Statistic)
  
  # Make factors ----
  
  tmp$Statistic <- factor(tmp$Statistic, levels = c("Event/person-years","Incidence rate","Median (IQR)"))
  tmp$Outcome <- factor(tmp$Outcome, levels = c("Hospital admission",
                                                "Length of hospital admission",
                                                "Readmission to hospital within 30 days of discharge",
                                                "Death"))
  
  # Order variables ----
  
  if (cohort=="Winter2019") {
    tmp <- tmp[order(tmp$Outcome,tmp$Statistic),c("Outcome","Statistic","Influenza","Pneumonia","RSV")]
  } else {
    tmp <- tmp[order(tmp$Outcome,tmp$Statistic),c("Outcome","Statistic","COVID-19","Influenza","Pneumonia","RSV")]
  }
  
  # Save ----
  
  data.table::fwrite(tmp,paste0("output/post_release/table2_",cohort,".csv"))

}