/*==============================================================================
	   DO FILE NAME:			cox_model.do
	   PROJECT:				RiskFactorsWinterPressures
	   DATE: 					Feb 2020 
	   AUTHOR:					V Walker									
	   DESCRIPTION OF FILE:	set data and perform cox modelling
	   DATASETS USED:			output/clean_winter*.dta.gz
	   STATA FUNCTIONS USED:	
	   DATASETS CREATED: 		
	   OTHER OUTPUT: 			
   ==============================================================================*/

* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6

* Source functions -------------------------------------------------------------

run "analysis/functions/utility.do"

* Create macros for arguments --------------------------------------------------

/*
clear all
local cohort "winter2019"
local outcome "flu_death"
*/

local cohort "`1'"
local outcome "`2'"

di "Arguments: (1) `cohort'; (2) `outcome'."

adopath + "analysis/adofiles"

* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6

* Source functions -------------------------------------------------------------

run "analysis/functions/utility.do"
run "analysis/functions/cox_model-perform_cox.do"

* Create empty results file ----------------------------------------------------

set obs 0
gen model = ""
save "output/cox_model-`outcome'-`cohort'.dta", replace

* Load data --------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz, clear

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
	
	perform_cox "`exposure'" "`outcome'" "`cohort'"

}

* Perform Cox analyses for all exposures ---------------------------------------

perform_cox "exp_*" "`outcome'" "`cohort'"

* Tidy results -----------------------------------------------------------------

use "output/cox_model-`outcome'-`cohort'.dta", clear
gen est = exp(coef)
gen lci = exp(ci_lower)
gen uci = exp(ci_upper)
keep cohort outcome modeltype model adj var est lci uci pval N_total N_fail risktime
order cohort outcome modeltype model adj var est lci uci pval N_total N_fail risktime

* Round results ----------------------------------------------------------------

roundmid_any "N_total" 6
roundmid_any "N_fail" 6

* Save results -----------------------------------------------------------------

export delimited using "output/cox_model-`outcome'-`cohort'.csv", replace

* Save rounded results ---------------------------------------------------------

drop N_total N_fail
export delimited using "output/cox_model-`outcome'-`cohort'_rounded.csv", replace
