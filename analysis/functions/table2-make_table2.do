
cap prog drop make_table2
prog def make_table2

args outcome

	* Hospital admission: event flags and risktime  ----------------------------
	
	gen event_`outcome'_adm=0
	replace event_`outcome'_adm=1 if out_date_`outcome'_adm!=. & out_date_`outcome'_adm<=followupend_date_`outcome'_adm

	gen risktime_`outcome'_adm=followupend_date_`outcome'_adm - study_start_date


	* Re-admission: event flags and risktime -----------------------------------
	
	gen event_`outcome'_readm=0 if event_`outcome'_adm==1
	replace event_`outcome'_readm=1 if out_date_`outcome'_readm!=. & event_`outcome'_adm==1 & out_date_`outcome'_readm<=followupend_date_`outcome'_readm

	gen risktime_`outcome'_readm=followupend_date_`outcome'_readm - tmp_out_date_`outcome'_dis if event_`outcome'_readm!=.
	
	
	* Death: event flags and risktime ------------------------------------------

	gen event_`outcome'_death=0
	replace event_`outcome'_death=1 if out_date_`outcome'_death!=. & out_date_`outcome'_death<=followupend_date_death

	gen risktime_`outcome'_death=followupend_date_death - study_start_date 
	
	* Generate summary statistics as a single row: non-rounded -----------------
	
	preserve
	
	collapse (sum) event_`outcome'_adm risktime_`outcome'_adm event_`outcome'_readm risktime_`outcome'_readm event_`outcome'_death risktime_`outcome'_death ///
			 (p50) p50_`outcome'_stay=out_num_`outcome'_stay (iqr) iqr_`outcome'_stay=out_num_`outcome'_stay
	
	replace risktime_`outcome'_adm=round(risktime_`outcome'_adm/365.25,1)
	replace risktime_`outcome'_readm=round(risktime_`outcome'_readm/365.25,1)
	replace risktime_`outcome'_death=round(risktime_`outcome'_death/365.25,1)
	
	gen infection="`outcome'"
	egen eventcount_risktime_adm=concat(event_`outcome'_adm risktime_`outcome'_adm), punct("/")
	gen incidence_adm=100000*event_`outcome'_adm/risktime_`outcome'_adm
	gen median_stay=p50_`outcome'_stay
	gen iqr_stay=iqr_`outcome'_stay
	egen eventcount_risktime_readm=concat(event_`outcome'_readm risktime_`outcome'_readm), punct("/")
	gen incidence_readm=100000*event_`outcome'_readm/risktime_`outcome'_readm
	egen eventcount_risktime_death=concat(event_`outcome'_death risktime_`outcome'_death), punct("/")
	gen incidence_death=100000*event_`outcome'_death/risktime_`outcome'_death
	
	* Generate summary statistics as a single row: rounded ---------------------
	
	gen risktime_`outcome'_adm_r=risktime_`outcome'_adm
	roundmid_any "risktime_`outcome'_adm_r" 6
	gen risktime_`outcome'_readm_r=risktime_`outcome'_readm
	roundmid_any "risktime_`outcome'_readm_r" 6
	gen risktime_`outcome'_death_r=risktime_`outcome'_death
	roundmid_any "risktime_`outcome'_death_r" 6
	
	egen eventcount_risktime_adm_r=concat(event_`outcome'_adm_r risktime_`outcome'_adm_r), punct("/")
	gen incidence_adm_r=100000*event_`outcome'_adm_r/risktime_`outcome'_adm_r
	gen median_stay_r=p50_`outcome'_stay
	gen iqr_stay_r=iqr_`outcome'_stay
	egen eventcount_risktime_readm_r=concat(event_`outcome'_readm_r risktime_`outcome'_readm_r), punct("/")
	gen incidence_readm_r=100000*event_`outcome'_readm_r/risktime_`outcome'_readm_r
	egen eventcount_risktime_death_r=concat(event_`outcome'_death_r risktime_`outcome'_death_r), punct("/")
	gen incidence_death_r=100000*event_`outcome'_death_r/risktime_`outcome'_death_r
	
	drop event_`outcome'* risktime_`outcome'* p50_`outcome'_stay iqr_`outcome'_stay
	
	* save as single row dta dataset
	
	save output/table2_`outcome'.dta, replace
	*save "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/table2_flu.dta", replace

	restore
	
	drop event_`outcome'* risktime_`outcome'*
	
end