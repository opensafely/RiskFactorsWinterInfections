* Create locals for arguments --------------------------------------------------

global dir `c(pwd)'

global cohort=`1' /* first argument in YAML is the cohort year, e.g. 2019 */

*global cohortyear=2019
*cd "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections"


* Load data --------------------------------------------------------------------

import delim using "./output/input_winter$cohortyear.csv", clear


* Create study start and end dates as variables --------------------------------
  * `2' is the study start date and `3' is the end date in the YAML, e.g. "td(1dec2019)"
  
gen study_start_date=`2'
gen study_end_date=`3'
format study_start_date study_end_date %td


* Format variables -------------------------------------------------------------

*cd "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections"

run "./analysis/functions/data_cleaning-format_variables.do"
format_variables 


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

run "/analysis/functions/data_cleaning-inclusion_exclusion.do"
inclusion_exclusion


* Apply quality assurance measures ---------------------------------------------

run "./analysis/functions/data_cleaning-quality_assurance.do"
quality_assurances


* Restrict dataset to relevant variables ---------------------------------------

drop registered_previous_365days sex tmp* inex qa* primary_care_death_date ons_died_from_any_cause_date ///
	 cov_num_bmi_date_measured hospitalised_previous_30days baseline_creatinine ///
	 prostate* cov_bin_combined_oral_contracept cov_bin_hormone_replacement_ther death_date ///
	 egfr ckd max study_start_minus_1yr study_start_minus_5yrs today year_extract

	 
* Compress data ----------------------------------------------------------------

compress

* Save clean data --------------------------------------------------------------


save "./output/clean_winter$cohortyear.dta", replace
