* Program to apply inclusion/exclusion criteria --------------------------------

cap prog drop inclusion_exclusion
prog def inclusion_exclusion

* initiate count of excluded records
gen exclude=0

* Restrict to individuals alive on study start date 

replace exclude=1 if death_date<=study_start_date


* Restrict to individuals registered at the same TPP practice from 365 days prior to the study start date to the end of follow-up for that cohort   

replace exclude=1 if registered_previous_365days==0


* Restrict to individuals with known age between 18 and 110 inclusive on the study start date 

replace exclude=1 if cov_num_age<18|cov_num_age>110


* Restrict to individuals with known sex 

replace exclude=1 if sex==""


* Restrict to individuals with known deprivation 

replace exclude=1 if cov_cat_deprivation==.


* Restrict to individuals known region 

replace exclude=1 if cov_cat_region==.


* Restrict to individuals with no record of hospitalization in the 30 days prior to the study start date 

replace exclude=1 if hospitalised_previous_30days==1


* record total records excluded

quietly: table () (exclude), statistic(frequency) name(consort)

drop if exclude=1

end
