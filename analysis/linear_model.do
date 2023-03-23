/*==============================================================================
   DO FILE NAME:			linear_model.do
   PROJECT:					RiskFactorsWinterPressures
   DATE: 					Feb 2020 
   AUTHOR:					V Walker									
   DESCRIPTION OF FILE:		perform linear modelling
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

clear all
local cohort "winter2019"
local outcome "flu"

/*
local cohort "`1'"
local outcome "`2'"
*/
di "Arguments: (1) `cohort'; (2) `outcome'."

adopath + "analysis/adofiles"

* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6

* Source functions -------------------------------------------------------------

run "analysis/functions/utility.do"
run "analysis/functions/linear_model-perform_linear.do"

* Create empty results file ----------------------------------------------------

set obs 0
gen model = ""
save "output/linear_model-`outcome'_stay-`cohort'.dta", replace

* Load data --------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz, clear

* Keep patients with hospital admission ----------------------------------------

keep if out_date_`outcome'_adm!=.

* Keep relevant variables ------------------------------------------------------

keep patient_id out_num_`outcome'_stay exp_* cov_*

* Perform linear regression for single exposures -------------------------------

foreach exposure of varlist exp_* {
	
	perform_linear "`exposure'" "`outcome'" "`cohort'"

}

* Perform linear regression for all exposures ----------------------------------

perform_linear "exp_*" "`outcome'" "`cohort'"

* Tidy results -----------------------------------------------------------------

use "output/linear_model-`outcome'_stay-`cohort'.dta", clear
rename coef beta
rename ci_lower lci
rename ci_upper uci
keep cohort outcome model adj var beta lci uci pval N_total
order cohort outcome model adj var beta lci uci pval N_total

* Round results ----------------------------------------------------------------

roundmid_any "N_total" 6

* Save results -----------------------------------------------------------------

export delimited using "output/linear_model-`outcome'_stay-`cohort'.csv", replace

* Save rounded results ---------------------------------------------------------

drop N_total
export delimited using "output/linrear_model-`outcome'_stay-`cohort'_rounded.csv", replace