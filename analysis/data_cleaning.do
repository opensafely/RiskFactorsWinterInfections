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
DATASETS USED:			data in memory (from output/input_winter*.csv.gz)
STATA FUNCTIONS USED:	data_cleaning-format_variables
						data_cleaning-variable_definitions
						data_cleaning-inclusion_exclusion
						data_cleaning-quality_assurance
DATASETS CREATED: 		output/clean_winter*.dta.gz
OTHER OUTPUT: 			consort*.xlsx							
==============================================================================*/


* Create macros for arguments --------------------------------------------------

cd ..
global dir `c(pwd)'

global cohort=`1' /* first argument in YAML is the cohort year, e.g. 2019 */

adopath + "$dir/analysis/adofiles"


* Load data --------------------------------------------------------------------

shell gunzip ./output/input_winter$cohort.csv.gz, replace
*import delim using "$dir/output/input_winter$cohort.csv", clear


* Create study start and end dates as variables --------------------------------
  * `2' is the study start date and `3' is the end date in the YAML, e.g. "td(1dec2019)"
  
gen study_start_date=`2'
gen study_end_date=`3'
format study_start_date study_end_date %td


* Format variables -------------------------------------------------------------

*cd "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections"

run "$dir/analysis/functions/data_cleaning-format_variables.do"
format_variables 

run "$dir/analysis/functions/data_cleaning-variable_definitions.do"
variable_definitions


*Summarise missingness

misstable summarize


* Create outcomes --------------------------------------------------------------

** Length of hospital stay -----------------------------------------------------
   * patients with no admission in the study period have stay=0

gen out_num_flu_stay = tmp_out_date_flu_dis - out_date_flu_adm
replace out_num_flu_stay=0 if out_num_flu_stay==.
			
gen out_num_rsv_stay = tmp_out_date_rsv_dis - out_date_rsv_adm
replace out_num_rsv_stay=0 if out_num_rsv_stay==.

gen out_num_pneustrep_stay = tmp_out_date_pneustrep_dis - out_date_pneustrep_adm
replace out_num_pneustrep_stay=0 if out_num_pneustrep_stay==.

gen out_num_pneu_stay = tmp_out_date_pneu_dis - out_date_pneu_adm
replace out_num_pneu_stay=0 if out_num_pneu_stay==.

gen out_num_covid_stay = tmp_out_date_covid_dis - out_date_covid_adm
replace out_num_covid_stay=0 if out_num_covid_stay==.


* Apply inclusion/exclusion criteria -------------------------------------------

run "$dir/analysis/functions/data_cleaning-inclusion_exclusion.do"
inclusion_exclusion


* Apply quality assurance measures ---------------------------------------------

run "$dir/analysis/functions/data_cleaning-quality_assurance.do"
quality_assurance


* Combine counts of excluded records and export for CONSORT flow diagram

quietly: collect layout () (exclude qa_birth_after_dth qa_birth_after_today qa_dth_after_today qa_preg_men qa_hrt_cocp_men qa_prostate_women)

collect export "$dir/output/consort$cohort.xlsx", replace


* Restrict dataset to relevant variables ---------------------------------------

drop registered_previous_365days tmp* exclude qa* hospitalised_previous_30days death_date ///
	 death_year today year_extract

	 
* Compress data ----------------------------------------------------------------

compress

* Save clean data --------------------------------------------------------------

* requires gzip to be installed
gzsave "$dir/output/clean_winter$cohort.dta.gz", replace
*save "$dir/output/clean_winter$cohort.dta.", replace
