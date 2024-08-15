# Specify paths ----

source("analysis/post_release/specify_paths.R")
source("analysis/post_release/utility.R")

for (cohort in c("winter2019","winter2021")) {
  
  # Read in Table 1 ----
  
  path_table1 <- get(paste0("path_table1_",cohort))
  tmp <- data.table::fread(path_table1, data.table = FALSE)
  characteristics <- unique(tmp$characteristic)
  tmp <- tmp[,c("characteristic","category",colnames(tmp)[grepl("count_",colnames(tmp))])]
  tmp$count_pneustrep_rounded <- NULL
  
  # Add percentages to counts ----
  
  for (i in c("all","covid","flu","pneu","rsv")) {
    
    if ((i=="covid" & cohort=="winter2019")==FALSE) {
      
      tmp$new <- ifelse(tmp$characteristic=="N=",
                        tmp[,paste0("count_",i,"_rounded")],
                        paste0(tmp[,paste0("count_",i,"_rounded")], " (",display(100*(tmp[,paste0("count_",i,"_rounded")]/tmp[1,paste0("count_",i,"_rounded")])),")"))
      
      tmp$new <- ifelse(tmp$new=="NA (NA)","0 (0.00)",tmp$new)
      names(tmp)[names(tmp) == "new"] <- i
      
    }
    
    tmp[,paste0("count_",i,"_rounded")] <- NULL
    
  }
  
  # Save table1 ----
  
  data.table::fwrite(tmp, paste0("output/post_release/table1_",cohort,".csv"))
  
}