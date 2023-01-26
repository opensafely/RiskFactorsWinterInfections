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

def generate_common_variables(index_date_variable, index_date_variable_covariates):

    dynamic_variables = dict(

#----------------------------------------------- VARIABLES NEEDED TO DEFINE STUDY POPULATION #----------------------------------------------- #
# "ALIVE" and "REGISTERED" defined in study definitions
# Variables only defined here - study population to be defined in data cleaning script

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

    ## Region
    cov_cat_region=patients.registered_practice_as_of(
        f"{index_date_variable}",
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

    ## Record of hospitalisation in the 30 days prior to study start date

    hosp_admitted_1=patients.admitted_to_hospital(
        returning="binary_flag",
        between=["index_date", "index_date - 1 month"],
        with_patient_classification = ["1"],
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.05},
    ),

    ## Registered at the same TPP practice 

    registered_previous_365days=patients.registered_with_one_practice_between(
        start_date="index_date - 365 days",
        end_date="index_date",
        return_expectations={"incidence": 0.95},
    ),

#----------------------------------------------- RISK FACTORS #----------------------------------------------- #

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

    ## Other chronic respiratory conditions
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/21
    exp_bin_chronicresp=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    ## Chronic heart disease
    exp_bin_chd=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    ## Diabetes
    exp_bin_diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    ## Chronic liver disease
    exp_bin_chronicliver=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    ## Chronic neurological diseases
    exp_bin_chronicneuro=patients.with_these_clinical_events(
        other_neuro,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    ## Common autoimmune diseases 
    exp_bin_autoimmune=patients.with_these_clinical_events(
        autoimmune_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    ## Solid organ transplant
    exp_bin_solid_organ_transplantation=patients.with_these_clinical_events(
        asplenia_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    ## Asplenia 
    exp_bin_asplenia=patients.with_these_clinical_events(
        asplenia_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    # Other immunosuppressive conditions
    # Other immunosuppressive conditions included human immunodeficiency virus (HIV) 
    # or a condition inducing permanent immunodeficiency ever diagnosed, or aplastic anaemia or temporary immunodeficiency recorded within the last year.
    
    tmp_exp_bin_hiv=patients.with_these_clinical_events(
        hiv_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    tmp_exp_bin_perm_immuno=patients.with_these_clinical_events(
        permanent_immunosuppression_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    tmp_exp_bin_temp_immuno=patients.with_these_clinical_events(
        temporary_immunosuppression_codes,
        between=["index_date - 1 year", "index_date - 1 day"],
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    tmp_exp_bin_aplastic_anaemia=patients.with_these_clinical_events(
        aplastic_anaemia_codes,
        between=["index_date - 1 year", "index_date - 1 day"],
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    # Define other immunosupressive conditions based on the above

    exp_bin_other_immunosuppression=patients.maximum_of(
    "tmp_exp_bin_hiv", "tmp_exp_bin_perm_immuno", "tmp_exp_bin_temp_immuno", "tmp_exp_bin_aplastic_anaemia"
    ),

    ## Cancer

    exp_bin_lung_cancer=patients.with_these_clinical_events(
        lung_cancer_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    exp_bin_haem_cancer=patients.with_these_clinical_events(
        haem_cancer_codes, 
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    exp_bin_other_cancer=patients.with_these_clinical_events(
        other_cancer_codes, 
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

    # Combine above cancers
    exp_bin_cancer_combined=patients.maximum_of(
    "exp_bin_lung_cancer", "exp_bin_haem_cancer", "exp_bin_other_cancer"
    ),

    ## Reduced kidney function
    # Define in data cleaning script

    baseline_creatinine=patients.mean_recorded_value(
        creatinine_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before = "index_date - 1 day",
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 40},
            "incidence": 0.60,
        }
    ),

    ## Raised BP / Hypertension 

    exp_bin_hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        on_or_before = "index_date - 1 day",
        returning = "binary_flag",
        return_expectations = {"incidence": 0.05},
    ),

#----------------------------------------------- OUTCOMES #----------------------------------------------- #
# Outcomes: influenza, RSV, pneumonia_strep, pneunomia, COVID-19
# Separated below into: hospital admission, length of hospital admission, readmission to hospital, death


##--- HOSPITAL ADMISSION ---##


# Influenza 

	out_date_flu_adm = patients.admitted_to_hospital(
		with_these_diagnoses = flu_icd10,
		on_or_after = "index_date",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),

# RSV

	out_date_rsv_adm = patients.admitted_to_hospital(
		with_these_diagnoses = rsv_icd10,
		on_or_after = "index_date",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),

# Pneumonia strep

	out_date_pneustrep_adm = patients.admitted_to_hospital(
		with_these_diagnoses = pneustrep_icd10,
		on_or_after = "index_date",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),    

# Pmeumonia

	out_date_pneu_adm = patients.admitted_to_hospital(
		with_these_diagnoses = pneu_icd10,
		on_or_after = "index_date",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	), 

# COVID-19

	out_date_covid_adm = patients.admitted_to_hospital(
		with_these_diagnoses = covid_icd10,
		on_or_after = "index_date",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	), 



##--- LENGTH OF HOSPITAL ADMISSION ---##
# "tmp" variables defined here using discharge date - length of admission to then be defined in data cleaning script

# Influenza 

	tmp_out_date_flu_dis = patients.admitted_to_hospital(
		returning="date_discharged",
        with_these_diagnoses = flu_icd10,
        find_first_match_in_period=True,
		on_or_after = "out_date_flu_adm",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),

# RSV

	tmp_out_date_rsv_dis = patients.admitted_to_hospital(
		returning="date_discharged",
        with_these_diagnoses = rsv_icd10,
        find_first_match_in_period=True,
		on_or_after = "out_date_rsv_adm",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),

# Pneumonia strep

	tmp_out_date_pneustrep_dis = patients.admitted_to_hospital(
		returning="date_discharged",
        with_these_diagnoses = pneustrep_icd10,
        find_first_match_in_period=True,
		on_or_after = "out_date_pneustrep_adm",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),

# Pneumonia

	tmp_out_date_pneu_dis = patients.admitted_to_hospital(
		returning="date_discharged",
        with_these_diagnoses = pneu_icd10,
        find_first_match_in_period=True,
		on_or_after = "out_date_pneu_adm",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),

# COVID-19

	tmp_out_date_covid_dis = patients.admitted_to_hospital(
		returning="date_discharged",
        with_these_diagnoses = covid_icd10,
        find_first_match_in_period=True,
		on_or_after = "out_date_covid_adm",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),


##--- READMISSION TO HOSPITAL WITHIN 30 DAYS OF DISCHARGE ---##

# Influenza 

	out_date_flu_readm = patients.admitted_to_hospital(
		with_these_diagnoses = flu_icd10,
		on_or_before = "tmp_out_date_flu_dis + 30 days",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),

# RSV

	out_date_rsv_readm = patients.admitted_to_hospital(
		with_these_diagnoses = rsv_icd10,
		on_or_before = "tmp_out_date_rsv_dis + 30 days",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),

# Pneumonia strep

	out_date_pneustrep_readm = patients.admitted_to_hospital(
		with_these_diagnoses = pneustrep_icd10,
		on_or_before = "tmp_out_date_pneustrep_dis + 30 days",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	),    

# Pmeumonia

	out_date_pneu_readm = patients.admitted_to_hospital(
		with_these_diagnoses = pneu_icd10,
		on_or_before = "tmp_out_date_pneu_dis + 30 days",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	), 

# COVID-19

	out_date_covid_readm = patients.admitted_to_hospital(
		with_these_diagnoses = covid_icd10,
		on_or_before = "tmp_out_date_covid_dis + 30 days",
		returning="date_admitted",
		date_format = "YYYY-MM-DD",
		return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
	), 


##--- DEATH ---##

# Influenza 

    out_date_flu_death=patients.with_these_codes_on_death_certificate(
        flu_icd10,
        returning="date_of_death",
        on_or_after="index_date",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date", "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.05,
        },
    ),

# RSV

# Pneumonia strep

# Pmeumonia

# COVID-19

#----------------------------------------------- COVARIATES #----------------------------------------------- #

    ## Age - defined above in study population variables

    ## Sex

    sex = patients.sex(
    return_expectations = {
      "rate": "universal",
      "category": {"ratios": {"M": 0.49, "F": 0.51}},
      },
    ),

    ## Deprivation - defined above in study population variables

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
    cov_cat_obese = patients.categorised_as(
        {
            "No": "cov_num_bmi < 30", 
            "Yes": "cov_num_bmi >=30", 
            "Missing": "DEFAULT", 
        }, 
        return_expectations = {
            "rate": "universal", 
            "category": {
                "ratios": {
                    "No": 0.7, 
                    "Yes": 0.3, 
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

#----------------------------------------------- VARIABLES NEEDED FOR QUALITY ASSURANCE #----------------------------------------------- #

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
    cov_bin_combined_oral_contraceptive_pill=patients.with_these_medications(
        cocp_dmd, 
        returning='binary_flag',
        on_or_before="index_date",
        return_expectations={"incidence": 0.1},
    ),

    ## Hormone replacement therapy
    cov_bin_hormone_replacement_therapy=patients.with_these_medications(
        hrt_dmd, 
        returning='binary_flag',
        on_or_before="index_date",
        return_expectations={"incidence": 0.1},
    ),

    )
    return dynamic_variables