/*==============================================================================
DO FILE NAME:			table1.do
PROJECT:				RiskFactorsWinterPressures
DATE: 					Feb 2020 
AUTHOR:					S Walter										
DESCRIPTION OF FILE:	generate a table of counts and percentages 
						for risk factors and covariates both overall and for 
						each outcome condition
DATASETS USED:			output/clean_winter*.dta.gz
STATA FUNCTIONS USED:	table1-label_variables
DATASETS CREATED: 		output/table1_winter*_rounded.csv
OTHER OUTPUT: 			output/table1_winter*.csv
==============================================================================*/


* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6


* Create macros for arguments --------------------------------------------------

/*
local cohort "winter2019"
*/

local cohort "`1'"

di "Arguments: (1) `cohort'"

adopath + "analysis/adofiles"


*** Overall summary stats ------------------------------------------------------

* Load data

gzuse output/clean_`cohort'.dta.gz
*use "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/clean_winter2019.dta", clear


* Add labels to variables 

run "analysis/functions/table1-label_variables.do"
*run "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/analysis/functions/table1-label_variables.do"
label_variables 


* Create table of counts and percentages 

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


drop in 1

* Layout
rename _columna_1 count_all
rename _columnb_1 percent_all
replace percent_all=subinstr(percent_all, "(", "", .)
replace percent_all=subinstr(percent_all, "%)", "", .)
replace factor=factor[_n-1] if factor==""
replace factor="N=" if _n==1

* Column for total obs: exact and rounded
gen N=subinstr(N_1, ",", "", .) if _n==1
destring N, replace
replace N=N[_n-1] if N==.


gen rnd_N = ceil(N/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(N!=0)*(N!=.))
*gen rnd_N = ceil(N/6)*6 - (floor(6/2)*(N!=0)*(N!=.))


* Convert counts and %s to numeric
gen count_all_tmp=subinstr(count_all, ",", "", .)
destring count_all_tmp, replace
drop count_all
rename count_all_tmp count_all

gen percent_all_tmp=subinstr(percent_all, ",", "", .)
destring percent_all_tmp, replace
drop percent_all
rename percent_all_tmp percent_all


* Create rounded version of counts
gen rnd_count_all = ceil(rnd_count_all_tmp/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(rnd_count_all_tmp!=0)*(rnd_count_all_tmp!=.))
*gen rnd_count_all = ceil(count_all/6)*6 - (floor(6/2)*(count_all!=0)*(count_all!=.))

replace count_all=N if _n==1
replace rnd_count_all=rnd_N if _n==1


* Calculate percentages based on rounded counts. 
gen rnd_percent_all=round(100*rnd_count_all/rnd_N, 0.1)

gen sort_order=_n

drop N_1 m_1 N rnd_N Total


save output/table1.dta, replace
*save "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", replace



*** Covid ----------------------------------------------------------------------

* Load data

gzuse output/clean_`cohort'.dta.gz
*use "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/clean_winter2019.dta", clear


* Add labels to variables 

label_variables 


* Create table of counts and percentages 
  
keep if out_date_covid_adm!=.|out_date_covid_death!=. 

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
	
drop in 1

* Layout
rename _columna_1 count_covid
rename _columnb_1 percent_covid
replace percent_covid=subinstr(percent_covid, "(", "", .)
replace percent_covid=subinstr(percent_covid, "%)", "", .)
replace factor=factor[_n-1] if factor==""
replace factor="N=" if _n==1

* Column for total obs: exact and rounded
gen N=subinstr(N_1, ",", "", .) if _n==1
destring N, replace
replace N=N[_n-1] if N==.


gen rnd_N = ceil(N/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(N!=0)*(N!=.))
*gen rnd_N = ceil(N/6)*6 - (floor(6/2)*(N!=0)*(N!=.))


* Convert counts and %s to numeric
gen count_covid_tmp=subinstr(count_covid, ",", "", .)
destring count_covid_tmp, replace
drop count_covid
rename count_covid_tmp count_covid

gen percent_covid_tmp=subinstr(percent_covid, ",", "", .)
destring percent_covid_tmp, replace
drop percent_covid
rename percent_covid_tmp percent_covid


* Create rounded version of counts
gen rnd_count_covid = ceil(rnd_count_covid_tmp/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(rnd_count_covid_tmp!=0)*(rnd_count_covid_tmp!=.))
*gen rnd_count_covid = ceil(count_covid/6)*6 - (floor(6/2)*(count_covid!=0)*(count_covid!=.))

replace count_covid=N if _n==1
replace rnd_count_covid=rnd_N if _n==1


* Calculate percentages based on rounded counts. 
gen rnd_percent_covid=round(100*rnd_count_covid/rnd_N, 0.1)

gen sort_order=_n

drop N_1 m_1 N rnd_N Total


* Append results onto master Table 1 file

merge 1:m factor level using output/table1.dta, nogen
*merge 1:m factor level using "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", nogen

