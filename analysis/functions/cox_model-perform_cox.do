* Program to perform Cox analyses ----------------------------------------------

cap prog drop perform_cox
prog def perform_cox

	* Define arguments ---------------------------------------------------------

	args exposure outcome cohort
	
	* Minimal adjustment model -------------------------------------------------

	stcox `exposure' cov_num_age cov_bin_male, strata(region) vce(r)
	local N_total = e(N_sub)
	local N_fail = e(N_fail)
	local risktime = e(risk)
	regsave using "output/cox_model-`outcome'-`cohort'.dta", pval ci addlabel(adjustment, "min", outcome, "`outcome'", model, "`exposure'",  modeltype "cox", cohort, `cohort', N_total, `N_total', N_fail, `N_fail', risktime, `risktime') append
			
	* Maximal adjustment model -------------------------------------------------

	stcox `exposure' cov_*, strata(region) vce(r)
	local N_total = e(N_sub)
	local N_fail = e(N_fail)
	local risktime = e(risk)
	regsave using "output/cox_model-`outcome'-`cohort'.dta", pval ci addlabel(adjustment, "max", outcome, "`outcome'", model, "`exposure'", modeltype "cox", cohort, `cohort', N_total, `N_total', N_fail, `N_fail', risktime, `risktime') append

end
