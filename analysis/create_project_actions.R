# Load libraries ---------------------------------------------------------------

library(tidyverse)
library(yaml)
library(here)
library(glue)
library(readr)

# Specify defaults -------------------------------------------------------------

defaults_list <- list(
  version = "3.0",
  expectations= list(population_size=200000L)
)

# Specify parameters -----------------------------------------------------------

# cohorts

cohorts <- data.frame(cohort_name = character(),
                      cohort_start = character(),
                      cohort_end = character(),
                      stringsAsFactors = FALSE)

cohorts[nrow(cohorts)+1,] <- c("winter2019","td(1dec2019)","td(28feb2020)")
cohorts[nrow(cohorts)+1,] <- c("winter2021","td(1dec2021)","td(28feb2022)")

# outcomes x subgroups x cohorts for Cox models

infections <- c("flu","rsv","pneustrep","pneu","covid")

subgrp <- c("all","age18_39","age40_59","age60_79","age80_110","sex_f","sex_m","care_y","care_n","eth_white","eth_black","eth_asian","eth_mixed","eth_other")

cox_outcomes <- data.frame(outcome = c(rep(paste0(infections ,"_adm", "_", subgrp),
                                           each = length(unique(cohorts$cohort_name))),
                                       rep(paste0(infections ,"_readm", "_", subgrp),
                                           each = length(unique(cohorts$cohort_name))),
                                       rep(paste0(infections ,"_death", "_", subgrp),
                                           each = length(unique(cohorts$cohort_name))),
                                       rep(paste0(infections ,"_stay", "_", subgrp),
                                          each = length(unique(cohorts$cohort_name)))),
                           cohort_name = rep(unique(cohorts$cohort_name), times = length(infections)*4),
                           model = c(rep("cox",length(infections)*3*2),
                                     rep("linear",length(infections)*2)),
                           stringsAsFactors = FALSE)

cox_outcomes <- cox_outcomes[!(grepl("covid",cox_outcomes$outcome) & 
                                 cox_outcomes$cohort_name=="winter2019"),]

# Create action function -------------------------------------------------------

action <- function(
    name,
    run,
    dummy_data_file=NULL,
    arguments=NULL,
    needs=NULL,
    highly_sensitive=NULL,
    moderately_sensitive=NULL
){
  
  outputs <- list(
    moderately_sensitive = moderately_sensitive,
    highly_sensitive = highly_sensitive
  )
  
  outputs[sapply(outputs, is.null)] <- NULL
  
  action <- list(
    run = paste(c(run, arguments), collapse=" "),
    dummy_data_file = dummy_data_file,
    needs = needs,
    outputs = outputs
  )
  
  action[sapply(action, is.null)] <- NULL
  
  action_list <- list(name = action)
  names(action_list) <- name
  
  action_list
  
}

# Create comment functions ------------------------------------------------------

comment <- function(...){
  
  list_comments <- list(...)
  comments <- map(list_comments, ~paste0("## ", ., " ##"))
  comments
  
}

# The following converts comment "actions" in a yaml string into proper comments

convert_comment_actions <-function(yaml.txt){
  
  yaml.txt %>%
    str_replace_all("\\\n(\\s*)\\'\\'\\:(\\s*)\\'", "\n\\1")  %>%
    str_replace_all("([^\\'])\\\n(\\s*)\\#\\#", "\\1\n\n\\2\\#\\#") %>%
    str_replace_all("\\#\\#\\'\\\n", "\n")
  
}

# Create function for actions at cohort level ----------------------------------

