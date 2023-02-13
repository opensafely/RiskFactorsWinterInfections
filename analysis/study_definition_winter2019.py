# Import statements

## Set seed
import numpy as np
np.random.seed(123456)

## Cohort extractor
from cohortextractor import (
  StudyDefinition,
  patients,
  codelist_from_csv,
  codelist,
  filter_codes_by_category,
  combine_codelists,
)

## Codelists from codelist.py (which pulls them from the codelist folder)
from codelists import *

## Datetime functions
from datetime import date

## Study definition helper
import study_definition_helper_functions as helpers

## Import common variables function
from common_variables import generate_common_variables
(
    dynamic_variables
) = generate_common_variables(study_start_variable="index_date", study_end_variable="2020-02-28")


study = StudyDefinition(

    # Set default expectations
    default_expectations={
      "date": {"earliest": "1900-01-01", "latest": "today"},
      "rate": "uniform",
      "incidence": 0.5,
    },

    # Specify index date for study
    index_date = "2019-12-01",

    # Extract all patients
    population = patients.all(),
   
    # Add common variables
    **dynamic_variables

)