save output/table1.dta, replace
*save "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", replace

 

*** Pneumonia ------------------------------------------------------------------

* Load data

gzuse output/clean_`cohort'.dta.gz
*use "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/clean_winter2019.dta", clear


* Add labels to variables 

label_variables 


* Create table of counts and percentages 
  
keep if out_date_pneu_adm!=.|out_date_pneu_death!=.

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
	
drop in 1

* Layout
rename _columna_1 count_pneu
rename _columnb_1 percent_pneu
replace percent_pneu=subinstr(percent_pneu, "(", "", .)
replace percent_pneu=subinstr(percent_pneu, "%)", "", .)
replace factor=factor[_n-1] if factor==""
replace factor="N=" if _n==1

* Column for total obs: exact and rounded
gen N=subinstr(N_1, ",", "", .) if _n==1
destring N, replace
replace N=N[_n-1] if N==.


gen rnd_N = ceil(N/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(N!=0)*(N!=.))
*gen rnd_N = ceil(N/6)*6 - (floor(6/2)*(N!=0)*(N!=.))


* Convert counts and %s to numeric
gen count_pneu_tmp=subinstr(count_pneu, ",", "", .)
destring count_pneu_tmp, replace
drop count_pneu
rename count_pneu_tmp count_pneu

gen percent_pneu_tmp=subinstr(percent_pneu, ",", "", .)
destring percent_pneu_tmp, replace
drop percent_pneu
rename percent_pneu_tmp percent_pneu


* Create rounded version of counts
gen rnd_count_pneu = ceil(rnd_count_pneu_tmp/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(rnd_count_pneu_tmp!=0)*(rnd_count_pneu_tmp!=.))
*gen rnd_count_pneu = ceil(count_pneu/6)*6 - (floor(6/2)*(count_pneu!=0)*(count_pneu!=.))

replace count_pneu=N if _n==1
replace rnd_count_pneu=rnd_N if _n==1


* Calculate percentages based on rounded counts. 
gen rnd_percent_pneu=round(100*rnd_count_pneu/rnd_N, 0.1)

gen sort_order=_n

drop N_1 m_1 N rnd_N Total


* Append results onto master Table 1 file

merge 1:m factor level using output/table1.dta, nogen
*merge 1:m factor level using "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", nogen

save output/table1.dta, replace
*save "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", replace



*** Pneumonia due to strep -----------------------------------------------------

* Load data

gzuse output/clean_`cohort'.dta.gz
*use "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/clean_winter2019.dta", clear


* Add labels to variables 

label_variables 


* Create table of counts and percentages 
  
keep if out_date_pneustrep_adm!=.|out_date_pneustrep_death!=.

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
	
drop in 1

* Layout
rename _columna_1 count_pneustrep
rename _columnb_1 percent_pneustrep
replace percent_pneustrep=subinstr(percent_pneustrep, "(", "", .)
replace percent_pneustrep=subinstr(percent_pneustrep, "%)", "", .)
replace factor=factor[_n-1] if factor==""
replace factor="N=" if _n==1

* Column for total obs: exact and rounded
gen N=subinstr(N_1, ",", "", .) if _n==1
destring N, replace
replace N=N[_n-1] if N==.


gen rnd_N = ceil(N/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(N!=0)*(N!=.))
*gen rnd_N = ceil(N/6)*6 - (floor(6/2)*(N!=0)*(N!=.))


* Convert counts and %s to numeric
gen count_pneustrep_tmp=subinstr(count_pneustrep, ",", "", .)
destring count_pneustrep_tmp, replace
drop count_pneustrep
rename count_pneustrep_tmp count_pneustrep

gen percent_pneustrep_tmp=subinstr(percent_pneustrep, ",", "", .)
destring percent_pneustrep_tmp, replace
drop percent_pneustrep
rename percent_pneustrep_tmp percent_pneustrep


* Create rounded version of counts
gen rnd_count_pneustrep = ceil(rnd_count_pneustrep_tmp/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(rnd_count_pneustrep_tmp!=0)*(rnd_count_pneustrep_tmp!=.))
*gen rnd_count_pneustrep = ceil(count_pneustrep/6)*6 - (floor(6/2)*(count_pneustrep!=0)*(count_pneustrep!=.))

replace count_pneustrep=N if _n==1
replace rnd_count_pneustrep=rnd_N if _n==1


* Calculate percentages based on rounded counts. 
gen rnd_percent_pneustrep=round(100*rnd_count_pneustrep/rnd_N, 0.1)

gen sort_order=_n

drop N_1 m_1 N rnd_N Total



* Append results onto master Table 1 file

merge 1:m factor level using output/table1.dta, nogen
*merge 1:m factor level using "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", nogen

save output/table1.dta, replace
*save "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", replace



*** RSV ------------------------------------------------------------------------

* Load data

