/*==============================================================================
DO FILE NAME:			table1.do
PROJECT:				RiskFactorsWinterPressures
DATE: 					Feb 2020 
AUTHOR:					S Walter										
DESCRIPTION OF FILE:	
DATASETS USED:			output/clean_winter*.dta.gz
STATA FUNCTIONS USED:	
DATASETS CREATED: 		output/table1.csv
OTHER OUTPUT: 			
==============================================================================*/


* Create macros for arguments --------------------------------------------------

/*
local cohort "winter2019"
*/

local cohort "`1'"

di "Arguments: (1) `cohort'"

adopath + "analysis/adofiles"

* Load data --------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz

/*
use "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/clean_winter2019.dta", clear
*/

* Add labels to variables ------------------------------------------------------

run "analysis/functions/table1-label_variables.do"
*run "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections/analysis/functions/table1-label_variables.do"
label_variables 


* Creat table of counts and percentages ----------------------------------------

  * Covid, 
  
	gzuse output/clean_`cohort'.dta.gz
	*use "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/clean_winter2019.dta", clear

	label_variables 

	keep if out_date_covid_adm != .

	table1_mc, vars(sub_cat_age cat \ ///
		cov_bin_male cat \ ///
		cov_cat_obese cat \ ///
		cov_cat_smoking cat \ ///
		cov_cat_ethnicity cat \ ///
		cov_cat_deprivation cat \ ///
		sub_bin_carehome bin \ ///
		exp_bin_hypertension bin \ ///
		exp_bin_chronicresp bin \ ///
		exp_cat_asthma cat \ ///
		exp_bin_chd bin \ ///
		exp_cat_diabetes cat \ ///
		exp_cat_cancer_exhaem cat \ ///
		exp_cat_cancer_haem cat \ ///
		exp_cat_kidneyfunc cat \ ///
		exp_bin_chronicliver bin \ ///
		exp_bin_stroke_dementia bin \ ///
		exp_bin_otherneuro bin \ ///
		exp_bin_transplant bin \ ///
		exp_bin_asplenia bin \ ///
		exp_bin_autoimm bin \ ///
		exp_bin_othimm bin) clear
	
		drop N_1 m_1
		drop in 1

		rename Total count_percent_covid
		rename _columna_1 count_covid
		rename _columnb_1 percent_covid
		replace percent_covid=subinstr(percent_covid, "(", "", .)
		replace percent_covid=subinstr(percent_covid, "%)", "", .)

		gen merge_id=_n

		save output/table1.dta, replace
		*save "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/table1.dta", replace
  
  
  * RSV, pneumonia+strep, penumonia, Covid
  
	foreach var of varlist pneu pneustrep rsv flu {
		gzuse output/clean_`cohort'.dta.gz
		*use "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/clean_winter2019.dta", clear

		label_variables 

		keep if out_date_`var'_adm != .

		table1_mc, vars(sub_cat_age cat \ ///
			cov_bin_male cat \ ///
			cov_cat_obese cat \ ///
			cov_cat_smoking cat \ ///
			cov_cat_ethnicity cat \ ///
			cov_cat_deprivation cat \ ///
			sub_bin_carehome bin \ ///
			exp_bin_hypertension bin \ ///
			exp_bin_chronicresp bin \ ///
			exp_cat_asthma cat \ ///
			exp_bin_chd bin \ ///
			exp_cat_diabetes cat \ ///
			exp_cat_cancer_exhaem cat \ ///
			exp_cat_cancer_haem cat \ ///
			exp_cat_kidneyfunc cat \ ///
			exp_bin_chronicliver bin \ ///
			exp_bin_stroke_dementia bin \ ///
			exp_bin_otherneuro bin \ ///
			exp_bin_transplant bin \ ///
			exp_bin_asplenia bin \ ///
			exp_bin_autoimm bin \ ///
			exp_bin_othimm bin) clear
	
		drop N_1 m_1
		drop in 1

		rename Total count_percent_`var'
		rename _columna_1 count_`var'
		rename _columnb_1 percent_`var'
		replace percent_`var'=subinstr(percent_`var', "(", "", .)
		replace percent_`var'=subinstr(percent_`var', "%)", "", .)

		gen merge_id=_n

	
		merge 1:m merge_id using output/table1.dta
		*merge 1:m merge_id using "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/table1.dta"

		save output/table1.dta, replace
		*save "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/table1.dta", replace
	}

	
	* Overall summary stats
	
	table1_mc, vars(sub_cat_age cat \ ///
		cov_bin_male cat \ ///
		cov_cat_obese cat \ ///
		cov_cat_smoking cat \ ///
		cov_cat_ethnicity cat \ ///
		cov_cat_deprivation cat \ ///
		sub_bin_carehome bin \ ///
		exp_bin_hypertension bin \ ///
		exp_bin_chronicresp bin \ ///
		exp_cat_asthma cat \ ///
		exp_bin_chd bin \ ///
		exp_cat_diabetes cat \ ///
		exp_cat_cancer_exhaem cat \ ///
		exp_cat_cancer_haem cat \ ///
		exp_cat_kidneyfunc cat \ ///
		exp_bin_chronicliver bin \ ///
		exp_bin_stroke_dementia bin \ ///
		exp_bin_otherneuro bin \ ///
		exp_bin_transplant bin \ ///
		exp_bin_asplenia bin \ ///
		exp_bin_autoimm bin \ ///
		exp_bin_othimm bin) clear
	
	drop N_1 m_1
	drop in 1

	rename Total count_percent_all
	rename _columna_1 count_all
	rename _columnb_1 percent_all
	replace percent_all=subinstr(percent_all, "(", "", .)
	replace percent_all=subinstr(percent_all, "%)", "", .)

	gen merge_id=_n

	merge 1:m merge_id using output/table1.dta
	*merge 1:m merge_id using "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/table1.dta"

	
* save final table as CSV
	
	export delimited output/table1_`cohort'.csv, replace
	*export delimited "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/table1.csv", replace
