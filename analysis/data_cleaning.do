* Create locals for arguments --------------------------------------------------

local cohort "`1'"

* Load data --------------------------------------------------------------------

import delim using "./output/input_`cohort'.csv.gz", clear


* Format variables -------------------------------------------------------------

run "./analysis/functions/data_cleaning-format_variables.do"
format_variables


* Create outcomes --------------------------------------------------------------

** Length of hospital stay -----------------------------------------------------
   * patients with no admission in th study period have stay=0

gen out_num_flu_stay=0
replace out_num_flu_stay = tmp_out_date_flu_dis - out_date_flu_adm if out_date_flu_adm!=.
			
gen out_num_rsv_stay=0
replace out_num_rsv_stay = tmp_out_date_rsv_dis - out_date_rsv_adm if out_date_rsv_adm!=.

gen out_num_pneustrep_stay=0
replace out_num_pneustrep_stay = tmp_out_date_pneustrep_dis - out_date_pneustrep_adm if out_date_pneustrep_adm!=.

gen out_num_pneu_stay=0
replace out_num_pneu_stay = tmp_out_date_pneu_dis - out_date_pneu_adm if out_date_pneu_adm!=.

gen out_num_covid_stay=0
replace out_num_covid_stay = tmp_out_date_covid_dis - out_date_covid_adm if out_date_covid_adm!=.



* Apply inclusion/exclusion criteria -------------------------------------------

run "./analysis/functions/data_cleaning-inclusion_exclusion.do"
inclusion_exclusion


* Apply quality assurance measures ---------------------------------------------

run "./analysis/functions/data_cleaning-quality_assurance.do"
quality_assurances


* Restrict dataset to relevant variables ---------------------------------------

// TBC, please remove QA and other variables that are not used downstream

drop registered_previous_365days sex tmp* inex qa* primary_care_death_date ons_died_from_any_cause_date ///
	 cov_num_bmi_date_measured hosp_admitted_1 baseline_creatinine ///
	 prostate* cov_bin_combined_oral_contracept cov_bin_hormone_replacement_ther death_date

	 
* Compress data ----------------------------------------------------------------

compress

* Save clean data --------------------------------------------------------------

// TBC, please use name "clean_`cohort'"

save "./output/clean_`cohort'.dta"
