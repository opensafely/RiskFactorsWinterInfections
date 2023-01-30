* Program to apply quality assurance measures ----------------------------------

cap prog drop quality_assurance
prog def quality_assurance
args // TBC

* Remove individuals whose year of birth is after their year of death ----------  

// TBC, please record number removed for CONSORT diagram

* Remove individuals whose year of birth is after date of data extract ---------

// TBC, please record number removed for CONSORT diagram

gen qa_birth_after_index=0
replace qa_birth_after_index=1 if qa_num_birth_year>`date'

drop if qa_birth_after_index=1

* Remove individuals whose date of death is after date of data extract ---------

// TBC, please record number removed for CONSORT diagram

* Remove men whose records contain pregnancy and/or birth codes ----------------

// TBC, please record number removed for CONSORT diagram
gen qa_preg_men=0
replace qa_preg_men=1 if qa_bin_pregnancy==1

* Remove men whose records contain HRT or COCP medication codes ----------------

// TBC, please record number removed for CONSORT diagram

* Remove women whose records contain prostate cancer codes ---------------------

// TBC, please record number removed for CONSORT diagram

end
