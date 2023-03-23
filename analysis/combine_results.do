/*==============================================================================
DO FILE NAME:			combine_results.do
PROJECT:				RiskFactorsWinterPressures
DATE: 					March 2020 
AUTHOR:					V Walker									
DESCRIPTION OF FILE:	combine results datasets into single file
DATASETS USED:			output/cox_model-*-*_rounded.csv
STATA FUNCTIONS USED:	
DATASETS CREATED: 		ouput/cox_model_rounded.csv
OTHER OUTPUT: 			
==============================================================================*/
   
 * Create empty results file ---------------------------------------------------

set obs 0
gen cohort = ""
save "output/cox_model_rounded.dta", replace

* Append each dataset to results file ------------------------------------------

foreach cohort in winter2019 winter2021 {
	
	foreach outcome in covid flu pneu pneustrep rsv {
		
		foreach outcometype in adm readm death {
		
			* Confirm results file is present
		
			if fileexists("output/cox_model-`outcome'_`outcometype'-`cohort'_rounded.csv")==1 {
			
				* Convert results from .csv to .dta
			
				import delimited "output/cox_model-`outcome'_`outcometype'-`cohort'_rounded.csv", clear
				save "output/cox_model-`outcome'_`outcometype'-`cohort'_rounded.dta", replace
				
				* Append results 
				
				use "output/cox_model_rounded.dta", clear
				append using "output/cox_model-`outcome'_`outcometype'-`cohort'_rounded.dta"
				save "output/cox_model_rounded.dta", replace 
		
			}
		
		}
			
	}
	
}

* Save final results file as csv -----------------------------------------------

use "output/cox_model_rounded.dta", clear
export delimited "output/cox_model_rounded.csv", replace