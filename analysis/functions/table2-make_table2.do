
cap prog drop make_table2
prog def make_table2

args cohort outcome



* 2. preserve then collapse, summing flag and risktime, and get median/IQR for LoS
* 3. calculate rates=flagsum/risktimesum
* 4. save single row dataset=base
* 5. restore
* 6. repeat steps 1-5 for each infection and append to base: use append command



	* Hospital admission: event flags and risktime  ----------------------------
	
	gen event_flu_adm=0
	replace event_flu_adm=1 if out_date_flu_adm!=. & (death_date>=out_date_flu_adm | death_date==.)

	* patients admitted with infection
	gen risktime_flu_adm=out_date_flu_adm - study_start_date if event_flu_adm==1 
	* patients who died before they could be admitted but within the study period
	replace risktime_flu_adm=death_date - study_start_date if death_date<out_date_flu_adm | (death_date!=. & out_date_flu_adm==. & death_date<=study_end_date) 
	* patients who were not admitted and stayed alive through the study period
	replace risktime_flu_adm=study_end_date - study_start_date if event_flu_adm==0 & (death_date==. | death_date>study_end_date)


	* Re-admission: event flags and risktime -----------------------------------
	
	gen event_flu_readm=0 if event_flu_adm==1
	replace event_flu_readm=1 if out_date_flu_readm!=. & event_flu_adm==1 & (death_date>=out_date_flu_readm | death_date==.)

	* patients admitted with same infection
	gen risktime_flu_readm=out_date_flu_readm - tmp_out_date_flu_dis if event_flu_readm==1
	* patients who died before they could be readmitted
	replace risktime_flu_readm=death_date - tmp_out_date_flu_dis ///
		if event_flu_adm==1 & ((death_date<out_date_flu_readm & event_flu_readm==0) | (death_date!=. & event_flu_readm==0 & death_date<=study_end_date))
	* patients who were not readmitted and stayed alive through the study period following first admission
	replace risktime_flu_readm=study_end_date - tmp_out_date_flu_dis if event_flu_readm==0 & (death_date==. | death_date>study_end_date)
	
	
	* Death: event flags and risktime ------------------------------------------

	gen event_flu_death=0
	replace event_flu_death=1 if out_date_flu_death!=. & out_date_flu_death<=study_end_date

	* patients who died from the infection
	gen risktime_flu_death=out_date_flu_death - study_start_date if event_flu_death==1 
	* patients who died from other causes in the study period
	replace risktime_flu_death=death_date - study_start_date if death_date!=. & death_date<=study_end_date & event_flu_death==0
	*patients alive throughout study period
	replace risktime_flu_death=study_end_date - study_start_date if death_date==. | death_date>study_end_date
	
	* Generate summary statistics ----------------------------------------------
	
	preserve
	
	collapse (sum) event_flu_adm risktime_flu_adm event_flu_readm risktime_flu_readm event_flu_death risktime_flu_death ///
			 (p50) p50_flu_stay=out_num_flu_stay (iqr) iqr_flu_stay=out_num_flu_stay
	
	replace risktime_flu_adm=risktime_flu_adm/365.25
	gen infection="Influenza"
	egen event_risktime_adm=concat(event_flu_adm risktime_flu_adm), punct("/")
	gen incidence_adm=event_flu_adm/risktime_flu_adm
	
	
	*save output/table2_flu.dta, replace
	save "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/table2_flu.dta", replace

	restore
	
	drop event_flu* risktime_flu*
	