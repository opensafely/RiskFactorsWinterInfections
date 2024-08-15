
make_table1 <- function(winter2019, winter2021, i) {
  
  keep <- c("characteristic","category",
            paste0("count_",i,"_rounded"),
            paste0("percent_",i,"_rounded"))
  
  table1a <- winter2019[,c("characteristic","category",
                           paste0("count_",i,"_rounded"),
                           paste0("percent_",i,"_rounded"))]
  
  colnames(table1a) <- gsub(paste0("_",i,"_rounded"),"",colnames(table1a))
  table1a$winter2019 <- ifelse(table1a$characteristic=="N=", table1a$count, paste0(table1a$count," (",display(table1a$percent),")"))
  table1a[,c("count","percent")] <- NULL
  
  table1b <- winter2021[,c("characteristic","category",
                           paste0("count_",i,"_rounded"),
                           paste0("percent_",i,"_rounded"))]
  
  colnames(table1b) <- gsub(paste0("_",i,"_rounded"),"",colnames(table1b))
  table1b$winter2021 <- ifelse(table1b$characteristic=="N=", table1b$count, paste0(table1b$count," (",display(table1b$percent),")"))
  table1b[,c("count","percent")] <- NULL
  
  table1 <- merge(table1a, table1b, by = c("characteristic","category"))
  
  return(table1)
  
}