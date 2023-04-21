* Program to perform Cox analyses ----------------------------------------------

cap prog drop perform_cox
prog def perform_cox

	* Define arguments ---------------------------------------------------------

	args exposure outcome cohort subgrp
	
	* Handle categorical exposures ---------------------------------------------
	
	unab exposure_model: `exposure'
	local exposure_model: subinstr local exposure "exp_cat_" "i.exp_cat_", all
	
	* Minimal adjustment model -------------------------------------------------

	if strpos("`subgrp'","sex") {
		stcox `exposure_model' cov_num_age, strata(region) vce(r)
	}

	if strpos("`subgrp'","main")|strpos("`subgrp'","care")|strpos("`subgrp'","eth")|strpos("`subgrp'","age") {
		stcox `exposure_model' cov_num_age cov_bin_male, strata(region) vce(r)
	}
	
	local N_total = e(N_sub)
	local N_fail = e(N_fail)
	local risktime = e(risk)
	regsave using "output/cox_model-`outcome'-`subgrp'-`cohort'.dta", pval ci addlabel(adjustment, "min", outcome, "`outcome'", subgroup, "`subgrp'", model, "`exposure'",  modeltype, "cox", cohort, `cohort', N_total, `N_total', N_fail, `N_fail', risktime, `risktime') append
			
	* Maximal adjustment model -------------------------------------------------
	
	if strpos("`subgrp'","main")|strpos("`subgrp'","care")|strpos("`subgrp'","age") {
		stcox `exposure_model' ib3.cov_cat_deprivation i.cov_cat_smoking i.cov_cat_obese i.cov_cat_ethnicity cov_bin_* cov_num_*, strata(region) vce(r)
	}

	if strpos("`subgrp'","sex") {
		stcox `exposure_model' ib3.cov_cat_deprivation i.cov_cat_smoking i.cov_cat_obese i.cov_cat_ethnicity cov_num_*, strata(region) vce(r)
	}

	if strpos("`subgrp'","eth") {
		stcox `exposure_model' ib3.cov_cat_deprivation i.cov_cat_smoking i.cov_cat_obese cov_bin_* cov_num_*, strata(region) vce(r)
	}
	
	local N_total = e(N_sub)
	local N_fail = e(N_fail)
	local risktime = e(risk)
	regsave using "output/cox_model-`outcome'-`subgrp'-`cohort'.dta", pval ci addlabel(adjustment, "max", outcome, "`outcome'", subgroup, "`subgrp'", model, "`exposure'", modeltype, "cox", cohort, `cohort', N_total, `N_total', N_fail, `N_fail', risktime, `risktime') append

end
