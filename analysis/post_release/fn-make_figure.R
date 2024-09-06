make_figure <- function(name, hr, cohort, subgroup, infection, outcome, model, adjustment) {
  
  # Specify null_value ----
  
  if (hr==TRUE) {
    null_value <- 1
  } else {
    null_value <- 0
  }
  
  # Read in data ----
  
  tmp <- data.table::fread(path_results, select = c("cohort","subgroup","outcome","model","adjustment","var","est","lci","uci"))
  ref <- data.table::fread("lib/labels.csv")
  
  # Separate infection and outcome ----
  
  tmp <- tidyr::separate(tmp, outcome, into = c("infection","outcome"), sep = "_")
  
  # Filter ----
  
  tmp <- tmp[tmp$cohort %in% cohort & 
               tmp$subgroup %in% subgroup &
               tmp$infection %in% infection &
               tmp$outcome %in% outcome &
               tmp$model %in% model,]
  
  # Convert age coefficients to be per 10 years ----
  
  tmp$est <- ifelse(tmp$var=="cov_num_age", tmp$est^10, tmp$est)
  tmp$lci <- ifelse(tmp$var=="cov_num_age", tmp$est^10, tmp$lci)
  tmp$uci <- ifelse(tmp$var=="cov_num_age", tmp$est^10, tmp$uci)
  
  # Add female ----
  
  tmp2 <- unique(tmp[,c("cohort","subgroup","infection","outcome","model","adjustment")])
  tmp2$var <- "cov_bin_female"
  tmp2$est <- null_value
  tmp2$lci <- null_value
  tmp2$uci <- null_value
  tmp <- rbind(tmp,tmp2)
  
  # Add labels ----
  
  tmp <- merge(tmp, ref, by = "var")
  tmp <- tmp[order(tmp$order),]
  tmp$category <- factor(tmp$category, levels = unique(tmp$category))
  
  # Sort labels ----
  
  tmp$label <- ifelse(tmp$label==tmp$category, "", tmp$label)
  tmp <- tmp[tmp$label!="Missing",]
  tmp$label <- factor(tmp$label, levels = unique(tmp$label))
  
  # Rename infections ----
  
  tmp$infection <- ifelse(tmp$infection=="covid","COVID-19",tmp$infection)
  tmp$infection <- ifelse(tmp$infection=="flu","Influenza",tmp$infection)
  tmp$infection <- ifelse(tmp$infection=="pneu","Pneumonia",tmp$infection)
  tmp$infection <- ifelse(tmp$infection=="pneustrep","Pneumonia (Streptococcus pneumoniae)",tmp$infection)
  tmp$infection <- ifelse(tmp$infection=="rsv","RSV",tmp$infection)
  
  # Plot ----
  
  if (hr==TRUE) {
    
    x_min <- 2^-2
    x_max <- 2^4
    
    tmp$uci_trim <- ifelse(tmp$uci>x_max, x_max, tmp$uci)
    tmp$lci_trim <- ifelse(tmp$lci<x_min, x_min, tmp$lci)
    
    ggplot2::ggplot(data = tmp[tmp$adjustment==adjustment,], mapping = ggplot2::aes(x = est, y = forcats::fct_rev(label), color = infection)) +
      ggplot2::geom_vline(xintercept=null_value, col = "dark grey") +
      ggplot2::geom_point(shape = 15, size = 0.5) +
      ggplot2::geom_linerange(ggplot2::aes(xmin = lci_trim, xmax = uci_trim), alpha = 0.5, size = 1) +
      ggplot2::scale_x_continuous(transform = "log", 
                                  breaks = 2^(seq(-100,100,1)), 
                                  label = display(2^(seq(-100,100,1))), 
                                  lim = c(x_min,x_max)) +
      ggplot2::labs(x = "Hazard ratio and 95% confidence interval", y = "") + 
      ggplot2::scale_color_manual(breaks = c("COVID-19","Influenza","Pneumonia","Pneumonia (Streptococcus pneumoniae)","RSV"),
                                  values = c("#377eb8","#4daf4a","#e41a1c","#ff7f00","#984ea3")) +
      ggplot2::theme_minimal() +
      ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                     panel.grid.minor = ggplot2::element_blank(),
                     legend.position = "none",
                     strip.text = ggplot2::element_text(size=8),
                     axis.text = ggplot2::element_text(size=8),
                     text = ggplot2::element_text(size=8),
                     strip.text.y.left = ggplot2::element_text(angle = 0, hjust = 1),
                     strip.placement = "outside") +
      ggplot2::facet_grid(rows = dplyr::vars(category), cols = dplyr::vars(infection), scales = "free_y", space = "free_y", switch = "y")

  } else {
    
    x_min <- -25
    x_max <- 25
    
    tmp$uci_trim <- ifelse(tmp$uci>x_max, x_max, tmp$uci)
    tmp$lci_trim <- ifelse(tmp$lci<x_min, x_min, tmp$lci)
    
    ggplot2::ggplot(data = tmp[tmp$adjustment==adjustment,], mapping = ggplot2::aes(x = est, y = forcats::fct_rev(label), color = infection)) +
      ggplot2::geom_vline(xintercept=null_value, col = "dark grey") +
      ggplot2::geom_point(shape = 15, size = 0.5) +
      ggplot2::geom_linerange(ggplot2::aes(xmin = lci_trim, xmax = uci_trim), alpha = 0.5, size = 1) +
      ggplot2::scale_x_continuous(breaks = seq(-100,100,5), 
                                  label = seq(-100,100,5), 
                                  lim = c(x_min,x_max)) +
      ggplot2::labs(x = "Estimate and 95% confidence interval", y = "") + 
      ggplot2::scale_color_manual(breaks = c("COVID-19","Influenza","Pneumonia","Pneumonia (Streptococcus pneumoniae)","RSV"),
                                  values = c("#377eb8","#4daf4a","#e41a1c","#ff7f00","#984ea3")) +
      ggplot2::theme_minimal() +
      ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                     panel.grid.minor = ggplot2::element_blank(),
                     legend.position = "none",
                     strip.text = ggplot2::element_text(size=8),
                     axis.text = ggplot2::element_text(size=8),
                     text = ggplot2::element_text(size=8),
                     strip.text.y.left = ggplot2::element_text(angle = 0, hjust = 1),
                     strip.placement = "outside") +
      ggplot2::facet_grid(rows = dplyr::vars(category), cols = dplyr::vars(infection), scales = "free_y", space = "free_y", switch = "y")
    
  }

  # Save plot ----
  
  ggplot2::ggsave(filename = paste0("output/post_release/figure",name,".jpeg"),
                  dpi = 300, height = 210, width = 297, unit = "mm", scale = 1)
  
  # Make table3s ----
  
  table3 <- tmp[tmp$infection %in% unique(tmp$infection),c("order","infection","category","label","adjustment","est","lci","uci")]
  table3$estimate <- ifelse(grepl("(ref)",table3$label),"1.00 (ref)",paste0(display(table3$est)," (",display(table3$lci)," to ",display(table3$uci),")"))
  table3 <- tidyr::pivot_wider(table3, id_cols = c("order","category","label"), names_from = c("infection","adjustment"), values_from = estimate)
  order_table3 <- c(paste0("COVID-19",c("_min","_max")),paste0("Influenza",c("_min","_max")),paste0("Pneumonia",c("_min","_max")),paste0("RSV",c("_min","_max")))
  order_table3 <- intersect(order_table3,colnames(table3))
  table3 <- table3[order(table3$order),c("category","label",order_table3)]
  data.table::fwrite(table3,paste0("output/post_release/table3_alladj_figure",name,".csv"))
  
  table3 <- table3[,colnames(table3)[!grepl("_min",colnames(table3))]]
  colnames(table3) <- gsub("_max","",colnames(table3))
  data.table::fwrite(table3,paste0("output/post_release/table3_maxadj_figure",name,".csv"))
  
}