cohort_actions <- function(cohort,cohort_start,cohort_end) {
  
  splice(
    
    comment(glue("Generate study population - {cohort}")),
    
    action(
      name = glue("generate_study_population_{cohort}"),
      run = glue("cohortextractor:latest generate_cohort --study-definition study_definition_{cohort} --output-format csv.gz"),
      highly_sensitive = list(
        cohort = glue("output/input_{cohort}.csv.gz")
      )
    ),
    
    comment(glue("Describe - input_{cohort}.csv.gz")),
    
    action(
      name =  glue("describe_input_{cohort}"),
      run =  glue("stata-mp:latest analysis/describe.do input_{cohort} csv"),
      needs = list(glue("generate_study_population_{cohort}")),
      highly_sensitive = list(
        cohort = glue("output/describe-input_{cohort}.log")
      )
    ),
    
    comment(glue("Data cleaning - {cohort}")),
    
    action(
      name =  glue("data_cleaning_{cohort}"),
      run =  glue("stata-mp:latest analysis/data_cleaning.do {cohort} {cohort_start} {cohort_end}"),
      needs = list(glue("generate_study_population_{cohort}")),
      moderately_sensitive = list(
        consort = glue("output/consort_{cohort}.csv"),
        rounded_consort = glue("output/rounded_consort_{cohort}.csv")
      ),
      highly_sensitive = list(
        cohort = glue("output/clean_{cohort}.dta.gz")
      )
    ),
    
    comment(glue("Describe - clean_{cohort}.dta.gz")),
    
    action(
      name = glue("describe_clean_{cohort}"),
      run = glue("stata-mp:latest analysis/describe.do clean_{cohort} dta"),
      needs = list(glue("data_cleaning_{cohort}")),
      highly_sensitive = list(
        cohort = glue("output/describe-clean_{cohort}.log")
      )
    ),
    
    comment(glue("Table 1 - {cohort}")),
    
    action(
      name = glue("table1_{cohort}"),
      run = glue("stata-mp:latest analysis/table1.do {cohort}"),
      needs = list(glue("data_cleaning_{cohort}")),
      moderately_sensitive = list(
        table1 = glue("output/table1_{cohort}.csv"),
        rounded_table1 = glue("output/rounded_table1_{cohort}.csv")
      )
    ),
  
    comment(glue("Table 2 - {cohort}")),
    
    action(
      name = glue("table2_{cohort}"),
      run = glue("stata-mp:latest analysis/table2.do {cohort}"),
      needs = list(glue("data_cleaning_{cohort}")),
      moderately_sensitive = list(
        table1 = glue("output/table2_{cohort}.csv"),
        rounded_table1 = glue("output/rounded_table2_{cohort}.csv")
      )
    )
  
    )
  
}

# Create function for actions at outcome level ---------------------------------

model_cohort_outcome_actions <- function(model,cohort,outcome) {
  
  splice(
    
    comment(glue("{model} model - {outcome} - {subgrp} - {cohort}")),
    
    action(
      name = glue("{model}_model_{outcome}_{subgrp}_{cohort}"),
      run = glue("stata-mp:latest analysis/{model}_model.do {cohort} {outcome} {subgrp}"),
      needs = list(glue("data_cleaning_{cohort}")),
      moderately_sensitive = list(
        results = glue("output/{model}_model-{outcome}-{subgrp}-{cohort}.csv"),
        rounded_results = glue("output/{model}_model-{outcome}-{subgrp}-{cohort}_rounded.csv")
      )
    )
    
  )
  
}

# Define all actions -----------------------------------------------------------

actions_list <- splice(
  
  comment("# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #",
          "DO NOT EDIT project.yaml DIRECTLY",
          "This file is created by create_project_actions.R",
          "Edit and run create_project_actions.R to update the project.yaml",
          "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  ),
  
  splice(
    unlist(
      lapply(1:nrow(cohorts),
             function(x) cohort_actions(cohort = cohorts[x,"cohort_name"], 
                                        cohort_start = cohorts[x,"cohort_start"],
                                        cohort_end = cohorts[x,"cohort_end"])), 
      recursive = FALSE
    )
  ),
  
  splice(
    unlist(
      lapply(1:nrow(cox_outcomes),
             function(x) model_cohort_outcome_actions(model = cox_outcomes[x,"model"],
                                                      cohort = cox_outcomes[x,"cohort_name"],
                                                      outcome = cox_outcomes[x,"outcome"])), 
      recursive = FALSE
    )
  ),
  
  comment(glue("Combine results")),
  
  action(
    name = glue("combine_results"),
    run = glue("stata-mp:latest analysis/combine_results.do"),
    needs = as.list(paste0(cox_outcomes$model,"_model_",cox_outcomes$outcome,"_",cox_outcomes$cohort_name)),
    moderately_sensitive = list(
      rounded_results = glue("output/results_rounded.csv")
    )
  )

)

# Combine all actions in a list ------------------------------------------------

project_list <- splice(
  defaults_list,
  list(actions = actions_list)
)

# Convert list to yaml ---------------------------------------------------------
## This includes reformatting comments and white space, and outputting .yaml file 

as.yaml(project_list, indent=2) %>%
  # convert comment actions to comments
  convert_comment_actions() %>%
  # add one blank line before level 1 and level 2 keys
  str_replace_all("\\\n(\\w)", "\n\n\\1") %>%
  str_replace_all("\\\n\\s\\s(\\w)", "\n\n  \\1") %>%
  writeLines("project.yaml")