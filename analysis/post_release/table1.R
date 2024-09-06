# Specify paths ----

source("analysis/post_release/specify_paths.R")
source("analysis/post_release/utility.R")

# Load reference data ----

ref <- data.table::fread("lib/labels.csv", select = c("table1","category","label","order"))

# Repeat for each cohort ----

for (cohort in c("winter2019","winter2021")) {
  
  # Read in Table 1 ----
  
  path_table1 <- get(paste0("path_table1_",cohort))
  tmp <- data.table::fread(path_table1, data.table = FALSE)
  characteristics <- unique(tmp$characteristic)
  tmp$table1 <- sub("\\s+$", "", paste(tmp$characteristic,tmp$category))
  tmp <- tmp[,c("table1",colnames(tmp)[grepl("count_",colnames(tmp))])]
  tmp$count_pneustrep_rounded <- NULL
  tmp <- merge(tmp, ref, by = "table1")
  tmp$table1 <- NULL
  tmp <- dplyr::rename(tmp,"characteristic" = "label")
  
  # Add percentages to counts ----
  
  for (i in c("all","covid","flu","pneu","rsv")) {
    
    if ((i=="covid" & cohort=="winter2019")==FALSE) {
      
      tmp$new <- ifelse(tmp$category=="All",
                        tmp[,paste0("count_",i,"_rounded")],
                        paste0(tmp[,paste0("count_",i,"_rounded")], " (",display(100*(tmp[,paste0("count_",i,"_rounded")]/tmp[tmp$category=="All",paste0("count_",i,"_rounded")])),")"))
      
      tmp$new <- ifelse(tmp$new=="NA (NA)","0 (0.00)",tmp$new)
      names(tmp)[names(tmp) == "new"] <- i
      
    }
    
    tmp[,paste0("count_",i,"_rounded")] <- NULL
    
  }
  
  # Final formatting ----
  
  tmp <- tmp[order(tmp$order),]
  tmp$characteristic <- gsub(" \\(ref\\)","",tmp$characteristic)
  
  # Save table1 ----
  
  data.table::fwrite(tmp, paste0("output/post_release/table1_",cohort,".csv"))
  
}