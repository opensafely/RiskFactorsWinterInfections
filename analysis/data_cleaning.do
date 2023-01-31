* Create locals for arguments --------------------------------------------------

local cohort "`1'"

* Load data --------------------------------------------------------------------

import delim using "./output/input_`cohort'.csv.gz", clear

* Format variables -------------------------------------------------------------

run "./analysis/functions/data_cleaning-format_variables.do"
format_variables

* Create outcomes --------------------------------------------------------------

** Length of hospital stay -----------------------------------------------------

gen out_num_flu_stay=0
replace out_num_flu_stay = tmp_out_date_flu_dis - out_date_flu_adm if tmp_out_date_flu_dis!=. & out_date_flu_adm !=.


** Readmission within 30 days --------------------------------------------------



* Apply quality assurance measures ---------------------------------------------

run "./analysis/functions/data_cleaning-quality_assurance.do"
quality_assurances

* Apply inclusion/exclusion criteria -------------------------------------------

run "./analysis/functions/data_cleaning-inclusion_exclusion.do"
inclusion_exclusion

* Restrict dataset to relevant variables ---------------------------------------

// TBC, please remove QA and other variables that are not used downstream

drop has_died registered_previous_365days sex tmp* inex qa*

* Compress data ----------------------------------------------------------------

compress

* Save clean data --------------------------------------------------------------

// TBC, please use name "clean_`cohort'"
