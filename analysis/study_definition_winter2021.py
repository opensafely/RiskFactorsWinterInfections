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
) = generate_common_variables(index_date_variable="index_date" )


study = StudyDefinition(

    default_expectations={
      "date": {"earliest": "1900-01-01", "latest": "today"},
      "rate": "uniform",
      "incidence": 0.5,
    },

    # Specify index date for study
    index_date = "2020-12-01",

    # Define the study population 
    # NB: not all inclusions and exclusions are written into study definition
    population = patients.satisfying(
        "registered",
        registered=patients.registered_as_of("index_date"),
    ),
   
        **dynamic_variables
)