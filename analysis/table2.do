/*==============================================================================
DO FILE NAME:			table2.do
PROJECT:				RiskFactorsWinterPressures
DATE: 					March 2020 
AUTHOR:					S Walter, V Walker										
DESCRIPTION OF FILE:	generate a table of summaru statistics for each
						infection type and each outcome 
DATASETS USED:			output/clean_winter*.dta.gz
STATA FUNCTIONS USED:	table1-label_variables
DATASETS CREATED: 		output/table2_winter*_rounded.csv
OTHER OUTPUT: 			output/table2_winter*.csv
==============================================================================*/


* Specify redaction_threshold --------------------------------------------------

local redaction_threshold 6

* Source functions -------------------------------------------------------------

run "analysis/functions/utility.do"

* Create macros for arguments --------------------------------------------------

local cohort "`1'"

di "Arguments: (1) `cohort'"

adopath + "analysis/adofiles"


gzuse output/clean_`cohort'.dta.gz, clear
use "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/clean_winter2019.dta", clear

* Influenza --------------------------------------------------------------------

make_table2 "`cohort'" "flu"

* RSV --------------------------------------------------------------------------

make_table2 "`cohort'" "rsv"

* Pneumonia due to strep -------------------------------------------------------

make_table2 "`cohort'" "pneustrep"

* Penumonia --------------------------------------------------------------------

make_table2 "`cohort'" "pneu"

* Covid ------------------------------------------------------------------------

make_table2 "`cohort'" "covid"

* Combine summary stats into one table

append 


* Save Table 2 -----------------------------------------------------------------

export delimited output/table2_`cohort'.csv, replace

* Save rounded Table 2 ---------------------------------------------------------

export delimited output/rounded_table2_`cohort'.csv, replace
