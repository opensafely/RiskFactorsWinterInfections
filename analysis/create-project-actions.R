library(tidyverse)
library(yaml)
library(here)
library(glue)
library(readr)
#library(dplyr)


###########################
# Load information to use #
###########################

## defaults ----
defaults_list <- list(
  version = "3.0",
  expectations= list(population_size=200000L)
)

# create action functions ----

############################
## generic action function #
############################
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


## create comment function ----
comment <- function(...){
  list_comments <- list(...)
  comments <- map(list_comments, ~paste0("## ", ., " ##"))
  comments
}


## create function to convert comment "actions" in a yaml string into proper comments
convert_comment_actions <-function(yaml.txt){
  yaml.txt %>%
    str_replace_all("\\\n(\\s*)\\'\\'\\:(\\s*)\\'", "\n\\1")  %>%
    #str_replace_all("\\\n(\\s*)\\'", "\n\\1") %>%
    str_replace_all("([^\\'])\\\n(\\s*)\\#\\#", "\\1\n\n\\2\\#\\#") %>%
    str_replace_all("\\#\\#\\'\\\n", "\n")
}


#################################################
## Function for typical actions to analyse data #
#################################################
# Updated to a typical action running Cox models for one outcome
apply_model_function <- function(outcome, cohort, data_only){
  splice(
    comment(glue("Cox model for {outcome} - {cohort}")),
    action(
      name = glue("Analysis_cox_{outcome}_{cohort}"),
      run = "r:latest analysis/model/01_cox_pipeline.R",
      arguments = c(outcome,cohort,data_only),
      needs = list("stage1_data_cleaning_prevax", "stage1_data_cleaning_vax", "stage1_data_cleaning_unvax", 
                   glue("stage1_end_date_table_{cohort}"),
                   glue("diabetes_post_hoc_{cohort}")),
      moderately_sensitive = list(
        analyses_not_run = glue("output/review/model/*/analyses_not_run_{outcome}_{cohort}.csv"),
        compiled_hrs_csv = glue("output/review/model/*/suppressed_compiled_HR_results_{outcome}_{cohort}.csv"),
        compiled_hrs_csv_to_release = glue("output/review/model/*/suppressed_compiled_HR_results_{outcome}_{cohort}_to_release.csv"),
        compiled_event_counts_csv = glue("output/review/model/*/suppressed_compiled_event_counts_{outcome}_{cohort}.csv"),
        compiled_event_counts_csv_non_supressed = glue("output/review/model/*/compiled_event_counts_{outcome}_{cohort}.csv"),
        describe_data_surv = glue("output/not-for-review/describe_data_surv_{outcome}_*_{cohort}_*_time_periods.txt")
      ),
      highly_sensitive = list(
        dataset = glue("output/input_{outcome}_*_{cohort}_*_time_periods.csv"),
        sampled_dataset = glue("output/input_sampled_data_{outcome}_*_{cohort}_*_time_periods.csv")
      )
    )
  )
}

