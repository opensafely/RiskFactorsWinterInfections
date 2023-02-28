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

* Source functions -------------------------------------------------------------

run "analysis/functions/utility.do"
run "analysis/functions/table1-make_table1.do"

* Create macros for arguments --------------------------------------------------

local cohort "`1'"

di "Arguments: (1) `cohort'"

adopath + "analysis/adofiles"

* All --------------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz, clear

make_table1 "`cohort'" "all"

* COVID-19 ---------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz, clear
  
keep if out_date_covid_adm!=.|out_date_covid_death!=. 

make_table1 "`cohort'" "covid"

* Pneumonia --------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz
  
keep if out_date_pneu_adm!=.|out_date_pneu_death!=.

make_table1 "`cohort'" "pneu"

* Pneumonia due to strep -------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz
  
keep if out_date_pneustrep_adm!=.|out_date_pneustrep_death!=.

make_table1 "`cohort'" "pneustrep" 

* RSV --------------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz

keep if out_date_rsv_adm!=.|out_date_rsv_death!=.

make_table1 "`cohort'" "rsv"

* Influenza --------------------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz
  
keep if out_date_flu_adm!=.|out_date_flu_death!=.

make_table1 "`cohort'" "flu"

* Combine table 1 all with each outcome ----------------------------------------

use output/table1_`cohort'_all.dta, clear

foreach outcome in covid flu pneu pneustrep rsv {	
	merge 1:m factor level using output/table1_`cohort'_`outcome'.dta, nogen
}

* Sort and rename variables ----------------------------------------------------

sort sort_order
drop sort_order

rename factor characteristic
rename level category

* Save Table 1 -----------------------------------------------------------------

export delimited output/table1_`cohort'.csv, replace

* Save rounded Table 1 ---------------------------------------------------------

keep characteristic category *_rounded
export delimited output/rounded_table1_`cohort'.csv, replace
