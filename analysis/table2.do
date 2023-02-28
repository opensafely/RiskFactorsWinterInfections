


use "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/clean_winter2019.dta", clear

*** Change data_clearning to keep variables: tmp_out_date_*_dis death_date 

*** Possibly make a function that can be run for each infection type.


/*** Create flags and patient level intervals ***/

* Admissions

gen count_flu_adm=0
replace count_flu_adm=1 if out_date_flu_adm!=. & (date_death>=out_date_flu_adm | date_death==.)

gen risktime_flu_adm=out_date_flu_adm - study_start_date if count_flu_adm==1 & date_death>=out_date_flu_adm
replace risktime_flu_adm=date_death - study_start_date if date_death<out_date_flu_adm  /* CHECK THIS */
replace risktime_flu_adm=study_end_date - study_start_date if count_flu_adm==0 & date_death==.

				
* Length of stay

if out_date_flu_adm!=. & date_death>=out_date_flu_adm


* Readmission within 30 days of discharge - keep tmp_out_date_*_dis variables from data cleaning
*   Only applies to those who were admitted in the first place.

gen count_flu_readm=0 if count_flu_adm==1
replace count_flu_readm=1 if out_date_flu_readm!=. & count_flu_adm==1 /* what about deaths?? */

gen risktime_flu_readm=out_date_flu_readm - tmp_out_date_flu_dis if count_flu_readm==1
replace risktime_flu_readm=

* Death

gen count_flu_death=0
replace count_flu_dth=1 if out_date_flu_death!=.

gen risktime_flu_death=out_date_flu_death - study_start_date


/*** Collapse into one row per infection using preserve/restore ***/


/*** Combine rows into one dataset ***/