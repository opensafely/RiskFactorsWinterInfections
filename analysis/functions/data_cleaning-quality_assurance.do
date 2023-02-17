* Program to apply quality assurance measures ----------------------------------

cap prog drop quality_assurance
prog def quality_assurance

	* Remove individuals whose year of birth is after their year of death ------

	gen death_year=year(death_date)
	drop if qa_num_birth_year>death_year
	local N = _N
	frame change consort
	replace total = `N' if criteria=="qa_birth_after_dth"
	frame change default


	* Remove individuals whose year of birth is after date of data extract -----

	gen today= date("`c(current_date)'", "DMY")
	gen year_extract=year(today)
	drop if qa_num_birth_year > year_extract
	local N = _N
	frame change consort
	replace total = `N' if criteria=="qa_birth_after_today"
	frame change default

	* Remove individuals whose date of death is after date of data extract -----

	drop if death_year > year_extract
	local N = _N
	frame change consort
	replace total = `N' if criteria=="qa_dth_after_today"
	frame change default

	* Remove men whose records contain pregnancy and/or birth codes ------------

	drop if qa_bin_pregnancy==1&cov_bin_male==1
	local N = _N
	frame change consort
	replace total = `N' if criteria=="qa_preg_men"
	frame change default

	* Remove men whose records contain HRT or COCP medication codes ------------

	drop if qa_bin_hrtcocp==1 & cov_bin_male==1
	local N = _N
	frame change consort
	replace total = `N' if criteria=="qa_hrt_cocp_men"
	frame change default


	* Remove women whose records contain prostate cancer codes -----------------

	drop if qa_bin_prostate==1 & cov_bin_male==0 
	local N = _N
	frame change consort
	replace total = `N' if criteria=="qa_prostate_women"
	frame change default

	* Drop variables created to apply quality assurance measures ---------------
	
	drop death_year today year_extract

end
