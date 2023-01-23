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
#from common_variables import generate_common_variables
#(
#    dynamic_variables
#) = generate_common_variables(index_date_variable="2019-12-01", index_date_variable_covariates = "2019-11-30" )


study = StudyDefinition(

    # Specify index date for study
    index_date = "2019-12-01",

    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },

    # Define the study population 
    # NB: not all inclusions and exclusions are written into study definition
    population = patients.satisfying(
        """registered""",
        registered=patients.registered_as_of("index_date"),
    ),
        
    has_died = patients.died_from_any_cause(
        on_or_before = "index_date",
        returning = "binary_flag",
    ),
        
    has_follow_up_previous_365days = patients.registered_with_one_practice_between(
        start_date = "index_date - 365 days",
        end_date = "index_date",
        return_expectations = {"incidence": 0.95},
    ),

    ## Region
    cov_cat_region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and The Humber": 0.1,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East": 0.1,
                    "London": 0.2,
                    "South East": 0.1,
                    "South West": 0.1,
                },
            },
        },
    ),

    ## Hospital admission in 30 days prior to study date
    #adm_last_30days = patients.admitted_to_hospital(
    #    returning = "binary flag",
    #    between = ["index_date - 30 days", "index_date - 1 day"],
    #    return_expectations = {"incidence": 0.1},
    #),

    ## Registered at same practice from 365 days prior to study period up to end of study period
    registered_same_practice = patients.registered_with_one_practice_between(
        start_date = "index_date - 366 days",
        end_date = "index_date + 89 days",
        return_expectations = {"incidence": 0.9},
    ),

    ## Sex
    sex = patients.sex(
        return_expectations = {
        "rate": "universal",
        "category": {"ratios": {"M": 0.49, "F": 0.51}},
        },
    ),

    cov_bin_male = patients.satisfying(
        """
        sex = "M"
        """,
        return_expectations = {
            "category":{"ratios":{"0": 0.51, "1": 0.49}}
        },
    ),

    ## Age
    cov_num_age = patients.age_as_of(
        "index_date",
        return_expectations = {
        "rate": "universal",
        "int": {"distribution": "population_ages"},
        "incidence" : 0.98
        },
    ),

    ## Deprivation
    cov_cat_deprivation=patients.categorised_as(
        helpers.generate_deprivation_ntile_dictionary(10),
        index_of_multiple_deprivation=patients.address_as_of(
            "index_date - 1 day",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations=helpers.generate_universal_expectations(10,False),
    ),

    ## Ethnicity 
    cov_cat_ethnicity=patients.categorised_as(
        helpers.generate_ethnicity_dictionary(6),
        cov_ethnicity_sus=patients.with_ethnicity_from_sus(
            returning="group_6", use_most_frequent_code=True
        ),
        cov_ethnicity_gp_opensafely=patients.with_these_clinical_events(
            opensafely_ethnicity_codes_6,
            on_or_before="index_date - 1 day",
            returning="category",
            find_last_match_in_period=True,
        ),
        cov_ethnicity_gp_primis=patients.with_these_clinical_events(
            primis_covid19_vacc_update_ethnicity,
            on_or_before="index_date - 1 day",
            returning="category",
            find_last_match_in_period=True,
        ),
        cov_ethnicity_gp_opensafely_date=patients.with_these_clinical_events(
            opensafely_ethnicity_codes_6,
            on_or_before="index_date - 1 day",
            returning="category",
            find_last_match_in_period=True,
        ),
        cov_ethnicity_gp_primis_date=patients.with_these_clinical_events(
            primis_covid19_vacc_update_ethnicity,
            on_or_before="index_date - 1 day",
            returning="category",
            find_last_match_in_period=True,
        ),
        return_expectations=helpers.generate_universal_expectations(5,True),
    ),

    ## BMI
    # taken from: https://github.com/opensafely/BMI-and-Metabolic-Markers/blob/main/analysis/common_variables.py 
    cov_num_bmi=patients.most_recent_bmi(
        on_or_before="index_date - 1 day",
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        date_format="YYYY-MM",
        return_expectations={
            "date": {"earliest": "2010-02-01", "latest": "2022-02-01"},
            "float": {"distribution": "normal", "mean": 28, "stddev": 8},
            "incidence": 0.7,
        },
    ),
     ### Categorising BMI
    cov_cat_bmi_groups = patients.categorised_as(
        {
            "Underweight": "cov_num_bmi < 18.5", 
            "Healthy_weight": "cov_num_bmi >= 18.5 AND cov_num_bmi < 25", 
            "Overweight": "cov_num_bmi >= 25 AND cov_num_bmi < 30",
            "Obese": "cov_num_bmi >=30", 
            "Missing": "DEFAULT", 
        }, 
        return_expectations = {
            "rate": "universal", 
            "category": {
                "ratios": {
                    "Underweight": 0.05, 
                    "Healthy_weight": 0.25, 
                    "Overweight": 0.4,
                    "Obese": 0.3, 
                },
            },
        },
    ),

    ## Smoking status
    cov_cat_smoking=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                most_recent_smoking_code = 'E' OR (
                most_recent_smoking_code = 'N' AND ever_smoked
                )
            """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            smoking_clear,
            find_last_match_in_period=True,
            on_or_before="index_date - 1 day",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(smoking_clear, include=["S", "E"]),
            on_or_before="index_date - 1 day",
        ),
    ),


    ### RISK FACTORS ####

    ## Asthma
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/55
    exp_bin_asthma=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                (
                  recent_asthma_code OR (
                    asthma_code_ever AND NOT
                    copd_code_ever
                  )
                ) AND (
                  prednisolone_last_year = 0 OR 
                  prednisolone_last_year > 4
                )
                OR
                (
                  recent_asthma_code OR (
                    asthma_code_ever AND NOT
                    copd_code_ever
                  )
                ) AND
                prednisolone_last_year > 0 AND
                prednisolone_last_year < 5
                
            """,
        },
        return_expectations={"category": {"ratios": {"0": 0.8, "1": 0.2}},},
        recent_asthma_code=patients.with_these_clinical_events(
            asthma_codes, between=["index_date - 365 days", "index_date - 1 day"],
        ),
        asthma_code_ever=patients.with_these_clinical_events(asthma_codes),
        copd_code_ever=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes
        ),
        prednisolone_last_year=patients.with_these_medications(
            pred_codes,
            between=["index_date - 365 days", "index_date - 1 day"],
            returning="number_of_matches_in_period",
        ),
    ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/21
    exp_bin_chronicresp=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,
        on_or_before = ["index_date - 1 day"],
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    exp_bin_chd=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        on_or_before = ["index_date - 1 day"],
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    )
 #   **dynamic_variables

)