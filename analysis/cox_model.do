/*==============================================================================
	   DO FILE NAME:			cox_model.do
	   PROJECT:				RiskFactorsWinterPressures
	   DATE: 					Mar 2020 
	   AUTHOR:					V Walker, S Walter									
	   DESCRIPTION OF FILE:	set data and perform cox modelling
	   DATASETS USED:			output/clean_winter*.dta.gz
	   STATA FUNCTIONS USED:	
	   DATASETS CREATED: 		
	   OTHER OUTPUT: 			
   ==============================================================================*/

* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6

* Create macros for arguments --------------------------------------------------

/*
clear all
local cohort "winter2019"
local outcome "flu_death"
*/

local cohort "`1'"
local outcome "`2'"
local subgrp "`3'"

di "Arguments: (1) `cohort'; (2) `outcome'; (3) `subgrp'."

adopath + "analysis/adofiles"

* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6

* Source functions -------------------------------------------------------------

run "analysis/functions/utility.do"
run "analysis/functions/cox_model-perform_cox.do"

* Create empty results file ----------------------------------------------------

set obs 0
gen model = ""
save "output/cox_model-`outcome'-`subgrp'-`cohort'.dta", replace

* Load data --------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz, clear

* Filter data for subgroup analyses --------------------------------------------

keep if patient_id!=.

if "`subgrp'"=="age18_39" {
	keep if sub_cat_age==0 & sub_cat_age!=.
}

if "`subgrp'"=="age40_59" {
	keep if sub_cat_age==1 & sub_cat_age!=.
}

if "`subgrp'"=="age60_79" {
	keep if sub_cat_age==2 & sub_cat_age!=.
}

if "`subgrp'"=="age80_110" {
	keep if sub_cat_age==3 & sub_cat_age!=.
}

if "`subgrp'"=="sex_f" {
	keep if cov_bin_male==0 & cov_bin_male!=.
}

if "`subgrp'"=="sex_m" {
	keep if cov_bin_male==1 & cov_bin_male!=.
}

if "`subgrp'"=="care_y" {
	keep if sub_bin_carehome==1 & sub_bin_carehome!=.
}

if "`subgrp'"=="care_n" {
	keep if sub_bin_carehome==0 & sub_bin_carehome!=.
}

if "`subgrp'"=="eth_white" {
	keep if cov_cat_ethnicity==1 & cov_cat_ethnicity!=.
}

if "`subgrp'"=="eth_black" {
	keep if cov_cat_ethnicity==2 & cov_cat_ethnicity!=.
}

if "`subgrp'"=="eth_asian" {
	keep if cov_cat_ethnicity==3 & cov_cat_ethnicity!=.
}

if "`subgrp'"=="eth_mixed" {
	keep if cov_cat_ethnicity==4 & cov_cat_ethnicity!=.
}

if "`subgrp'"=="eth_other" {
	keep if cov_cat_ethnicity==5 & cov_cat_ethnicity!=.
}

* Filter data if outcome is readmission ----------------------------------------

if strpos("`outcome'","readm") {
	local outcome_adm: subinstr local outcome "readm" "adm", all
	keep if out_date_`outcome_adm'!=.
}

* Keep relevant variables ------------------------------------------------------

keep patient_id study_start_date study_end_date out_date_`outcome' exp_* cov_*

* Make binary failure variable -------------------------------------------------

gen out_status = 0
replace out_status = 1 if out_date_`outcome'!=.

* Rename region ----------------------------------------------------------------

rename cov_cat_region region

* Put data into stset format ---------------------------------------------------

stset study_end_date, failure(out_status) id(patient_id) origin(study_start_date)

* Perform Cox analyses for single exposures ------------------------------------

foreach exposure of varlist exp_* {
	
	perform_cox "`exposure'" "`outcome'" "`cohort'" "`subgrp'"

}

* Perform Cox analyses for all exposures ---------------------------------------

vl create exposure_all = (exp_*)

perform_cox "$exposure_all" "`outcome'" "`cohort'" "`subgrp'"

* Tidy results -----------------------------------------------------------------

use "output/cox_model-`outcome'-`subgrp'-`cohort'.dta", clear
gen est = exp(coef)
gen lci = exp(ci_lower)
gen uci = exp(ci_upper)
keep cohort subgroup outcome modeltype model adj var est lci uci pval N_total N_fail risktime
order cohort subgroup outcome modeltype model adj var est lci uci pval N_total N_fail risktime

* Round results ----------------------------------------------------------------

roundmid_any "N_total" 6
roundmid_any "N_fail" 6

* Save results -----------------------------------------------------------------

export delimited using "output/cox_model-`outcome'-`subgrp'-`cohort'.csv", replace

* Save rounded results ---------------------------------------------------------

drop N_total N_fail
export delimited using "output/cox_model-`outcome'-`subgrp'-`cohort'_rounded.csv", replace
