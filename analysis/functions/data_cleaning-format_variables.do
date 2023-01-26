* Program to format variables -------------------------------------------------

cap prog drop format_variables
prog def format_variables
args // TBC, please include study start and end date

* Replace NA with missing value that Stata recognises --------------------------

ds , has(type string)
foreach var of varlist `r(varlist)' {
	replace `var' = "" if `var' == "NA"
}

* Format _date_ variables as dates ---------------------------------------------


foreach var of varlist exposure_date outcome_date follow_up_start follow_up_end {
	split `var', gen(tmp_date) parse(-)
	gen year = real(tmp_date1)
	gen month = real(tmp_date2)
	gen day = real(tmp_date3)
	gen `var'_tmp = mdy(month, day, year)
	format %td `var'_tmp
	drop `var' tmp_date* year month day
	rename `var'_tmp `var'
}


* Format _bin_ variables as logicals -------------------------------------------

foreach var of varlist exp_bin* cov_bin* sub_bin* qa_bin* inex_bin_registered {
	encode `var', gen(`var'_tmp)
	drop `var'
	rename `var'_tmp `var'
}

* Format _num_ variables as numeric --------------------------------------------

// TBC

* Format _cat_ variables as categoricals ---------------------------------------

// TBC, please include a missing category when needed and set reference categories


* Recode ethnicity

gen ethnicity_tmp = .
replace ethnicity_tmp = 1 if ethnicity=="White"
replace ethnicity_tmp = 2 if ethnicity=="Mixed"
replace ethnicity_tmp = 3 if ethnicity=="South Asian"
replace ethnicity_tmp = 4 if ethnicity=="Black"
replace ethnicity_tmp = 5 if ethnicity=="Other"
replace ethnicity_tmp = 6 if ethnicity=="Missing"
lab def ethnicity_tmp 1 "White, inc. miss" 2 "Mixed" 3 "South Asian" 4 "Black" 5 "Other" 6 "Missing"
lab val ethnicity_tmp ethnicity_tmp
drop ethnicity
rename ethnicity_tmp cov_cat_ethnicity

* Alternative Ethnicity (5 category)
replace ethnicity = 6 if ethnicity==.
label define ethnicity_lab 	1 "White"  						///
							2 "Mixed" 						///
							3 "Asian or Asian British"		///
							4 "Black"  						///
							5 "Other"						///
							6 "Unknown"
label values ethnicity ethnicity_lab


* Recode deprivation

gen cov_cat_deprivation_tmp = .
replace cov_cat_deprivation_tmp = 1 if cov_cat_deprivation=="1-2 (most deprived)"
replace cov_cat_deprivation_tmp = 2 if cov_cat_deprivation=="3-4"
replace cov_cat_deprivation_tmp = 3 if cov_cat_deprivation=="5-6"
replace cov_cat_deprivation_tmp = 4 if cov_cat_deprivation=="7-8"
replace cov_cat_deprivation_tmp = 5 if cov_cat_deprivation=="9-10 (least deprived)"
lab def cov_cat_deprivation_tmp 1 "1-2 (most deprived)" 2 "3-4" 3 "5-6" 4 "7-8" 5 "9-10 (least deprived)"
lab val cov_cat_deprivation_tmp cov_cat_deprivation_tmp
drop cov_cat_deprivation
rename cov_cat_deprivation_tmp cov_cat_deprivation

* Recode smoking status

gen cov_cat_smoking_status_tmp = .
replace cov_cat_smoking_status_tmp = 1 if cov_cat_smoking_status=="Never smoker"
replace cov_cat_smoking_status_tmp = 2 if cov_cat_smoking_status=="Ever smoker"
replace cov_cat_smoking_status_tmp = 3 if cov_cat_smoking_status=="Current smoker"
replace cov_cat_smoking_status_tmp = 4 if cov_cat_smoking_status=="Missing"
lab def cov_cat_smoking_status_tmp 1 "Never smoker" 2 "Ever smoker" 3 "Current smoker" 4 "Missing"
lab val cov_cat_smoking_status_tmp cov_cat_smoking_status_tmp
drop cov_cat_smoking_status
rename cov_cat_smoking_status_tmp cov_cat_smoking_status 


*Summarise missingness

misstable summarize

end