gzuse output/clean_`cohort'.dta.gz
*use "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/clean_winter2019.dta", clear


* Add labels to variables 

label_variables 


* Create table of counts and percentages 
  
keep if out_date_rsv_adm!=.|out_date_rsv_death!=.

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
	
drop in 1

* Layout
rename _columna_1 count_rsv
rename _columnb_1 percent_rsv
replace percent_rsv=subinstr(percent_rsv, "(", "", .)
replace percent_rsv=subinstr(percent_rsv, "%)", "", .)
replace factor=factor[_n-1] if factor==""
replace factor="N=" if _n==1

* Column for total obs: exact and rounded
gen N=subinstr(N_1, ",", "", .) if _n==1
destring N, replace
replace N=N[_n-1] if N==.


gen rnd_N = ceil(N/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(N!=0)*(N!=.))
*gen rnd_N = ceil(N/6)*6 - (floor(6/2)*(N!=0)*(N!=.))


* Convert counts and %s to numeric
gen count_rsv_tmp=subinstr(count_rsv, ",", "", .)
destring count_rsv_tmp, replace
drop count_rsv
rename count_rsv_tmp count_rsv

gen percent_rsv_tmp=subinstr(percent_rsv, ",", "", .)
destring percent_rsv_tmp, replace
drop percent_rsv
rename percent_rsv_tmp percent_rsv


* Create rounded version of counts
gen rnd_count_rsv = ceil(rnd_count_rsv_tmp/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(rnd_count_rsv_tmp!=0)*(rnd_count_rsv_tmp!=.))
*gen rnd_count_rsv = ceil(count_rsv/6)*6 - (floor(6/2)*(count_rsv!=0)*(count_rsv!=.))

replace count_rsv=N if _n==1
replace rnd_count_rsv=rnd_N if _n==1


* Calculate percentages based on rounded counts. 
gen rnd_percent_rsv=round(100*rnd_count_rsv/rnd_N, 0.1)

gen sort_order=_n

drop N_1 m_1 N rnd_N Total



* Append results onto master Table 1 file

merge 1:m factor level using output/table1.dta, nogen
*merge 1:m factor level using "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", nogen

save output/table1.dta, replace
*save "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", replace



*** Influenza ------------------------------------------------------------------

* Load data

gzuse output/clean_`cohort'.dta.gz
*use "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/clean_winter2019.dta", clear


* Add labels to variables 

label_variables 


* Create table of counts and percentages 
  
keep if out_date_flu_adm!=.|out_date_flu_death!=.

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
	
drop in 1

* Layout
rename _columna_1 count_flu
rename _columnb_1 percent_flu
replace percent_flu=subinstr(percent_flu, "(", "", .)
replace percent_flu=subinstr(percent_flu, "%)", "", .)
replace factor=factor[_n-1] if factor==""
replace factor="N=" if _n==1

* Column for total obs: exact and rounded
gen N=subinstr(N_1, ",", "", .) if _n==1
destring N, replace
replace N=N[_n-1] if N==.


gen rnd_N = ceil(N/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(N!=0)*(N!=.))
*gen rnd_N = ceil(N/6)*6 - (floor(6/2)*(N!=0)*(N!=.))


* Convert counts and %s to numeric
gen count_flu_tmp=subinstr(count_flu, ",", "", .)
destring count_flu_tmp, replace
drop count_flu
rename count_flu_tmp count_flu

gen percent_flu_tmp=subinstr(percent_flu, ",", "", .)
destring percent_flu_tmp, replace
drop percent_flu
rename percent_flu_tmp percent_flu


* Create rounded version of counts
gen rnd_count_flu = ceil(rnd_count_flu_tmp/`redaction_threshold')*`redaction_threshold' - (floor(`redaction_threshold'/2)*(rnd_count_flu_tmp!=0)*(rnd_count_flu_tmp!=.))
*gen rnd_count_flu = ceil(count_flu/6)*6 - (floor(6/2)*(count_flu!=0)*(count_flu!=.))

replace count_flu=N if _n==1
replace rnd_count_flu=rnd_N if _n==1


* Calculate percentages based on rounded counts. 
gen rnd_percent_flu=round(100*rnd_count_flu/rnd_N, 0.1)

gen sort_order=_n

drop N_1 m_1 N rnd_N Total



* Append results onto master Table 1 file

merge 1:m factor level using output/table1.dta, nogen
*merge 1:m factor level using "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", nogen

save output/table1.dta, replace
*save "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1.dta", replace

	
*** Save final tables as CSV ----------------------------------------------------

sort sort_order
drop sort_order

* Rounded
preserve

drop count_all percent_all count_flu percent_flu count_rsv percent_rsv count_pneustrep percent_pneustrep count_pneu percent_pneu count_covid percent_covid

export delimited output/table1_`cohort'_rounded.csv, replace
*export delimited "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1_rounded.csv", replace

restore

drop rnd*

export delimited output/table1_`cohort'csv, replace
*export delimited "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/output/table1csv", replace
