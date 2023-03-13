/*==============================================================================
DO FILE NAME:			describe.do
PROJECT:				RiskFactorsWinterPressures
DATE: 					March 2020 
AUTHOR:					V Walker										
DESCRIPTION OF FILE:	describe contents of given file
DATASETS USED:			parsed from YAML
STATA FUNCTIONS USED:	
DATASETS CREATED: 		output/describe-*
==============================================================================*/

* Create macros for arguments --------------------------------------------------

clear all
local filename "clean_winter2019"
local filetype "dta"

// local filename "`1'"
// local filetype "`2'"

di "Arguments: (1) `file'; (2) `type'"

adopath + "analysis/adofiles"

* Import file ------------------------------------------------------------------

if ("`filetype'"=="csv") {
	!gunzip output/`filename'.csv.gz
	import delimited using output/`file'.csv
}
 
 if ("`filetype'"=="dta") {
	gzuse output/`filename'.dta.gz, clear
 }
 
* Start log --------------------------------------------------------------------

cap log close
log using output/describe-`filename', replace text

* Describe file ----------------------------------------------------------------
 
describe, detail
 
* Summarize file ---------------------------------------------------------------
 
summarize, detail
 
* Close log --------------------------------------------------------------------

log close
