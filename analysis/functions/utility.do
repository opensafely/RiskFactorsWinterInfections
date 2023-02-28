* Function for rounding centered on (integer) midpoint -------------------------

cap prog drop roundmid_any
prog def roundmid_any

	args x to
	
	gen `x'_rounded = ceil(`x'/`to')*`to' - (floor(`to'/2)*(`x'!=0)*(`x'!=.))
	
end
