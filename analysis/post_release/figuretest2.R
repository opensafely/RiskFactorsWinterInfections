for (outcome in c("adm","death")) {

  
  name = "test2"
  hr = TRUE
  cohort = c("winter2019","winter2021")
  subgroup = c("main")
  infection = c("covid","flu","pneu","rsv")
  model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem")
  adjustment = "max"
  
  # Specify null_value ----
  
  if (hr==TRUE) {
    null_value <- 1
  } else {
    null_value <- 0
  }
  
  # Read in data ----
  
  tmp <- data.table::fread(path_results, select = c("cohort","subgroup","outcome","model","adjustment","var","est","lci","uci"))
  ref <- data.table::fread("lib/labels.csv")
  ref$label <- ref$shortlabel
  ref$category <- ref$shortcategory
  ref[,c("shortlabel","shortcategory")] <- NULL
  
  # Separate infection and outcome ----
  
  tmp <- tidyr::separate(tmp, outcome, into = c("infection","outcome"), sep = "_")
  
  # Filter ----
  
  # tmp <- tmp[tmp$cohort %in% cohort & 
  #              tmp$subgroup %in% subgroup &
  #              tmp$infection %in% infection &
  #              tmp$outcome %in% outcome &
  #              tmp$model %in% model,]
  
  tmp <- tmp[tmp$subgroup %in% subgroup &
             tmp$outcome %in% outcome &
             tmp$model %in% model,]
  
  tmp <- tmp[!(tmp$infection=="pneustrep"),]
  tmp <- tmp[!(tmp$outcome=="death" & tmp$infection=="rsv"),]
  tmp <- tmp[!(tmp$cohort=="winter2021" & tmp$outcome=="death" & tmp$infection=="pneu"),]
  tmp <- tmp[!(tmp$cohort=="winter2019" & tmp$infection=="covid"),]
  tmp <- tmp[!(tmp$cohort=="winter2021" & tmp$infection=="flu"),]
  tmp <- tmp[!(tmp$cohort=="winter2021" & tmp$infection=="rsv"),]
  
  # Convert age coefficients to be per 10 years ----
  
  tmp$est <- ifelse(tmp$var=="cov_num_age", tmp$est^10, tmp$est)
  tmp$lci <- ifelse(tmp$var=="cov_num_age", tmp$lci^10, tmp$lci)
  tmp$uci <- ifelse(tmp$var=="cov_num_age", tmp$uci^10, tmp$uci)
  
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
  tmp$infection <- factor(tmp$infection, 
                          levels = c("RSV","Influenza","Pneumonia (Streptococcus pneumoniae)","Pneumonia","COVID-19"))
  # Plot ----
  
  x_min <- 2^-2
  x_max <- 2^4
  
  tmp$uci_trim <- ifelse(tmp$uci>x_max, x_max, tmp$uci)
  tmp$lci_trim <- ifelse(tmp$lci<x_min, x_min, tmp$lci)
  
  
  ggplot2::ggplot(data = tmp[tmp$adjustment == adjustment,], 
                  mapping = ggplot2::aes(x = est, y = forcats::fct_rev(label), color = cohort)) +
    ggplot2::geom_vline(xintercept = null_value, col = "dark grey") +
    ggplot2::geom_point(shape = 15, size = 0.5, 
                        position = ggplot2::position_dodge(width=1)) +
    ggplot2::geom_errorbarh(ggplot2::aes(xmin = lci_trim, xmax = uci_trim),  alpha = 0.5, size = 1, height=0,
                            position = ggplot2::position_dodge(width=1)) +
    ggplot2::scale_x_continuous(transform = "log", 
                                breaks = 2^(seq(-100, 100, 1)), 
                                labels = display(2^(seq(-100, 100, 1))), 
                                limits = c(x_min, x_max)) +
    ggplot2::labs(x = "Hazard ratio and 95% confidence interval", y = "", color = "Cohort") + 
    ggplot2::scale_color_manual(breaks = c("winter2019", "winter2021"),
                                labels = c("Winter 2019", "Winter 2021"),
                                values = c("#f1a340", "#998ec3")) +
    ggplot2::theme_minimal() +
    ggplot2::guides(color = ggplot2::guide_legend(nrow = 1)) +
    ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   legend.position = "bottom",
                   legend.text = ggplot2::element_text(size = 8),
                   strip.text = ggplot2::element_text(size = 8),
                   axis.text = ggplot2::element_text(size = 8),
                   text = ggplot2::element_text(size = 8),
                   strip.text.y.left = ggplot2::element_text(angle = 0, hjust = 1),
                   strip.placement = "outside") +
    ggplot2::facet_grid(rows = dplyr::vars(category), 
                        cols = dplyr::vars(infection), 
                        scales = "free_y", 
                        space = "free_y", 
                        switch = "y")
  
  ggplot2::ggsave(filename = paste0("output/post_release/figure_",name,"_",outcome,".jpeg"),
                  dpi = 300, height = 210, width = (297/6)*(2+length(unique(tmp$infection))), unit = "mm", scale = 1)

  
  
  table3 <- tmp[tmp$adjustment=="max",c("order","infection","category","label","cohort","est","lci","uci")]
  table3$estimate <- ifelse(grepl("(ref)",table3$label),"1.00 (ref)",paste0(display(table3$est)," (",display(table3$lci)," to ",display(table3$uci),")"))
  table3 <- tidyr::pivot_wider(table3, id_cols = c("order","category","label"), names_from = c("cohort","infection"), values_from = estimate)
  order_table3 <- c(paste0("winter2019",c("_RSV","_Influenza","_Pneumonia","_COVID-19")),
                    paste0("winter2021",c("_RSV","_Influenza","_Pneumonia","_COVID-19")))
  order_table3 <- intersect(order_table3,colnames(table3))
  table3 <- table3[order(table3$order),c("category","label",order_table3)]
  data.table::fwrite(table3,paste0("output/post_release/table3_",name,"_",outcome,".csv"))
  
}
