* Program to format variables -------------------------------------------------

cap prog drop format_variables
prog def format_variables
args // TBC, please include study start and end date

* Replace NA with missing value that Stata recognises --------------------------

ds , has(type string)
foreach var of varlist `r(varlist)' {
	replace `var' = "" if `var' == "NA"
}

* Format _date_ variables as dates ---------------------------------------------

// TBC

* Format _bin_ variables as logicals -------------------------------------------

// TBC

* Format _num_ variables as numeric --------------------------------------------

// TBC

* Format _cat_ variables as categoricals ---------------------------------------

// TBC, please include a missing category when needed and set reference categories

end
