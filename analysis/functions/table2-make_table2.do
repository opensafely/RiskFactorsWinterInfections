
cap prog drop make_table2
prog def make_table2

args cohort outcome

	* Hospital admission: event flags and risktime  ----------------------------
	
	gen event_flu_adm=0
	replace event_flu_adm=1 if out_date_flu_adm!=. & out_date_flu_adm<=followup_end_date_flu_adm

	gen risktime_flu_adm=followup_end_date_flu_adm - study_start_date


	* Re-admission: event flags and risktime -----------------------------------
	
	gen event_flu_readm=0 if event_flu_adm==1
	replace event_flu_readm=1 if out_date_flu_readm!=. & out_date_flu_readm<=followup_end_date_flu_readm

	gen risktime_flu_readm=followup_end_date_flu_readm - tmp_out_date_flu_dis if event_flu_readm!=.
	
	
	* Death: event flags and risktime ------------------------------------------

	gen event_flu_death=0
	replace event_flu_death=1 if out_date_flu_death!=. & out_date_flu_death<=study_end_date

	gen risktime_flu_death=followup_end_date_death - study_start_date 
	
	* Generate summary statistics ----------------------------------------------
	
	preserve
	
	collapse (sum) event_flu_adm risktime_flu_adm event_flu_readm risktime_flu_readm event_flu_death risktime_flu_death ///
			 (p50) p50_flu_stay=out_num_flu_stay (iqr) iqr_flu_stay=out_num_flu_stay
	
	replace risktime_flu_adm=round(risktime_flu_adm/365.25,1)
	gen infection="flu"
	egen eventcount_risktime_adm=concat(event_flu_adm risktime_flu_adm), punct("/")
	gen incidence_adm=event_flu_adm/risktime_flu_adm
	
	
	*save output/table2_flu.dta, replace
	save "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/table2_flu.dta", replace

	restore
	
	drop event_flu* risktime_flu*
	