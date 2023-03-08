
cap prog drop make_table2
prog def make_table2

	args outcome
	
	* Risk time for hospital admission -----------------------------------------

	gen risktime_`outcome'_adm = out_date_`outcome'_adm - pat_start_date 

	* Risk time for readmission ------------------------------------------------

	gen risktime_`outcome'_readm = out_date_`outcome'_readm - tmp_out_date_`outcome'_dis

	* Risk time for death ------------------------------------------------------

	gen risktime_`outcome'_death = out_date_`outcome'_death - pat_start_date

	* Generate summary statistics as a single row: non-rounded -----------------

	preserve
	
	collapse (sum) out_status_`outcome'_adm risktime_`outcome'_adm out_status_`outcome'_readm risktime_`outcome'_readm out_status_`outcome'_death risktime_`outcome'_death ///
		(p50) p50_`outcome'_stay=out_num_`outcome'_stay (p25) p25_`outcome'_stay=out_num_`outcome'_stay (p75) p75_`outcome'_stay=out_num_`outcome'_stay

	replace risktime_`outcome'_adm=round(risktime_`outcome'_adm/365.25,1)
	replace risktime_`outcome'_readm=round(risktime_`outcome'_readm/365.25,1)
	replace risktime_`outcome'_death=round(risktime_`outcome'_death/365.25,1)

	gen infection="`outcome'"
	egen eventcount_risktime_adm=concat(out_status_`outcome'_adm risktime_`outcome'_adm), punct("/")
	gen incidence_adm=100000*out_status_`outcome'_adm/risktime_`outcome'_adm
	gen median_stay=p50_`outcome'_stay
	egen iqr_stay=concat(p25_`outcome'_stay p75_`outcome'_stay), punct(",")
	egen eventcount_risktime_readm=concat(out_status_`outcome'_readm risktime_`outcome'_readm), punct("/")
	gen incidence_readm=100000*out_status_`outcome'_readm/risktime_`outcome'_readm
	egen eventcount_risktime_death=concat(out_status_`outcome'_death risktime_`outcome'_death), punct("/")
	gen incidence_death=100000*out_status_`outcome'_death/risktime_`outcome'_death

	* Generate summary statistics as a single row: rounded ---------------------

	gen evnt_`outcome'_adm=out_status_`outcome'_adm
	roundmid_any "evnt_`outcome'_adm" 6
	gen evnt_`outcome'_readm=out_status_`outcome'_readm
	roundmid_any "evnt_`outcome'_readm" 6
	gen evnt_`outcome'_death=out_status_`outcome'_death
	roundmid_any "evnt_`outcome'_death" 6

	gen rt_`outcome'_adm=risktime_`outcome'_adm
	roundmid_any "rt_`outcome'_adm" 6
	gen rt_`outcome'_readm=risktime_`outcome'_readm
	roundmid_any "rt_`outcome'_readm" 6
	gen rt_`outcome'_death=risktime_`outcome'_death
	roundmid_any "rt_`outcome'_death" 6

	egen eventcount_risktime_adm_r=concat(evnt_`outcome'_adm_rounded rt_`outcome'_adm_rounded), punct("/")
	gen incidence_adm_r=100000*evnt_`outcome'_adm_rounded/rt_`outcome'_adm_rounded
	gen median_stay_r=p50_`outcome'_stay
	gen iqr_stay_r=iqr_stay
	egen eventcount_risktime_readm_r=concat(evnt_`outcome'_readm_rounded rt_`outcome'_readm_rounded), punct("/")
	gen incidence_readm_r=100000*evnt_`outcome'_readm_rounded/rt_`outcome'_readm_rounded
	egen eventcount_risktime_death_r=concat(evnt_`outcome'_death_rounded rt_`outcome'_death_rounded), punct("/")
	gen incidence_death_r=100000*evnt_`outcome'_death_rounded/rt_`outcome'_death_rounded
	
	drop risktime_`outcome'* evnt_* rt_* *_`outcome'_stay

	* save as single row dta dataset

	save output/table2_`outcome'.dta, replace
	
	restore
	
	drop risktime_`outcome'*
	
end