# Updated to a typical action running Cox models for one outcome
# apply_model_function_covariate_testing <- function(outcome, cohort){
#   splice(
#     comment(glue("Cox model {outcome} - {cohort}, covariate_testing")),
#     action(
#       name = glue("Analysis_cox_{outcome}_{cohort}_covariate_testing"),
#       run = "r:latest analysis/model/01_cox_pipeline.R",
#       arguments = c(outcome,cohort,"test_all"),
#       needs = list("stage1_data_cleaning_prevax", "stage1_data_cleaning_vax", "stage1_data_cleaning_unvax", glue("stage1_end_date_table_{cohort}")),
#       moderately_sensitive = list(
#         analyses_not_run = glue("output/review/model/analyses_not_run_{outcome}_{cohort}_covariate_testing_test_all.csv"),
#         compiled_hrs_csv = glue("output/review/model/suppressed_compiled_HR_results_{outcome}_{cohort}_covariate_testing_test_all.csv"),
#         compiled_hrs_csv_to_release = glue("output/review/model/suppressed_compiled_HR_results_{outcome}_{cohort}_covariate_testing_test_all_to_release.csv"),
#         compiled_event_counts_csv = glue("output/review/model/suppressed_compiled_event_counts_{outcome}_{cohort}_covariate_testing_test_all.csv"),
#         compiled_event_counts_csv_non_supressed = glue("output/review/model/compiled_event_counts_{outcome}_{cohort}_covariate_testing_test_all.csv"),
#         describe_data_surv = glue("output/not-for-review/describe_data_surv_{outcome}_*_{cohort}_*_covariate_testing_test_all.txt")
#       )
#     )
#   )
# }
table2 <- function(cohort){
  splice(
    comment(glue("Stage 4 - Table 2 - {cohort} cohort")),
    action(
      name = glue("stage4_table_2_{cohort}"),
      run = "r:latest analysis/descriptives/table_2.R",
      arguments = c(cohort),
      needs = list("stage1_data_cleaning_prevax", "stage1_data_cleaning_vax", "stage1_data_cleaning_unvax",glue("stage1_end_date_table_{cohort}")),
      moderately_sensitive = list(
        input_table_2 = glue("output/review/descriptives/table2_{cohort}_*.csv")
      )
    )
  )
}

##########################################################
## Define and combine all actions into a list of actions #
##########################################################
actions_list <- splice(
  
  comment("# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #",
          "DO NOT EDIT project.yaml DIRECTLY",
          "This file is created by create_project_actions.R",
          "Edit and run create_project_actions.R to update the project.yaml",
          "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  ),
  
  #comment("Generate dummy data for study_definition - winter 2019"),
  action(
    name = "generate_study_population_winter2019",
    run = "cohortextractor:latest generate_cohort --study-definition study_definition_winter2019 --output-format feather",
    highly_sensitive = list(
      cohort = glue("output/input_winter2019.csv.gz")
    )
  ),
  
  #comment("Generate dummy data for study_definition - winter 2021"),
  action(
    name = "generate_study_population_winter2021",
    run = "cohortextractor:latest generate_cohort --study-definition study_definition_winter2021 --output-format feather",
    highly_sensitive = list(
      cohort = glue("output/input_winter2021.csv.gz")
    )
  ),
  
  #comment("Preprocess and data cleaning - winter 2019"),
  action(
    name = "data_preprocess_cleaning_winter2019",
    run = "r:latest analysis/cleaning/data-pre-process-cleaning.R winter2019",
    needs = list("generate_study_population_winter2019"),
    moderately_sensitive = list(
      describe = glue("output/not-for-review/describe_input_prevax_*.txt")
    ),
    highly_sensitive = list(
      cohort = glue("output/input_winter2019.csv.gz")
    )
  ), 
  
  #comment("Preprocess and data cleaning - winter 2021"),
  action(
    name = "data_preprocess_cleaning_winter2021",
    run = "r:latest analysis/cleaning/data-pre-process-cleaning.R winter2021",
    needs = list("agenerate_study_population_winter2021"),
    moderately_sensitive = list(
      describe = glue("output/not-for-review/describe_input_prevax_*.txt")
    ),
    highly_sensitive = list(
      cohort = glue("output/input_winter2021.csv.gz")
    )
  )

  
  )

## combine everything ----
project_list <- splice(
  defaults_list,
  list(actions = actions_list)
)

#####################################################################################
## convert list to yaml, reformat comments and white space, and output a .yaml file #
#####################################################################################
as.yaml(project_list, indent=2) %>%
  # convert comment actions to comments
  convert_comment_actions() %>%
  # add one blank line before level 1 and level 2 keys
  str_replace_all("\\\n(\\w)", "\n\n\\1") %>%
  str_replace_all("\\\n\\s\\s(\\w)", "\n\n  \\1") %>%
  writeLines("project.yaml")