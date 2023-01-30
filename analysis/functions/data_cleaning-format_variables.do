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

* binary indicator for males
gen cov_bin_male=0
replace cov_bin_male=1 if sex=="M"


* Format _num_ variables as numeric --------------------------------------------

// TBC

* Format _cat_ variables as categoricals ---------------------------------------

* Ethnicity (5 category)
replace cov_cat_ethnicity = 6 if cov_cat_ethnicity==.|cov_cat_ethnicity==0
label define ethnicity_lab 	1 "White"  						///
							2 "Mixed" 						///
							3 "Asian or Asian British"		///
							4 "Black"  						///
							5 "Other"						///
							6 "Missing"
label values cov_cat_ethnicity ethnicity_lab


* Label deprivation

replace cov_cat_deprivation=11 if cov_cat_deprivation==.
label def deprivation_decile 1 "1 Most deprived" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10 Least deprived" 11 "Missing"
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


* recode obesity binary indicator

gen obese_tmp=.
replace obese_tmp=0 if cov_num_bmi<30
replace obese_tmp=1 if cov_num_bmi>=30&cov_num_bmi<35
replace obese_tmp=2 if cov_num_bmi>=35&cov_num_bmi<40
replace obese_tmp=3 if cov_num_bmi>=40
replace obese_tmp=4 if cov_num_bmi<=0|cov_num_bmi=.
label define obese 0 "Not obese" 1 "Obese class I" 2 "Obese class II" 3 "Obese class III" 4 "Missing"
drop cov_cat_obese
rename obese_tmp cov_cat_obese

*Summarise missingness

misstable summarize

end
