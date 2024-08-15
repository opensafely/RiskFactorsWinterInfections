# Specify paths ----

source("analysis/post_release/specify_paths.R")
source("analysis/post_release/utility.R")
source("analysis/post_release/fn-make_table1.R")

# Save characteristics ordering ----

tmp <- data.table::fread(path_table1_winter2019)
characteristics <- unique(tmp$characteristic)
rm(tmp)

# Read in Table 1s ----

winter2019 <- data.table::fread(path_table1_winter2019, data.table = FALSE)
winter2021 <- data.table::fread(path_table1_winter2021, data.table = FALSE)

# Convert to factor ----

winter2019$characteristic <- factor(winter2019$characteristic, levels = characteristics)
winter2021$characteristic <- factor(winter2021$characteristic, levels = characteristics)

# Make each table 1 ----

for (i in c("all","covid","flu","pneu","pneustrep","rsv")) {
  
  table1 <- make_table1(winter2019, winter2021, i = "all")
  
  if (i!="all") {
    
    table1 <- dplyr::rename(table1, 
                            "winter2019_all" = "winter2019",
                            "winter2021_all" = "winter2021")
    
    table1_i <- make_table1(winter2019, winter2021, i = i)
    
    table1 <- merge(table1, table1_i, by = c("characteristic","category"))
    
  }
  
  table1 <- table1[order(table1$characteristic),
                   c("characteristic","category",
                     colnames(table1)[grepl("winter2019",colnames(table1))],
                     colnames(table1)[grepl("winter2021",colnames(table1))])]
  
  data.table::fwrite(table1, 
                     paste0("output/post_release/table1_",i,".csv"),
                     row.names = FALSE)
  
}
