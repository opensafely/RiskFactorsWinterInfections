* Program to define variables not in study definition --------------------------

cap prog drop variable_definitions
prog def variable_definitions

	* Define exp_cat_diabetes --------------------------------------------------

	gen exp_cat_diabetes=.
	
	* Set implausible HbA1c values to missing
	replace tmp_exp_cat_diabetes_hba1c = . if !inrange(tmp_exp_cat_diabetes_hba1c, 15.0001, 514.999) 

	replace exp_cat_diabetes=0 if tmp_exp_cat_diabetes_code==0
	replace exp_cat_diabetes=1 if tmp_exp_cat_diabetes_code==1 & tmp_exp_cat_diabetes_hba1c<58 & tmp_exp_cat_diabetes_hba1c!=.
	replace exp_cat_diabetes=2 if tmp_exp_cat_diabetes_code==1 & (tmp_exp_cat_diabetes_hba1c>=58 & tmp_exp_cat_diabetes_hba1c!=.)
	replace exp_cat_diabetes=3 if tmp_exp_cat_diabetes_code==1 & tmp_exp_cat_diabetes_hba1c==.
	
	label define diabetes_categories 0 "No diabetes" 1 "Controlled diabetes" 2 "Uncontrolled diabetes" 3 "Unknown diabetes" 
	label values exp_cat_diabetes diabetes_categories

	* Define exp_cat_kidneyfunc ------------------------------------------------

	* Set implausible creatinine values to missing
	replace tmp_exp_cat_kidneyfunc_creatinin = . if !inrange(tmp_exp_cat_kidneyfunc_creatinin, 20, 3000) 

	* Divide by 88.4 (to convert umol/l to mg/dl)
	gen SCr_adj = tmp_exp_cat_kidneyfunc_creatinin/88.4

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
	label var egfr "eGFR calculated using CKD-EPI formula with no eth"

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
	replace exp_cat_kidneyfunc = 1 if tmp_exp_cat_kidneyfunc_creatinin==. 
	label define reduced_kidney_function_catlab 1 "None" 2 "Stage 3a/3b egfr 30-60	" 3 "Stage 4/5 egfr<30"
	label values exp_cat_kidneyfunc reduced_kidney_function_catlab 

	drop SCr_adj min max egf* ckd

	* Define exp_cat_cancer_exhaem ---------------------------------------------

	gen tmp_study_start_minus_1yr=study_start_date-365
	gen tmp_study_start_minus_5yrs=study_start_date-1825
	gen exp_cat_cancer_exhaem=0
	replace exp_cat_cancer_exhaem=1 if tmp_exp_date_cancer_exhaem>tmp_study_start_minus_1yr & tmp_exp_date_cancer_exhaem<study_start_date
	replace exp_cat_cancer_exhaem=2 if tmp_exp_date_cancer_exhaem<=tmp_study_start_minus_1yr & tmp_exp_date_cancer_exhaem>tmp_study_start_minus_5yrs
	replace exp_cat_cancer_exhaem=3 if tmp_exp_date_cancer_exhaem<=tmp_study_start_minus_5yrs
	label define cancer_categories 0 "Never diagnosed" 1 "Diagnosed <1 yr ago" 2 "Diagnosed 1-5 yrs ago" 3 "Diagnosed 5+ yrs ago" 
	label values exp_cat_cancer_exhaem cancer_categories

	* Define exp_cat_cancer_haem -----------------------------------------------

	gen exp_cat_cancer_haem=0
	replace exp_cat_cancer_haem=1 if tmp_exp_date_cancer_haem>tmp_study_start_minus_1yr & tmp_exp_date_cancer_haem<study_start_date
	replace exp_cat_cancer_haem=2 if tmp_exp_date_cancer_haem<=tmp_study_start_minus_1yr & tmp_exp_date_cancer_haem>tmp_study_start_minus_5yrs
	replace exp_cat_cancer_haem=3 if tmp_exp_date_cancer_haem<=tmp_study_start_minus_5yrs
	label values exp_cat_cancer_haem cancer_categories

end
