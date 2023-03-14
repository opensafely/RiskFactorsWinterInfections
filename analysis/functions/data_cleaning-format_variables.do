* Program to format variables --------------------------------------------------

cap prog drop format_variables
prog def format_variables

	* Replace NA with missing value that Stata recognises ----------------------

	ds , has(type string)
	foreach var of varlist `r(varlist)' {
		replace `var' = "" if `var' == "NA"
	}

	* Format *_date* variables as dates ----------------------------------------

	foreach var of varlist *_date* {
		split `var', gen(tmp_date) parse(-)
		gen year = real(tmp_date1)
		gen month = real(tmp_date2)
		gen day = real(tmp_date3)
		gen `var'_tmp = mdy(month, day, year)
		format %td `var'_tmp
		drop `var' tmp_date* year month day
		rename `var'_tmp `var'
	}

	* Format cov_bin_male ------------------------------------------------------

	gen cov_bin_male_tmp=0
	replace cov_bin_male_tmp=1 if cov_bin_male=="Yes"
	label define YesNo 0 "No" 1 "Yes"
	drop cov_bin_male
	rename cov_bin_male_tmp cov_bin_male
	label values cov_bin_male YesNo

	* Format cov_cat_ethnicity -------------------------------------------------

	replace cov_cat_ethnicity = 6 if cov_cat_ethnicity==.|cov_cat_ethnicity==0
	label define ethnicity_lab 	1 "White"  						///
		2 "Mixed" 						///
		3 "Asian or Asian British"		///
		4 "Black"  						///
		5 "Other"						///
		6 "Missing"
	label values cov_cat_ethnicity ethnicity_lab

	* Format cov_cat_deprivation -----------------------------------------------

	label def deprivation_quintile 1 "1 Most deprived" 2 "2" 3 "3" 4 "4" 5 "5 Least deprived"
	lab values cov_cat_deprivation deprivation_quintile

	* Format cov_cat_smoking ---------------------------------------------------

	gen cov_cat_smoking_tmp = .
	replace cov_cat_smoking_tmp = 1 if cov_cat_smoking=="Never"
	replace cov_cat_smoking_tmp = 2 if cov_cat_smoking=="Former"
	replace cov_cat_smoking_tmp = 3 if cov_cat_smoking=="Current"
	replace cov_cat_smoking_tmp = 4 if cov_cat_smoking=="Missing"|cov_cat_smoking==""
	lab def cov_cat_smoking_tmp 1 "Never smoker" 2 "Former smoker" 3 "Current smoker" 4 "Missing"
	lab val cov_cat_smoking_tmp cov_cat_smoking_tmp
	drop cov_cat_smoking
	rename cov_cat_smoking_tmp cov_cat_smoking 

	* Format region ------------------------------------------------------------

	gen region_tmp = .
	replace region_tmp = 1 if cov_cat_region=="East"
	replace region_tmp = 2 if cov_cat_region=="East Midlands"
	replace region_tmp = 3 if cov_cat_region=="London"
	replace region_tmp = 4 if cov_cat_region=="North East"
	replace region_tmp = 5 if cov_cat_region=="North West"
	replace region_tmp = 6 if cov_cat_region=="South East"
	replace region_tmp = 7 if cov_cat_region=="South West"
	replace region_tmp = 8 if cov_cat_region=="West Midlands"
	replace region_tmp = 9 if cov_cat_region=="Yorkshire and The Humber"
	label define region_tmp 1 "East" 2 "East Midlands" 3 "London" 4 "North East" 5 "North West" 6 "South East" 7 "South West" 8 "West Midlands" 9 "Yorkshire and The Humber"
	label values region_tmp region_tmp
	drop cov_cat_region
	rename region_tmp cov_cat_region

	* Format cov_cat_obese -----------------------------------------------------

	gen obese_tmp=.
	replace obese_tmp=0 if cov_cat_obese=="NoEvidence"
	replace obese_tmp=1 if cov_cat_obese=="ObeseClassI"
	replace obese_tmp=2 if cov_cat_obese=="ObeseClassII"
	replace obese_tmp=3 if cov_cat_obese=="ObeseClassIII"
	replace obese_tmp=4 if cov_cat_obese==" "
	label define obese_categories 0 "Not obese" 1 "Obese class I" 2 "Obese class II" 3 "Obese class III" 4 "Missing"
	label values obese_tmp obese_categories
	drop cov_cat_obese
	rename obese_tmp cov_cat_obese

	* Format exp_cat_asthma ----------------------------------------------------

	gen exp_cat_asthma_tmp=0
	replace exp_cat_asthma_tmp=1 if exp_cat_asthma=="Asthma_NoRecentOCS"
	replace exp_cat_asthma_tmp=2 if exp_cat_asthma=="Asthma_RecentOCS"
	label define asthma_cats 0 "NoEvidence" 1 "Asthma_NoRecentOCS" 2 "Asthma_RecentOCS"
	drop exp_cat_asthma
	rename exp_cat_asthma_tmp exp_cat_asthma
	label values exp_cat_asthma asthma_cats

	* Format sub_cat_age -------------------------------------------------------

	gen sub_cat_age_tmp=.
	replace sub_cat_age_tmp=0 if sub_cat_age=="18-39"
	replace sub_cat_age_tmp=1 if sub_cat_age=="40-59"
	replace sub_cat_age_tmp=2 if sub_cat_age=="60-79"
	replace sub_cat_age_tmp=3 if sub_cat_age=="80-110"
	label define age_subcats ///
		0 "18-39" 1 "40-59" 2 "60-79" 3 "80-110" 4 "Missing"
	drop sub_cat_age
	rename sub_cat_age_tmp sub_cat_age
	label values sub_cat_age age_subcats

	* Format sub_bin_carehome --------------------------------------------------

	gen sub_bin_carehome_tmp=0
	replace sub_bin_carehome_tmp=1 if sub_bin_carehome=="Yes"
	drop sub_bin_carehome
	rename sub_bin_carehome_tmp sub_bin_carehome
	label values sub_bin_carehome YesNo

end
