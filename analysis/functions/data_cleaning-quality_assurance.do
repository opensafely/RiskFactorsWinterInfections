* Program to apply quality assurance measures ----------------------------------

cap prog drop quality_assurance
prog def quality_assurance

* Remove individuals whose year of birth is after their year of death ----------  

gen death_year=year(death_date)

gen qa_birth_after_dth=0
replace qa_birth_after_dth=1 if qa_num_birth_year>death_year

quietly: table () (qa_birth_after_dth), statistic(frequency) name(consort) append

drop if qa_birth_after_dth=1


* Remove individuals whose year of birth is after date of data extract ---------

gen today= date("`c(current_date)'", "DMY")
gen year_extract=year(today)

gen qa_birth_after_today=0
replace qa_birth_after_today=1 if qa_num_birth_year > year_extract

quietly: table () (qa_birth_after_today), statistic(frequency) name(consort) append

drop if qa_birth_after_today=1


* Remove individuals whose date of death is after date of data extract ---------

gen qa_dth_after_today=0
replace qa_dth_after_today=1 if qa_num_dth_year > year_extract

quietly: table () (qa_dth_after_today), statistic(frequency) name(consort) append

drop if qa_dth_after_today=1

* Remove men whose records contain pregnancy and/or birth codes ----------------

gen qa_preg_men=0
replace qa_preg_men=1 if qa_bin_pregnancy==1&cov_bin_male==1

quietly: table () (qa_preg_men), statistic(frequency) name(consort) append

drop if qa_preg_men=1


* Remove men whose records contain HRT or COCP medication codes ----------------

gen qa_hrt_cocp_men=0
replace qa_hrt_cocp_men=1 if (cov_bin_combined_oral_contraceptive_pill==1|cov_bin_hormone_replacement_therapy===1) & cov_bin_male==1

quietly: table () (qa_hrt_cocp_men), statistic(frequency) name(consort) append

drop if qa_hrt_cocp_men=1


* Remove women whose records contain prostate cancer codes ---------------------

gen qa_prostate_women=0
replace qa_prostate_women=1 if qa_bin_prostate_cancer==1 & sex=="F" 

quietly: table () (qa_prostate_women), statistic(frequency) name(consort) append

drop if qa_prostate_women=1


* combine counts of excluded records and export

collect layout () (exclude qa_birth_after_dth qa_birth_after_today qa_dth_after_today qa_preg_men qa_hrt_cocp_men qa_prostate_women)

collect export "./output/consort.xlsx", xlsx


end
