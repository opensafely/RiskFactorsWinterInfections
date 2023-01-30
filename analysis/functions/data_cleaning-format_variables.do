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

foreach var of varlist out_date* {
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

*foreach var of varlist exp_bin* cov_bin* sub_bin* qa_bin* inex_bin_registered {
*	encode `var', gen(`var'_tmp)
*	drop `var'
*	rename `var'_tmp `var'
*}

* Format _num_ variables as numeric --------------------------------------------

// TBC

* Format _cat_ variables as categoricals ---------------------------------------

// TBC, please include a missing category when needed and set reference categories

* Ethnicity (5 category)
replace cov_cat_ethnicity = 6 if cov_cat_ethnicity==.
label define ethnicity_lab 	0 "Missing"						///
							1 "White"  						///
							2 "Mixed" 						///
							3 "Asian or Asian British"		///
							4 "Black"  						///
							5 "Other"
label values cov_cat_ethnicity ethnicity_lab


* Label deprivation

label def deprivation_decile 1 "1 Most deprived" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10 Least deprived"
lab values cov_cat_deprivation deprivation_decile

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


* Recode region

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


*Summarise missingness

misstable summarize

end
