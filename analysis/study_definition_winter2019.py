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
) = generate_common_variables(index_date_variable="2019-12-01", index_date_variable_covariates = "2019-11-30" )


study = StudyDefinition(

    # Specify index date for study
    index_date = "2019-12-01",

    # Define the study population 
    # NB: not all inclusions and exclusions are written into study definition
    population = patients.satisfying(
        "registered",
        registered=patients.registered_as_of("index_date"),
    ),
        
    ### Covariates and inclusion/exclusion variables
    ## Patient alive at index date
    has_died = patients.died_from_any_cause(
        on_or_before = "index_date",
        returning = "binary_flag",
    ),
   
        **dynamic_variables
)