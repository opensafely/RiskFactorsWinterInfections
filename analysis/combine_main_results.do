/*==============================================================================
	   DO FILE NAME:			combine_main_results.do
	   PROJECT:					RiskFactorsWinterPressures
	   DATE: 					Dec 2023 
	   AUTHOR:					S Walter									
	   DESCRIPTION OF FILE:	    combine main results datasets into single file
	   DATASETS USED:			output/cox_model-*-*_rounded.csv
	   STATA FUNCTIONS USED:	
	   DATASETS CREATED: 		ouput/results_main_rounded.csv
	   OTHER OUTPUT: 			
   ==============================================================================*/

* Create empty results file ---------------------------------------------------

set obs 0
gen cohort = ""
save "output/results_main_rounded.dta", replace

* Append each dataset to results file ------------------------------------------

foreach cohort in winter2019 winter2021 {

	foreach outcome in covid flu pneu pneustrep rsv {

		* For Cox model outcomes -----------------------------------------------

		foreach outcometype in adm readm death {
				
			** Confirm results file is present

			if fileexists("output/cox_model-`outcome'_`outcometype'-main-`cohort'_rounded.csv")==1 {

				** Convert results from .csv to .dta

				import delimited "output/cox_model-`outcome'_`outcometype'-main-`cohort'_rounded.csv", clear
				save "output/cox_model-`outcome'_`outcometype'-main-`cohort'_rounded.dta", replace

				** Append results 

				use "output/results_main_rounded.dta", clear
				append using "output/cox_model-`outcome'_`outcometype'-main-`cohort'_rounded.dta"
				save "output/results_main_rounded.dta", replace 				
			}

		}

		* For linear regression model outcomes ---------------------------------
		
			** Confirm results file is present

			if fileexists("output/linear_model-`outcome'_stay-main-`cohort'_rounded.csv")==1 {

				** Convert results from .csv to .dta

				import delimited "output/linear_model-`outcome'_stay-main-`cohort'_rounded.csv", clear
				save "output/linear_model-`outcome'_stay-main-`cohort'_rounded.dta", replace

				** Append results 

				use "output/results_main_rounded.dta", clear
				append using "output/linear_model-`outcome'_stay-main-`cohort'_rounded.dta"
				save "output/results_main_rounded.dta", replace 

			}

	}

}

* Save final results file as csv -----------------------------------------------

use "output/results_main_rounded.dta", clear
export delimited "output/results_main_rounded.csv", replace