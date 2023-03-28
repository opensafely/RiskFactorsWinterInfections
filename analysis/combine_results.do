/*==============================================================================
	   DO FILE NAME:			combine_results.do
	   PROJECT:				RiskFactorsWinterPressures
	   DATE: 					March 2020 
	   AUTHOR:					V Walker, S Walter									
	   DESCRIPTION OF FILE:	combine results datasets into single file
	   DATASETS USED:			output/cox_model-*-*_rounded.csv
	   STATA FUNCTIONS USED:	
	   DATASETS CREATED: 		ouput/cox_model_rounded.csv
	   OTHER OUTPUT: 			
   ==============================================================================*/

* Create empty results file ---------------------------------------------------

set obs 0
gen cohort = ""
save "output/results_rounded.dta", replace

* Append each dataset to results file ------------------------------------------

foreach cohort in winter2019 winter2021 {

	foreach outcome in covid flu pneu pneustrep rsv {

		* For Cox model outcomes -----------------------------------------------

		foreach outcometype in adm readm death {
			
			* Subgroups --------------------------------------------------------

			foreach subgrp in age18_39 age40_59 age60_79 age80_110 sex_f sex_m care_y care_n eth_white eth_black eth_asian eth_mixed eth_other {
				
				** Confirm results file is present

				if fileexists("output/cox_model-`outcome'_`outcometype'-`subgrp'-`cohort'_rounded.csv")==1 {

					** Convert results from .csv to .dta

					import delimited "output/cox_model-`outcome'_`outcometype'-`subgrp'-`cohort'_rounded.csv", clear
					save "output/cox_model-`outcome'_`outcometype'-`subgrp'-`cohort'_rounded.dta", replace

					** Append results 

					use "output/results_rounded.dta", clear
					append using "output/cox_model-`outcome'_`outcometype'-`subgrp'-`cohort'_rounded.dta"
					save "output/results_rounded.dta", replace 
				}
				
			}

		}

		* For linear regression model outcomes ---------------------------------
		
		* Subgroups --------------------------------------------------------

		foreach subgrp in age18_39 age40_59 age60_79 age80_110 sex_f sex_m care_y care_n eth_white eth_black eth_asian eth_mixed eth_other {

			** Confirm results file is present

			if fileexists("output/linear_model-`outcome'_stay-`subgrp'-`cohort'_rounded.csv")==1 {

				** Convert results from .csv to .dta

				import delimited "output/linear_model-`outcome'_stay-`subgrp'-`cohort'_rounded.csv", clear
				save "output/linear_model-`outcome'_stay-`subgrp'-`cohort'_rounded.dta", replace

				** Append results 

				use "output/results_rounded.dta", clear
				append using "output/linear_model-`outcome'_stay-`subgrp'-`cohort'_rounded.dta"
				save "output/results_rounded.dta", replace 

			}
			
		}

	}

}

* Save final results file as csv -----------------------------------------------

use "output/results_rounded.dta", clear
export delimited "output/results_rounded.csv", replace
