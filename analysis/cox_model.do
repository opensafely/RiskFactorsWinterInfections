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

local cohort "winter2019" //"`1'"
local outcome "out_date_flu_adm" //"`2'"

di "Arguments: (1) `cohort'; (2) `outcome'". 

adopath + "analysis/adofiles"

* Load data --------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz, clear

* Keep relevant variables ------------------------------------------------------

keep patient_id study_start_date study_end_date `outcome' exp_* cov_*

* Make binary failure variable -------------------------------------------------

gen out_status = 0
replace out_status = 1 if `outcome'!=.

* Rename region ----------------------------------------------------------------

rename cov_cat_region region

* Put data into stset format ---------------------------------------------------

stset study_end_date, failure(out_status) id(patient_id) origin(study_start_date)

* Perform Cox analyses for single exposures ------------------------------------

foreach exposure of varlist exp_* {
	
	local estname = substr("`exposure'",9,strlen("`exposure'"))
	
	** Minimal adjustment

	stcox `outcome' `exposure' cov_num_age cov_bin_male, strata(region) vce(r)
	estout using "output/cox_model-`cohort'-`outcome'-`estname'-minadj.txt", cells("b se t ci_l ci_u p") stats(risk N_fail N_sub N N_clust) style(tab) replace 

	** Maximal adjustment
	
	stcox `outcome' `exposure' cov_*, strata(region) vce(r)
	estout using "output/cox_model-`cohort'-`outcome'-`estname'-maxadj.txt", cells("b se t ci_l ci_u p") stats(risk N_fail N_sub N N_clust) style(tab) replace 

}

* Perform Cox analyses for all exposures ---------------------------------------

** Minimal adjustment

stcox `outcome' exp_* cov_num_age cov_bin_male, strata(region) vce(r)
estout using "output/cox_model-`cohort'-`outcome'-allexp-minadj.txt", cells("b se t ci_l ci_u p") stats(risk N_fail N_sub N N_clust) style(tab) replace 

** Maximal adjustment

stcox `outcome' exp_* cov_*, strata(region) vce(r)
estout using "output/cox_model-`cohort'-`outcome'-allexp-minadj.txt", cells("b se t ci_l ci_u p") stats(risk N_fail N_sub N N_clust) style(tab) replace 
