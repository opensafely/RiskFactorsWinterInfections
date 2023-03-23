

*Get cleaned dummy data

*use "C:\Users\dy21108\GitHub\RiskFactorsWinterInfections\output/clean_winter2019.dta", clear
gzuse output/clean_`cohort'.dta.gz, clear

*Redo admission dates
gen rand_10pct=rbinomial(1,0.1)
gen rand_days=round(runiform(0.5,88.5),1)
gen date_adm=study_start_date + rand_days if rand_10pct==1
gen rand5cat=round(runiform(0.5,5.5),1)

replace out_date_flu_adm=.
replace out_date_flu_adm=date_adm if rand5cat==1
replace out_date_rsv_adm=.
replace out_date_rsv_adm=date_adm if rand5cat==2
replace out_date_pneustrep_adm=.
replace out_date_pneustrep_adm=date_adm if rand5cat==3
replace out_date_pneu_adm=.
replace out_date_pneu_adm=date_adm if rand5cat==4
replace out_date_covid_adm=.
replace out_date_covid_adm=date_adm if rand5cat==5

*Redo discharge dates
gen stay=round(rgamma(1.1,10),1)
replace tmp_out_date_flu_dis=.
replace tmp_out_date_flu_dis=out_date_flu_adm + stay if rand5cat==1
replace tmp_out_date_rsv_dis=.
replace tmp_out_date_rsv_dis=out_date_rsv_adm + stay if rand5cat==2
replace tmp_out_date_pneustrep_dis=.
replace tmp_out_date_pneustrep_dis=out_date_pneustrep_adm + stay if rand5cat==3
replace tmp_out_date_pneu_dis=.
replace tmp_out_date_pneu_dis=out_date_pneu_adm + stay if rand5cat==4
replace tmp_out_date_covid_dis=.
replace tmp_out_date_covid_dis=out_date_covid_adm + stay if rand5cat==5

*Readmission date for 25% of patients discharged
gen t2readm=round(runiform(0.5,30.5),1)
gen rand_25pct=rbinomial(1,0.25)

replace out_date_flu_readm=tmp_out_date_flu_dis + t2readm if tmp_out_date_flu_dis!=. & rand_25pct==1
replace out_date_rsv_readm=tmp_out_date_rsv_dis + t2readm if tmp_out_date_rsv_dis!=. & rand_25pct==1
replace out_date_pneustrep_readm=tmp_out_date_pneustrep_dis + t2readm if tmp_out_date_pneustrep_dis!=. & rand_25pct==1
replace out_date_pneu_readm=tmp_out_date_pneu_dis + t2readm if tmp_out_date_pneu_dis!=. & rand_25pct==1
replace out_date_covid_readm=tmp_out_date_covid_dis + t2readm if tmp_out_date_covid_dis!=. & rand_25pct==1

*Deregistration
gen dereg=rbinomial(1,0.02)
gen dereg_time=round(runiform(0.5,100.5),1)
replace deregistration_date=.
replace deregistration_date=study_start_date + dereg_time if dereg==1 

	*delete any dates occurring after deregistration date
foreach var in flu rsv pneustrep pneu covid {
	replace out_date_`var'_adm=. if deregistration_date<out_date_`var'_adm
	replace tmp_out_date_`var'_dis=. if deregistration_date<tmp_out_date_`var'_dis
	replace out_date_`var'_readm=. if deregistration_date<out_date_`var'_readm
}

*Death: all cause and infection-specific dates
gen died=rbinomial(1,0.02)
gen dth_time=round(runiform(0.5,100.5),1)
replace death_date=.
replace death_date=study_start_date + dth_time if died==1 

gen rand6cat=round(runiform(0.5,6.5),1) // rand6cat=6 -> causes of death other than outcome conditions
replace out_date_flu_death=death_date if death_date!=. & rand6cat==1
replace out_date_rsv_death=death_date if death_date!=. & rand6cat==2
replace out_date_pneustrep_death=death_date if death_date!=. & rand6cat==3
replace out_date_pneu_death=death_date if death_date!=. & rand6cat==4
replace out_date_covid_death=death_date if death_date!=. & rand6cat==5

	*delete and dates occurring after death date
foreach var in flu rsv pneustrep pneu covid {
	replace out_date_`var'_adm=. if death_date<out_date_`var'_adm
	replace tmp_out_date_`var'_dis=. if death_date<tmp_out_date_`var'_dis
	replace out_date_`var'_readm=. if death_date<out_date_`var'_readm
}

drop rand_10pct rand_days date_adm rand5cat rand6cat stay t2readm rand_25pct died dth_time dereg dereg_time

* Define patient start and end dates -------------------------------------------

drop pat_start_date pat_end_date
gen pat_start_date=study_start_date
egen pat_end_date=rowmin(death_date study_end_date deregistration_date)
format pat_start_date pat_end_date %td

* Define outcome variables -----------------------------------------------------

foreach outcome in flu rsv pneustrep pneu covid {
	
	* Remove outcomes outside of study period

	foreach event in adm readm death {
		replace out_date_`outcome'_`event' = . if out_date_`outcome'_`event' > pat_end_date | out_date_`outcome'_`event'<pat_start_date
	}
	
	* Remove readmission if before initial admission
	
	replace out_date_`outcome'_readm = . if out_date_`outcome'_readm < out_date_`outcome'_adm
	
	* Create length of hospital stay outcome

	replace out_num_`outcome'_stay = 0 // for those with no admission
	
	replace out_num_`outcome'_stay = tmp_out_date_`outcome'_dis - out_date_`outcome'_adm if tmp_out_date_`outcome'_dis!=. & out_date_`outcome'_adm!=.
	
	replace out_num_`outcome'_stay = . if tmp_out_date_`outcome'_dis==. & out_date_`outcome'_adm!=. // for those still awaiting discharge
	
	* Create indicator variables for date outcomes
	
	foreach event in adm readm death {
		replace out_status_`outcome'_`event' = 0
		replace out_status_`outcome'_`event' = 1 if out_date_`outcome'_`event'!=.
	}
}


*save "C:/Users/dy21108/GitHub/RiskFactorsWinterInfections/lib/clean_winter2019_simdates.dta", replace
gzsave "lib/clean_`cohort'.dta.gz", replace
save "lib/clean_`cohort'.dta", replace

