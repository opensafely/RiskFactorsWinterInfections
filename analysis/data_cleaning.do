/*==============================================================================
DO FILE NAME:			data_cleaning.do
PROJECT:				RiskFactorsWinterPressures
DATE: 					Feb 2020 
AUTHOR:					S Walter, V Walker										
DESCRIPTION OF FILE:	data management for project 
						define variables
						reformat variables 
						categorise variables
						label variables 
						apply exclusion criteria and quality assurance checks
						record record counts for consort diagram
DATASETS USED:			data in memory (from output/input_winter*.csv.gz)
STATA FUNCTIONS USED:	data_cleaning-format_variables
						data_cleaning-variable_definitions
						data_cleaning-inclusion_exclusion
						data_cleaning-quality_assurance
DATASETS CREATED: 		output/clean_winter*.dta.gz
OTHER OUTPUT: 			output/consort_*.csv	
						output/rouded_consort_*.csv
==============================================================================*/

* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6

* Source utility functions -----------------------------------------------------

run "analysis/functions/utility.do"

* Create macros for arguments --------------------------------------------------

/*
local cohort "winter2019"
local study_start_date "td(1dec2019)"
local study_end_date "td(28feb2020)"
*/

local cohort "`1'"
local study_start_date "`2'"
local study_end_date "`3'"

di "Arguments: (1) `cohort', (2) `study_start_date', and (3) `study_end_date'"

adopath + "analysis/adofiles"

* Specify consort frame --------------------------------------------------------

frame create consort
frame change consort
import delimited using lib/consort.csv
frame change default

* Load data --------------------------------------------------------------------

!gunzip output/input_`cohort'.csv.gz
import delimited using output/input_`cohort'.csv

* Format variables -------------------------------------------------------------

run "analysis/functions/data_cleaning-format_variables.do"
format_variables 

* Create study start and end dates as variables --------------------------------

gen study_start_date=`study_start_date'
gen study_end_date=`study_end_date'
format study_start_date study_end_date %td

* Define variables not in study definition -------------------------------------

run "analysis/functions/data_cleaning-variable_definitions.do"
variable_definitions

* Summarise missingness --------------------------------------------------------

misstable summarize

* Create length of hospital stay outcome with 0 for no admission ---------------

foreach outcome in  flu rsv pneustrep pneu covid {
	gen out_num_`outcome'_stay = tmp_out_date_`outcome'_dis - out_date_`outcome'_adm
	replace out_num_`outcome'_stay=0 if out_num_`outcome'_stay==.

* Definie patient-specific end of follow-up time for admissions, readmissions and death

	egen followupend_date_`outcome'_adm=rowmin(out_date_`outcome'_adm death_date study_end_date deregistration_date)
	egen followupend_date_`outcome'_readm=rowmin(out_date_`outcome'_readm death_date study_end_date deregistration_date)
	format followupend_date_`outcome'_adm followupend_date_`outcome'_readm %td
}
  
egen followupend_date_death=rowmin(death_date study_end_date deregistration_date)
format followupend_date_death %td
  
* Apply inclusion/exclusion criteria -------------------------------------------

run "analysis/functions/data_cleaning-inclusion_exclusion.do"
inclusion_exclusion

* Apply quality assurance measures ---------------------------------------------

run "analysis/functions/data_cleaning-quality_assurance.do"
quality_assurance

* Restrict dataset to relevant variables ---------------------------------------

drop registered_previous_365days qa* hospitalised_previous_30days ///
     tmp_death* tmp_exp* tmp_prostate* tmp_cov* tmp_study_start_minus*

* Compress data ----------------------------------------------------------------

compress

* Save clean data --------------------------------------------------------------

save "output/clean_`cohort'.dta", replace

* Save consort information -----------------------------------------------------

frame change consort

gen remove = total[_n-1] - total
roundmid_any "total" 6
gen remove_rounded = total_rounded[_n-1] - total_rounded

export delimited using "output/consort_`cohort'.csv", replace

drop total remove
export delimited using "output/rounded_consort_`cohort'.csv", replace
