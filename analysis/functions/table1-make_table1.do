
cap prog drop make_table1
prog def make_table1

args cohort outcome

	* Add labels to variables --------------------------------------------------

	run "analysis/functions/table1-label_variables.do"
	label_variables 

	* Create table of counts and percentages -----------------------------------

	table1_mc, vars(sub_cat_age cat \ ///
		cov_bin_male cat \ ///
		cov_cat_obese cat \ ///
		cov_cat_smoking cat \ ///
		cov_cat_ethnicity cat \ ///
		cov_cat_deprivation cat \ ///
		sub_bin_carehome bin \ ///
		exp_bin_hypertension bin \ ///
		exp_bin_chronicresp bin \ ///
		exp_cat_asthma cat \ ///
		exp_bin_chd bin \ ///
		exp_cat_diabetes cat \ ///
		exp_cat_cancer_exhaem cat \ ///
		exp_cat_cancer_haem cat \ ///
		exp_cat_kidneyfunc cat \ ///
		exp_bin_chronicliver bin \ ///
		exp_bin_stroke_dementia bin \ ///
		exp_bin_otherneuro bin \ ///
		exp_bin_transplant bin \ ///
		exp_bin_asplenia bin \ ///
		exp_bin_autoimm bin \ ///
		exp_bin_othimm bin) clear

	* Tidy table ---------------------------------------------------------------
	
	drop in 1

	rename _columna_1 count_`outcome'
	rename _columnb_1 percent_`outcome'
	
	replace percent_`outcome'=subinstr(percent_`outcome', "(", "", .)
	replace percent_`outcome'=subinstr(percent_`outcome', "%)", "", .)
	
	replace factor=factor[_n-1] if factor==""
	replace factor="N=" if _n==1

	* Add var for total number of observations ---------------------------------
	
	gen N=subinstr(N_1, ",", "", .) if _n==1
	destring N, replace
	replace N=N[_n-1] if N==.

	* Round total number of observations var -----------------------------------
	
	roundmid_any "N" 6

	* Convert counts and percentages to numeric --------------------------------
	
	gen count_`outcome'_tmp=subinstr(count_`outcome', ",", "", .)
	destring count_`outcome'_tmp, replace
	drop count_`outcome'
	rename count_`outcome'_tmp count_`outcome'

	gen percent_`outcome'_tmp=subinstr(percent_`outcome', ",", "", .)
	destring percent_`outcome'_tmp, replace
	drop percent_`outcome'
	rename percent_`outcome'_tmp percent_`outcome'

	* Create rounded version of counts -----------------------------------------
	
	roundmid_any "count_`outcome'" 6

	replace count_`outcome'=N if _n==1
	replace count_`outcome'_rounded=N_rounded if _n==1

	* Recalculate percentages based on rounded counts -------------------------- 
	
	gen percent_`outcome'_rounded=round(100*count_`outcome'_rounded/N_rounded, 0.1)

	gen sort_order=_n

	drop N_1 m_1 N N_rounded Total

	* Save output --------------------------------------------------------------

	save output/table1_`cohort'_`outcome'.dta, replace
	
end
