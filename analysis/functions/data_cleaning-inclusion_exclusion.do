* Program to apply inclusion/exclusion criteria --------------------------------

cap prog drop inclusion_exclusion
prog def inclusion_exclusion

	* Record number of records in input ----------------------------------------
	
	local N = _N
	frame change consort
	replace total = `N' if criteria=="input"
	frame change default

	* Restrict to individuals alive on study start date 

	drop if death_date<=study_start_date
	local N = _N
	frame change consort
	replace total = `N' if criteria=="alive"
	frame change default
	
	* Restrict to individuals registered at the same TPP practice from 365 days prior to the study start date to the end of follow-up for that cohort   

	drop if registered_previous_365days==0
	local N = _N
	frame change consort
	replace total = `N' if criteria=="active_registration"
	frame change default
	
	* Restrict to individuals with known age between 18 and 110 inclusive on the study start date 

	drop if cov_num_age<18|cov_num_age>110
	local N = _N
	frame change consort
	replace total = `N' if criteria=="known_age"
	frame change default
	
	* Restrict to individuals with known sex

	drop if cov_bin_male==.
	local N = _N
	frame change consort
	replace total = `N' if criteria=="known_sex"
	frame change default
	
	* Restrict to individuals with known deprivation 

	drop if cov_cat_deprivation==.
	local N = _N
	frame change consort
	replace total = `N' if criteria=="known_deprivation"
	frame change default
	
	* Restrict to individuals known region 

	drop if cov_cat_region==.
	local N = _N
	frame change consort
	replace total = `N' if criteria=="known_region"
	frame change default
	
	* Restrict to individuals with no record of hospitalization in the 30 days prior to the study start date 

	drop if hospitalised_previous_30days==1
	local N = _N
	frame change consort
	replace total = `N' if criteria=="no_recent_hospitalization"
	frame change default

end
