/*==============================================================================
DO FILE NAME:			table2.do
PROJECT:				RiskFactorsWinterPressures
DATE: 					March 2020 
AUTHOR:					S Walter, V Walker										
DESCRIPTION OF FILE:	generate a table of summaru statistics for each
						infection type and each outcome 
DATASETS USED:			output/clean_winter*.dta.gz
STATA FUNCTIONS USED:	table2-make_table2
DATASETS CREATED: 		output/table2_winter*_rounded.csv
OTHER OUTPUT: 			output/table2_winter*.csv
==============================================================================*/

* Create macros for arguments --------------------------------------------------

/*
clear all
local cohort "winter2019"
*/

local cohort "`1'"

di "Arguments: (1) `cohort'"

adopath + "analysis/adofiles"

* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6

* Source functions -------------------------------------------------------------

run "analysis/functions/utility.do"
run "analysis/functions/table2-make_table2.do"

* Import cleaned data ----------------------------------------------------------

gzuse output/clean_`cohort'.dta.gz, clear

* Restrict variables -----------------------------------------------------------

keep pat* *out*

* Influenza --------------------------------------------------------------------

make_table2 "flu"

* RSV --------------------------------------------------------------------------

make_table2 "rsv"

* Pneumonia due to strep -------------------------------------------------------

make_table2 "pneustrep"

* Penumonia --------------------------------------------------------------------

make_table2 "pneu"

* Covid ------------------------------------------------------------------------

make_table2 "covid"

* Combine summary stats into one table -----------------------------------------

use output/table2los_flu.dta, clear
append using output/table2los_rsv.dta
append using output/table2los_pneustrep.dta
append using output/table2los_pneu.dta
append using output/table2los_covid.dta

save output/table2los.dta, replace

use output/table2_flu.dta, clear
append using output/table2_rsv.dta
append using output/table2_pneustrep.dta
append using output/table2_pneu.dta
append using output/table2_covid.dta

merge 1:1 infection using output/table2los.dta, nogen

* Save Table 2 -----------------------------------------------------------------

preserve

drop *_r

export delimited output/table2_`cohort'.csv, replace

restore

* Save rounded Table 2 ---------------------------------------------------------

keep infection *_r

export delimited output/rounded_table2_`cohort'.csv, replace
