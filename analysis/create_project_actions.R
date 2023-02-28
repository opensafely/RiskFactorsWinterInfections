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

# Define all actions -----------------------------------------------------------

actions_list <- splice(
  
  comment("# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #",
          "DO NOT EDIT project.yaml DIRECTLY",
          "This file is created by create_project_actions.R",
          "Edit and run create_project_actions.R to update the project.yaml",
          "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  ),
  
  comment("Generate study definitions"),
  
  action(
    name = "generate_study_population_winter2019",
    run = "cohortextractor:latest generate_cohort --study-definition study_definition_winter2019 --output-format csv.gz",
    highly_sensitive = list(
      cohort = glue("output/input_winter2019.csv.gz")
    )
  ),
  
  action(
    name = "generate_study_population_winter2021",
    run = "cohortextractor:latest generate_cohort --study-definition study_definition_winter2021 --output-format csv.gz",
    highly_sensitive = list(
      cohort = glue("output/input_winter2021.csv.gz")
    )
  ),
  
  comment("Data cleaning"),

  action(
    name = "data_cleaning_winter2019",
    run = "stata-mp:latest analysis/data_cleaning.do winter2019 td(1dec2019) td(28feb2020)",
    needs = list("generate_study_population_winter2019"),
    moderately_sensitive = list(
      consort = glue("output/consort_winter2019.csv"),
      rounded_consort = glue("output/rounded_consort_winter2019.csv")
    ),
    highly_sensitive = list(
      cohort = glue("output/clean_winter2019.dta.gz")
    )
  ),

  action(
    name = "data_cleaning_winter2021",
    run = "stata-mp:latest analysis/data_cleaning.do winter2021 td(1dec2021) td(28feb2022)",
    needs = list("generate_study_population_winter2021"),
    moderately_sensitive = list(
      consort = glue("output/consort_winter2021.csv"),
      rounded_consort = glue("output/rounded_consort_winter2021.csv")
    ),
    highly_sensitive = list(
      cohort = glue("output/clean_winter2021.dta.gz")
    )
  ),
  
  comment("Table 1"),
  
  action(
    name = "table1_winter2019",
    run = "stata-mp:latest analysis/table1.do winter2019",
    needs = list("data_cleaning_winter2019"),
    moderately_sensitive = list(
      table1 = glue("output/table1_winter2019.csv"),
      rounded_table1 = glue("output/rounded_table1_winter2019.csv")
    )
  ),
  
  action(
    name = "table1_winter2021",
    run = "stata-mp:latest analysis/table1.do winter2021",
    needs = list("data_cleaning_winter2021"),
    moderately_sensitive = list(
      table1 = glue("output/table1_winter2021.csv"),
      rounded_table1 = glue("output/rounded_table1_winter2021.csv")
    )
  ),
  
  comment("Cox models"),
  
  action(
    name = "cox_model_winter2019",
    run = "stata-mp:latest analysis/cox_model.do winter2019",
    needs = list("data_cleaning_winter2019"),
    moderately_sensitive = list(
      results = glue("output/results_winter2019.csv")
    )
  ),
  
  action(
    name = "cox_model_winter2021",
    run = "stata-mp:latest analysis/cox_model.do winter2021",
    needs = list("data_cleaning_winter2021"),
    moderately_sensitive = list(
      results = glue("output/results_winter2021.csv")
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