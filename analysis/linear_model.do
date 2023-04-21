/*==============================================================================
   DO FILE NAME:			linear_model.do
   PROJECT:					RiskFactorsWinterPressures
   DATE: 					Mar 2020 
   AUTHOR:					V Walker, S Walter									
   DESCRIPTION OF FILE:		perform linear modelling
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
local outcome "flu_stay"
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
run "analysis/functions/linear_model-perform_linear.do"

* Create empty results file ----------------------------------------------------

set obs 0
gen model = ""
save "output/linear_model-`outcome'-`subgrp'-`cohort'.dta", replace

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

* Keep patients with hospital admission ----------------------------------------

local outcome_only: subinstr local outcome "_stay" "", all
keep if out_date_`outcome_only'_adm!=. & tmp_out_date_`outcome_only'_dis!=. & out_num_`outcome'!=.

* Keep relevant variables ------------------------------------------------------

keep patient_id out_num_`outcome' exp_* cov_*

* Perform linear regression for single exposures -------------------------------

foreach exposure of varlist exp_* {
	
	perform_linear "`exposure'" "`outcome'" "`cohort'" "`subgrp'"

}

* Perform linear regression for all exposures ----------------------------------

perform_linear "exp_*" "`outcome'" "`cohort'" "`subgrp'"

* Tidy results -----------------------------------------------------------------

use "output/linear_model-`outcome'-`subgrp'-`cohort'.dta", clear
rename coef est
rename ci_lower lci
rename ci_upper uci
gen N_fail_rounded = .
gen risktime = .
keep cohort subgroup outcome modeltype model adj var est lci uci pval N_total N_fail_rounded risktime
order cohort subgroup outcome modeltype model adj var est lci uci pval N_total N_fail_rounded risktime

* Round results ----------------------------------------------------------------

roundmid_any "N_total" 6

* Save results -----------------------------------------------------------------

export delimited using "output/linear_model-`outcome'-`subgrp'-`cohort'.csv", replace

* Save rounded results ---------------------------------------------------------

drop N_total
export delimited using "output/linear_model-`outcome'-`subgrp'-`cohort'_rounded.csv", replace
