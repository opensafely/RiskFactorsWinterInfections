* Program to perform linear regression analyses --------------------------------

cap prog drop perform_linear
prog def perform_linear

	* Define arguments ---------------------------------------------------------

	args exposure outcome cohort subgrp
	
	* Handle categorical exposures ---------------------------------------------
	
	unab exposure_model: `exposure'
	local exposure_model: subinstr local exposure "exp_cat_" "i.exp_cat_", all

	* Minimal adjustment model -------------------------------------------------

	if strpos("`subgrp'","sex") {
		regress  out_num_`outcome' cov_num_age `exposure_model' 
	}
	
	if strpos("`subgrp'","all")|strpos("`subgrp'","care")|strpos("`subgrp'","eth")|strpos("`subgrp'","age") {
		regress  out_num_`outcome' cov_num_age cov_bin_male `exposure_model' 
	}
	
	local N_total = e(N)
	regsave using "output/linear_model-`outcome'-`subgrp'-`cohort'.dta", pval ci addlabel(adjustment, "min", outcome, "`outcome'", subgroup, "`subgrp'", model, "`exposure'", modeltype, "linear", cohort, `cohort', N_total, `N_total') append
			
	* Maximal adjustment model -------------------------------------------------

	if strpos("`subgrp'","all")|strpos("`subgrp'","care")|strpos("`subgrp'","age") {
		regress out_num_`outcome' i.cov_cat_* cov_bin_* cov_num_* `exposure_model' 
	}
	
	if strpos("`subgrp'","sex") {
		regress out_num_`outcome' i.cov_cat_* cov_num_* `exposure_model'
	}
	
	if strpos("`subgrp'","eth") {
		regress out_num_`outcome' i.cov_cat_deprivation i.cov_cat_smoking i.cov_cat_obese cov_bin_* cov_num_* `exposure_model'
	}
	
	local N_total = e(N)
	regsave using "output/linear_model-`outcome'-`subgrp'-`cohort'.dta", pval ci addlabel(adjustment, "max", outcome, "`outcome'", subgroup, "`subgrp'", model, "`exposure'", modeltype, "linear", cohort, `cohort', N_total, `N_total') append

end
