* Program to apply inclusion/exclusion criteria --------------------------------

cap prog drop inclusion_exclusion
prog def inclusion_exclusion
args // TBC, please include study start and end date

* Restrict to individuals alive on study start date 

// TBC

drop if has_died==1

* Restrict to individuals registered for a minimum of 365 days prior to the study start date  

// TBC


* Restrict to individuals with known age between 18 and 110 inclusive on the study start date 

drop if cov_num_age<18|cov_num_age>110


* Restrict to individuals with known sex 

drop if sex=="NA"


* Restrict to individuals with known deprivation 

drop if cov_cat_deprivation==.


* Restrict to individuals known region 

drop if cov_cat_region==" "


* Restrict to individuals with no record of hospitalization in the 30 days prior to the study start date 

drop if hosp_admitted_1==1


* Restrict to individuals registered at the same TPP practice from 365 days prior to the study start date to the end of follow-up for that cohort 

// TBC

end
