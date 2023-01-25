* Create locals for arguments --------------------------------------------------

local cohort "`1'"

* Load data --------------------------------------------------------------------

import delim using "./output/input_`cohort'.csv.gz", clear

* Format variables -------------------------------------------------------------

run "./analysis/functions/data_cleaning-format_variables.do"
format_variables

* Create outcomes --------------------------------------------------------------

** Length of hospital stay -----------------------------------------------------

// TBC

** Readmission within 30 days --------------------------------------------------

// TBC

* Apply quality assurance measures ---------------------------------------------

run "./analysis/functions/data_cleaning-quality_assurance.do"
quality_assurances

* Apply inclusion/exclusion criteria -------------------------------------------

run "./analysis/functions/data_cleaning-inclusion_exclusion.do"
inclusion_exclusion

* Restrict dataset to relevant variables ---------------------------------------

// TBC, please remove QA and other variables that are not used downstream

* Compress data ----------------------------------------------------------------

compress

* Save clean data --------------------------------------------------------------

// TBC, please use name "clean_`cohort'"
