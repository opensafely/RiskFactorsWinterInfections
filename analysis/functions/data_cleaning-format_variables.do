* Program to format variables -------------------------------------------------

cap prog drop format_variables
prog def format_variables


* Replace NA with missing value that Stata recognises --------------------------

ds , has(type string)
foreach var of varlist `r(varlist)' {
	replace `var' = "" if `var' == "NA"
}


* Format _date_ variables as dates ---------------------------------------------

foreach var of varlist out_date* tmp_out_date* death_date tmp_out_num_max_hba1c_date tmp_exp_date* {
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

gen cov_bin_male_tmp=0
replace cov_bin_male_tmp=1 if cov_bin_male=="Yes"
label define YesNo 0 "No" 1 "Yes"
drop cov_bin_male
rename cov_bin_male_tmp cov_bin_male
label values cov_bin_male YesNo


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

gen cov_cat_smoking_tmp = .
replace cov_cat_smoking_tmp = 1 if cov_cat_smoking=="N"
replace cov_cat_smoking_tmp = 2 if cov_cat_smoking=="E"
replace cov_cat_smoking_tmp = 3 if cov_cat_smoking=="S"
replace cov_cat_smoking_tmp = 4 if cov_cat_smoking=="M"|cov_cat_smoking==""
lab def cov_cat_smoking_tmp 1 "Never smoker" 2 "Ever smoker" 3 "Current smoker" 4 "Missing"
lab val cov_cat_smoking_tmp cov_cat_smoking_tmp
drop cov_cat_smoking
rename cov_cat_smoking_tmp cov_cat_smoking 


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


* recode obesity

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


* Reduced kidney function categories

  * Set implausible creatinine values to missing (Note: zero changed to missing)
replace baseline_creatinine = . if !inrange(baseline_creatinine, 20, 3000) 
	
  * Divide by 88.4 (to convert umol/l to mg/dl)
gen SCr_adj = baseline_creatinine/88.4

gen min=.
replace min = SCr_adj/0.7 if cov_bin_male==0
replace min = SCr_adj/0.9 if cov_bin_male==1
replace min = min^-0.329  if cov_bin_male==0
replace min = min^-0.411  if cov_bin_male==1
replace min = 1 if min<1

gen max=.
replace max=SCr_adj/0.7 if cov_bin_male==0
replace max=SCr_adj/0.9 if cov_bin_male==1
replace max=max^-1.209
replace max=1 if max>1

gen egfr=min*max*141
replace egfr=egfr*(0.993^cov_num_age)
replace egfr=egfr*1.018 if cov_bin_male==0
label var egfr "egfr calculated using CKD-EPI formula with no eth"

  * Categorise into ckd stages
egen egfr_cat = cut(egfr), at(0, 15, 30, 45, 60, 5000)
recode egfr_cat 0=5 15=4 30=3 45=2 60=0, generate(ckd)
* 0 = "No CKD" 	2 "stage 3a" 3 "stage 3b" 4 "stage 4" 5 "stage 5"
label define ckd 0 "No CKD" 1 "CKD"
label values ckd ckd
label var ckd "CKD stage calc without eth"

  * Convert into CKD group
*recode ckd 2/5=1, gen(chronic_kidney_disease)
*replace chronic_kidney_disease = 0 if creatinine==. 
	
recode ckd 0=1 2/3=2 4/5=3, gen(exp_cat_kidneyfunc)
replace exp_cat_kidneyfunc = 1 if baseline_creatinine==. 
label define reduced_kidney_function_catlab ///
	1 "None" 2 "Stage 3a/3b egfr 30-60	" 3 "Stage 4/5 egfr<30"
label values exp_cat_kidneyfunc reduced_kidney_function_catlab 
 

* Diabetes 
 
gen exp_cat_diabetes=0
replace exp_cat_diabetes=1 if tmp_exp_bin_diabetes==1&tmp_out_num_max_hba1c_mmol_mol<58&tmp_out_num_max_hba1c_mmol_mol!=.
replace exp_cat_diabetes=2 if tmp_exp_bin_diabetes==1&(tmp_out_num_max_hba1c_mmol_mol>=58&tmp_out_num_max_hba1c_mmol_mol!=.)
replace exp_cat_diabetes=3 if tmp_exp_bin_diabetes==1&tmp_out_num_max_hba1c_mmol_mol==.
label define diabetes_categories ///
		0 "No diabetes" 1 "Controlled diabetes" 2 "Uncontrolled diabetes" 3 "Unknown diabetes" 
label values exp_cat_diabetes diabetes_categories
 

* Non-haem cancer

gen study_start_minus_1yr=study_start_date-365
gen study_start_minus_5yrs=study_start_date-1825
gen exp_cat_cancer_exhaem=0
replace exp_cat_cancer_exhaem=1 if tmp_exp_date_cancer_exhaem>study_start_minus_1yr & tmp_exp_date_cancer_exhaem<study_start_date
replace exp_cat_cancer_exhaem=2 if tmp_exp_date_cancer_exhaem<=study_start_minus_1yr & tmp_exp_date_cancer_exhaem>study_start_minus_5yrs
replace exp_cat_cancer_exhaem=3 if tmp_exp_date_cancer_exhaem<=study_start_minus_5yrs
label define cancer_categories ///
		0 "Never diagnosed" 1 "Diagnosed <1 yr ago" 2 "Diagnosed 1-5 yrs ago" 3 "Diagnosed 5+ yrs ago" 
label values exp_cat_cancer_exhaem cancer_categories


* Haem cancer

gen exp_cat_cancer_haem=0
replace exp_cat_cancer_haem=1 if tmp_exp_date_cancer_haem>study_start_minus_1yr & tmp_exp_date_cancer_haem<study_start_date
replace exp_cat_cancer_haem=2 if tmp_exp_date_cancer_haem<=study_start_minus_1yr & tmp_exp_date_cancer_haem>study_start_minus_5yrs
replace exp_cat_cancer_haem=3 if tmp_exp_date_cancer_haem<=study_start_minus_5yrs
label define cancer_categories ///
		0 "Never diagnosed" 1 "Diagnosed <1 yr ago" 2 "Diagnosed 1-5 yrs ago" 3 "Diagnosed 5+ yrs ago" 
label values exp_cat_cancer_haem cancer_categories


* Asthma 
  * needs most recent date of corticosteroid use

gen exp_cat_asthma=0


* Age subcategories

gen sub_cat_age_tmp=0 /* this becomes the 18-39 category */
replace sub_cat_age_tmp=1 if sub_cat_age=="40-59"
replace sub_cat_age_tmp=2 if sub_cat_age=="60-79"
replace sub_cat_age_tmp=3 if sub_cat_age=="80-110"
replace sub_cat_age_tmp=4 if sub_cat_age==""
label define age_subcats ///
	  0 "18-39" 1 "40-59" 2 "60-79" 3 "80-110" 4 "Missing"
drop sub_cat_age
rename sub_cat_age_tmp sub_cat_age
label values sub_cat_age age_subcats
	  
	  
* Carehome status

gen sub_bin_carehome_tmp=0
replace sub_bin_carehome_tmp=1 if sub_bin_carehome=="Yes"
drop sub_bin_carehome
rename sub_bin_carehome_tmp sub_bin_carehome
label values sub_bin_carehome YesNo


* rename

rename exp_bin_other_immunosuppression=exp_bin_otherimm


*Summarise missingness

misstable summarize

end
