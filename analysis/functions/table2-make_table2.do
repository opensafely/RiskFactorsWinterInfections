
cap prog drop make_table2
prog def make_table2

args cohort outcome



* 1. define flag and risktime for adm, readm & death
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
	* patients who died before the could be admitted
	replace risktime_flu_adm=death_date - study_start_date if death_date<out_date_flu_adm | (death_date!=. & out_date_flu_adm==.) 
	* patients who were not admitted and stayed alive through the study period
	replace risktime_flu_adm=study_end_date - study_start_date if event_flu_adm==0 & death_date==.


	* Re-admission: event flags and risktime -----------------------------------
	
	gen event_flu_readm=0 if event_flu_adm==1 /* pts without admission=missing */
	replace event_flu_readm=1 if out_date_flu_readm!=. & event_flu_adm==1 & (death_date>=out_date_flu_readm | death_date==.)

	* patients admitted with same infection
	gen risktime_flu_readm=out_date_flu_readm - tmp_out_date_flu_dis if event_flu_readm==1
	* patients who died before they could be readmitted
	replace risktime_flu_readm=death_date - tmp_out_date_flu_dis if death_date<out_date_flu_readm | (death_date!=. & out_date_flu_readm==.) 
	* patients who were not readmitted and stayed alive through the study period following first admission
	replace risktime_flu_readm=study_end_date - tmp_out_date_flu_dis if event_flu_readm==0 & death_date==.
	
	
	* Death: event flags and risktime ------------------------------------------

	gen event_flu_death=0
	replace event_flu_death=1 if out_date_flu_death!=.

	* patients who died from the infection
	gen risktime_flu_death=out_date_flu_death - study_start_date if out_date_flu_death!=.
	* patients who died from other causes
	replace risktime_flu_death=study_end_date - study_start_date if death_date!=. & death_date<out_date_flu_death
	*patients alive throughout study period
	replace risktime_flu_death=death_date - study_start_date if death_date==. 
	
	* Generate summary statistics ----------------------------------------------
	
	preserve
	
	collapse (sum) event_flu_adm risktime_flu_adm event_flu_readm risktime_flu_readm event_flu_death risktime_flu_death ///
			 (median) out_num_flu_stay (p25) out_num_flu_stay (p75) out_num_flu_stay
			 

	save output/table2_flu.dta, replace

	restore
	
	