# Based on script developed by Alex Walker and Robin Park (https://github.com/opensafely/long-covid-sick-notes/blob/master/analysis/common_variables.py)

# Import statements

## Cohort extractor
from cohortextractor import (
    patients,
    codelist,
    filter_codes_by_category,
    combine_codelists,
    codelist_from_csv,
)

## Codelists from codelist.py (which pulls them from the codelist folder)
from codelists import *

## Datetime functions
from datetime import date

## Study definition helper
import study_definition_helper_functions as helpers

# Define common variables function

def generate_common_variables(study_start_variable,study_end_variable):

    dynamic_variables = dict(

    # Study population variables ------------------------------------------------------------------
        
        ## Death date

            ### Primary care
            primary_care_death_date=patients.with_death_recorded_in_primary_care(
                    on_or_after="index_date",
                    returning="date_of_death",
                    date_format="YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": "index_date", "latest" : "today"},
                        "rate": "exponential_increase",
                    },
            ),
            ### ONS
            ons_died_from_any_cause_date=patients.died_from_any_cause(
                    on_or_after="index_date",
                    returning="date_of_death",
                    date_format="YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": "index_date", "latest" : "today"},
                        "rate": "exponential_increase",
                    },
            ),
            ### Combined
            death_date=patients.minimum_of(
                "primary_care_death_date", "ons_died_from_any_cause_date"
            ),

        ## Record of hospitalisation in the 30 days prior to study start date

            hospitalised_previous_30days=patients.admitted_to_hospital(
                returning="binary_flag",
                between=[f"{study_start_variable}- 30 days", f"{study_start_variable}"],
                with_patient_classification = ["1"],
                find_last_match_in_period=True,
                return_expectations={"incidence": 0.05},
            ),

        ## Registered at the same TPP practice 

            registered_previous_365days=patients.registered_with_one_practice_between(
                start_date=f"{study_start_variable}- 365 days",
                end_date=f"{study_end_variable}",
                return_expectations={"incidence": 0.95},
            ),

    # Risk factors --------------------------------------------------------------------------------

        ## Asthma

        exp_cat_asthma=patients.categorised_as(
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
                asthma_codes, between=[f"{study_start_variable}- 365 days", f"{study_start_variable}- 1 day"],
            ),
            asthma_code_ever=patients.with_these_clinical_events(asthma_codes),
            copd_code_ever=patients.with_these_clinical_events(
                chronic_respiratory_disease_codes
            ),
            prednisolone_last_year=patients.with_these_medications(
                pred_codes,
                between=[f"{study_start_variable}- 365 days", f"{study_start_variable}- 1 day"],
                returning="number_of_matches_in_period",
            ),
        ),

        ## Other chronic respiratory conditions
        
        exp_bin_chronicresp=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ## Chronic heart disease

        exp_bin_chd=patients.with_these_clinical_events(
            chronic_cardiac_disease_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ## Diabetes
        tmp_exp_bin_diabetes=patients.with_these_clinical_events(
            diabetes_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ### Maximum latest HbA1c measure
        tmp_out_num_max_hba1c_mmol_mol=patients.max_recorded_value(
            hba1c_new_codes,
            on_most_recent_day_of_measurement=True, 
            between=["1990-01-01", "today"],
            date_format="YYYY-MM-DD",
            return_expectations={
            "float": {"distribution": "normal", "mean": 30.0, "stddev": 15},
            "date": {"earliest": "1980-02-01", "latest": "2021-05-31"},
            "incidence": 0.95,
            },
        ),
        tmp_out_num_max_hba1c_date=patients.date_of("tmp_out_num_max_hba1c_mmol_mol", date_format="YYYY-MM-DD"),

        ## Chronic liver disease

        exp_bin_chronicliver=patients.with_these_clinical_events(
            chronic_liver_disease_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ## Stroke

        exp_bin_stroke=patients.with_these_clinical_events(
            stroke_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ## Other neurological diseases

        exp_bin_otherneuro=patients.with_these_clinical_events(
            other_neuro,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ## Common autoimmune diseases 

        exp_bin_autoimm=patients.with_these_clinical_events(
            autoimmune_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ## Solid organ transplant

        exp_bin_transplant=patients.with_these_clinical_events(
            organ_transplantation,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ## Asplenia 

        exp_bin_asplenia=patients.with_these_clinical_events(
            asplenia_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        ## Other immunosuppressive conditions

        tmp_exp_bin_hiv=patients.with_these_clinical_events(
            hiv_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        tmp_exp_bin_perm_immuno=patients.with_these_clinical_events(
            permanent_immunosuppression_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        tmp_exp_bin_temp_immuno=patients.with_these_clinical_events(
            temporary_immunosuppression_codes,
            between=[f"{study_start_variable}- 365 days", f"{study_start_variable}- 1 day"],
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        tmp_exp_bin_aplastic_anaemia=patients.with_these_clinical_events(
            aplastic_anaemia_codes,
            between=[f"{study_start_variable}- 365 days", f"{study_start_variable}- 1 day"],
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

        exp_bin_other_immunosuppression=patients.maximum_of(
        "tmp_exp_bin_hiv", "tmp_exp_bin_perm_immuno", "tmp_exp_bin_temp_immuno", "tmp_exp_bin_aplastic_anaemia"
        ),

        ## Cancer

        tmp_exp_date_lung_cancer=patients.with_these_clinical_events(
            lung_cancer_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "date",
            return_expectations={
            "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
            }
        ),

        tmp_exp_date_cancer_haem=patients.with_these_clinical_events(
            haem_cancer_codes, 
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "date",
            return_expectations={
            "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
            }
        ),

        tmp_exp_date_other_cancer=patients.with_these_clinical_events(
            other_cancer_codes, 
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "date",
            return_expectations={
            "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
            },
        ),

        tmp_exp_date_cancer_exhaem=patients.maximum_of(
            "tmp_exp_date_lung_cancer", "tmp_exp_date_other_cancer"
        ),

        ## Reduced kidney function (to be define in data cleaning script)

        baseline_creatinine=patients.mean_recorded_value(
            creatinine_codes,
            on_most_recent_day_of_measurement=True,
            on_or_before = f"{study_start_variable}- 1 day",
            return_expectations={
                "float": {"distribution": "normal", "mean": 80, "stddev": 40},
                "incidence": 0.60,
            }
        ),

        ## Raised BP / Hypertension 

        exp_bin_hypertension=patients.with_these_clinical_events(
            hypertension_codes,
            on_or_before = f"{study_start_variable}- 1 day",
            returning = "binary_flag",
            return_expectations = {"incidence": 0.05},
        ),

    # Outcomes ------------------------------------------------------------------------------------


        ## Hospital admission


            ### Influenza 

                out_date_flu_adm = patients.admitted_to_hospital(
                    with_these_diagnoses = flu_icd10,
                    between=[f"{study_start_variable}", f"{study_end_variable}"],
                    find_first_match_in_period=True,
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### RSV

                out_date_rsv_adm = patients.admitted_to_hospital(
                    with_these_diagnoses = rsv_icd10,
                    between=[f"{study_start_variable}", f"{study_end_variable}"],
                    find_first_match_in_period=True,
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### Pneumonia strep

                out_date_pneustrep_adm = patients.admitted_to_hospital(
                    with_these_diagnoses = pneustrep_icd10,
                    between=[f"{study_start_variable}", f"{study_end_variable}"],
                    find_first_match_in_period=True,
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),    

            ### Pmeumonia

                out_date_pneu_adm = patients.admitted_to_hospital(
                    with_these_diagnoses = pneu_icd10,
                    between=[f"{study_start_variable}", f"{study_end_variable}"],
                    find_first_match_in_period=True,
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ), 

            ### COVID-19

                out_date_covid_adm = patients.admitted_to_hospital(
                    with_these_diagnoses = covid_icd10,
                    between=[f"{study_start_variable}", f"{study_end_variable}"],
                    find_first_match_in_period=True,
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ), 

        ## Length of admission - "tmp" variables defined here using discharge date, length of admission to then be defined in data cleaning script

            ### Influenza 

                tmp_out_date_flu_dis = patients.admitted_to_hospital(
                    returning="date_discharged",
                    with_these_diagnoses = flu_icd10,
                    find_first_match_in_period=True,
                    on_or_after = "out_date_flu_adm",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

             ### RSV

                tmp_out_date_rsv_dis = patients.admitted_to_hospital(
                    returning="date_discharged",
                    with_these_diagnoses = rsv_icd10,
                    find_first_match_in_period=True,
                    on_or_after = "out_date_rsv_adm",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### Pneumonia strep

                tmp_out_date_pneustrep_dis = patients.admitted_to_hospital(
                    returning="date_discharged",
                    with_these_diagnoses = pneustrep_icd10,
                    find_first_match_in_period=True,
                    on_or_after = "out_date_pneustrep_adm",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": "1900-01-01", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### Pneumonia

                tmp_out_date_pneu_dis = patients.admitted_to_hospital(
                    returning="date_discharged",
                    with_these_diagnoses = pneu_icd10,
                    find_first_match_in_period=True,
                    on_or_after = "out_date_pneu_adm",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### COVID-19

                tmp_out_date_covid_dis = patients.admitted_to_hospital(
                    returning="date_discharged",
                    with_these_diagnoses = covid_icd10,
                    find_first_match_in_period=True,
                    on_or_after = "out_date_covid_adm",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),


        ## Readmission within 30 days of discharge

            ### Influenza 

                out_date_flu_readm = patients.admitted_to_hospital(
                    with_these_diagnoses = flu_icd10,
                    between=["tmp_out_date_flu_dis", "tmp_out_date_flu_dis + 30 days"],
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### RSV

                out_date_rsv_readm = patients.admitted_to_hospital(
                    with_these_diagnoses = rsv_icd10,
                    between=["tmp_out_date_rsv_dis", "tmp_out_date_rsv_dis + 30 days"],
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### Pneumonia strep

                out_date_pneustrep_readm = patients.admitted_to_hospital(
                    with_these_diagnoses = pneustrep_icd10,
                    between=["tmp_out_date_pneustrep_dis", "tmp_out_date_pneustrep_dis + 30 days"],
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),    

            ### Pmeumonia

                out_date_pneu_readm = patients.admitted_to_hospital(
                    with_these_diagnoses = pneu_icd10,
                    between=["tmp_out_date_pneu_dis", "tmp_out_date_pneu_dis + 30 days"],
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ), 

            ### COVID-19

                out_date_covid_readm = patients.admitted_to_hospital(
                    with_these_diagnoses = covid_icd10,
                    between=["tmp_out_date_covid_dis", "tmp_out_date_covid_dis + 30 days"],
                    returning="date_admitted",
                    date_format = "YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ), 


       ## Death

            ### Influenza 

                out_date_flu_death=patients.with_these_codes_on_death_certificate(
                    flu_icd10,
                    returning="date_of_death",
                    on_or_after=f"{study_start_variable}",
                    match_only_underlying_cause=True,
                    date_format="YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### RSV

                out_date_rsv_death=patients.with_these_codes_on_death_certificate(
                    rsv_icd10,
                    returning="date_of_death",
                    on_or_after=f"{study_start_variable}",
                    match_only_underlying_cause=True,
                    date_format="YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### Pneumonia strep

                out_date_pneustrep_death=patients.with_these_codes_on_death_certificate(
                    pneustrep_icd10,
                    returning="date_of_death",
                    on_or_after=f"{study_start_variable}",
                    match_only_underlying_cause=True,
                    date_format="YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            ### Pmeumonia

                out_date_pneu_death=patients.with_these_codes_on_death_certificate(
                    pneu_icd10,
                    returning="date_of_death",
                    on_or_after=f"{study_start_variable}",
                    match_only_underlying_cause=True,
                    date_format="YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

            # COVID-19

                out_date_covid_death=patients.with_these_codes_on_death_certificate(
                    covid_icd10,
                    returning="date_of_death",
                    on_or_after=f"{study_start_variable}",
                    match_only_underlying_cause=True,
                    date_format="YYYY-MM-DD",
                    return_expectations={
                        "date": {"earliest": f"{study_start_variable}", "latest" : "today"},
                        "rate": "uniform",
                        "incidence": 0.05,
                    },
                ),

    # Covariates ----------------------------------------------------------------------------------

        ## Age

        cov_num_age = patients.age_as_of(
            f"{study_start_variable}",
            return_expectations = {
            "rate": "universal",
            "int": {"distribution": "population_ages"},
            "incidence" : 0.98
            },
        ),

	    # Age categories 
        sub_cat_age=patients.categorised_as(
            {
            "18-39": "cov_num_age >= 0 AND cov_num_age < 5",
            "40-45": "cov_num_age >= 5 AND cov_num_age < 10",
            "60-79": "cov_num_age >= 10 AND cov_num_age < 15",
            "80-110": "cov_num_age >= 15 AND cov_num_age < 20",
            "missing": "DEFAULT",
            },
            return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "18-39": 0.25,
                    "40-45": 0.25,
                    "60-79": 0.25,
                    "80-110": 0.1,
                    "missing": 0.15,
                 }
                },
            },
        ),

        ## Region

        cov_cat_region=patients.registered_practice_as_of(
            f"{study_start_variable}",
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

        ## Sex

        sex = patients.sex(
            return_expectations = {
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        },
        ),

        cov_bin_male=patients.categorised_as(
            {
            "Yes": "sex = 'M'",
            "No": "sex = 'F'",
            "Missing": "DEFAULT", 
            },
            return_expectations = {
             "rate": "universal", 
             "category": {
                 "ratios": {
                     "Yes": 0.5, 
                     "No": 0.5, 
                    }
                },
            },
        ),

        ## Deprivation

        cov_cat_deprivation=patients.categorised_as(
            helpers.generate_deprivation_ntile_dictionary(5),
            index_of_multiple_deprivation=patients.address_as_of(
                f"{study_start_variable}- 1 day",
                returning="index_of_multiple_deprivation",
                round_to_nearest=100,
            ),
            return_expectations=helpers.generate_universal_expectations(5,False),
        ),

        ## Ethnicity 
        
        cov_cat_ethnicity=patients.categorised_as(
            helpers.generate_ethnicity_dictionary(6),
            cov_ethnicity_sus=patients.with_ethnicity_from_sus(
                returning="group_6", use_most_frequent_code=True
            ),
            cov_ethnicity_gp_opensafely=patients.with_these_clinical_events(
                opensafely_ethnicity_codes_6,
                on_or_before=f"{study_start_variable}- 1 day",
                returning="category",
                find_last_match_in_period=True,
            ),
            cov_ethnicity_gp_primis=patients.with_these_clinical_events(
                primis_covid19_vacc_update_ethnicity,
                on_or_before=f"{study_start_variable}- 1 day",
                returning="category",
                find_last_match_in_period=True,
            ),
            cov_ethnicity_gp_opensafely_date=patients.with_these_clinical_events(
                opensafely_ethnicity_codes_6,
                on_or_before=f"{study_start_variable}- 1 day",
                returning="category",
                find_last_match_in_period=True,
            ),
            cov_ethnicity_gp_primis_date=patients.with_these_clinical_events(
                primis_covid19_vacc_update_ethnicity,
                on_or_before=f"{study_start_variable}- 1 day",
                returning="category",
                find_last_match_in_period=True,
            ),
            return_expectations=helpers.generate_universal_expectations(5,True),
        ),

        ## BMI

        cov_cat_obese = patients.categorised_as(
            {
                "NoEvidence": "bmi < 30", 
                "ObeseClassI": "bmi >= 30 AND bmi < 35", 
                "ObeseClassII": "bmi >= 35 AND bmi < 40", 
                "ObeseClassIII": "bmi >= 40", 
                "Missing": "DEFAULT", 
            }, 
            return_expectations = {
                "rate": "universal", 
                "category": {
                    "ratios": {
                        "NoEvidence": 0.25, 
                        "ObeseClassI": 0.25, 
                        "ObeseClassII": 0.25, 
                        "ObeseClassIII": 0.25,  
                    },
                },
            },
            bmi=patients.most_recent_bmi(
                on_or_before=f"{study_start_variable}- 1 day",
                minimum_age_at_measurement=18,
                include_measurement_date=True,
                date_format="YYYY-MM",
                return_expectations={
                    "date": {"earliest": "2010-02-01", "latest": "2022-02-01"},
                    "float": {"distribution": "normal", "mean": 28, "stddev": 8},
                    "incidence": 0.7,
                },
            ),
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
                on_or_before=f"{study_start_variable}- 1 day",
                returning="category",
            ),
            ever_smoked=patients.with_these_clinical_events(
                filter_codes_by_category(smoking_clear, include=["S", "E"]),
                on_or_before=f"{study_start_variable}- 1 day",
            ),
        ),

    # Quality assurance ---------------------------------------------------------------------------

        ## Prostate cancer
            
            ### Primary care
                prostate_cancer_snomed=patients.with_these_clinical_events(
                    prostate_cancer_snomed_clinical,
                    returning='binary_flag',
                    return_expectations={
                        "incidence": 0.03,
                    },
                ),
                ### HES APC
                prostate_cancer_hes=patients.admitted_to_hospital(
                    with_these_diagnoses=prostate_cancer_icd10,
                    returning='binary_flag',
                    return_expectations={
                        "incidence": 0.03,
                    },
                ),
                ### ONS
                prostate_cancer_death=patients.with_these_codes_on_death_certificate(
                    prostate_cancer_icd10,
                    returning='binary_flag',
                    return_expectations={
                        "incidence": 0.02
                    },
                ),
                ### Combined
                qa_bin_prostate_cancer=patients.maximum_of(
                    "prostate_cancer_snomed", "prostate_cancer_hes", "prostate_cancer_death"
                ),

        ## Pregnancy
            
            qa_bin_pregnancy=patients.with_these_clinical_events(
                pregnancy_snomed_clinical,
                returning='binary_flag',
                return_expectations={
                    "incidence": 0.03,
                },
            ),
            
        ## Year of birth
            qa_num_birth_year=patients.date_of_birth(
                date_format="YYYY",
                return_expectations={
                    "date": {"earliest": "1930-01-01", "latest": "today"},
                    "rate": "uniform",
                },
            ),

        ## Combined oral contraceptive pill
        ### dmd: dictionary of medicines and devices
            tmp_cov_bin_combined_oral_contraceptive_pill=patients.with_these_medications(
                cocp_dmd, 
                returning='binary_flag',
                on_or_before=f"{study_start_variable}",
                return_expectations={"incidence": 0.1},
            ),

        ## Hormone replacement therapy
            tmp_cov_bin_hormone_replacement_therapy=patients.with_these_medications(
                hrt_dmd, 
                returning='binary_flag',
                on_or_before=f"{study_start_variable}",
                return_expectations={"incidence": 0.1},
            ),

        # combined HRT and contraceptive pill

            qa_bin_hrtcocp=patients.maximum_of(
            "tmp_cov_bin_combined_oral_contraceptive_pill", "tmp_cov_bin_hormone_replacement_therapy"
            ),

        # care home 
            sub_bin_carehome=patients.care_home_status_as_of(
                f"{study_start_variable}",
                categorised_as={
                    "Yes": """
                    IsPotentialCareHome
                    AND LocationDoesNotRequireNursing='Y'
                    AND LocationRequiresNursing='N'
                    """,
                    "Yes": """
                    IsPotentialCareHome
                    AND LocationDoesNotRequireNursing='N'
                    AND LocationRequiresNursing='Y'
                    """,
                    "Yes": "IsPotentialCareHome",
                    "No": "DEFAULT",
                },
                return_expectations={
                    "rate": "universal",
                    "category": {"ratios": {"Yes": 0.30, "No": 0.70},},
                },
            ),

    )
   
    return dynamic_variables