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

di "Arguments: (1) `cohort'"

adopath + "analysis/adofiles"

* Load data --------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz, clear

* Remove non time-to-event outcomes --------------------------------------------

drop out_num_*

* Make binary failure variables -------------------------------------------------

foreach outcome of varlist out_date_* {
	di "`outcome'"
	local outcome = substr("`outcome'",10,strlen("`outcome'"))
	gen out_status_`outcome' = 0
	replace out_status_`outcome' = 1 if out_date_`outcome'
}

* Make age spline --------------------------------------------------------------

centile cov_num_age, centile(10 50 90)
mkspline age_spline = cov_num_age, cubic knots(`r(c_1)' `r(c_2)' `r(c_3)')
