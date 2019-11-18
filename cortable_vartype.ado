program define cortable_vartype, rclass
version 15.1
syntax varlist

// classify types and make sure all labels in place 
local J 0     // initialize error counter to 0
foreach var of local varlist {
	* user specified type using -corset-
	* if variable has type set in char [corsetVarType]
	if "`: char `var'[corsetVarType]'"!="" {
		if "`: char `var'[corsetVarType]'"=="continuous" {
			local convar "`convar' `var'"
		}
		else if "`: char `var'[corsetVarType]'"=="categorical" {
			local catvar "`catvar' `var'"
		}
		else if "`: char `var'[corsetVarType]'"=="binary" {
			local binvar "`binvar' `var'"
		}
	}
	* variable type based on chars generally set by registry manager
	else if inlist("`: char `var'[ResponseType]'", ///
	  "check box", "drop down list", "numeric") {
		* binary or categorical, not clear - radio button !!
		* binary - check box
		if "`: char `var'[ResponseType]'"=="check box" {
			local binvar "`binvar' `var'"
		}
		
		* categorical - drop down list, !! for now radio button is uninformative
		else if inlist("`: char `var'[ResponseType]'","drop down list") {
			local catvar "`catvar' `var'"
		}
			
		* continuous - numeric
		else if "`: char `var'[ResponseType]'"=="numeric" {
			local convar "`convar' `var'"
		}
	}
	 
		* if it has value label cmiss, treat as continuous
	* this is worth doing because it's going to be faster than -inspect-
	else if "`: value label `var''"=="cmiss" {
		local convar "`convar' `var'"
	}

	* variables without char set
	else  {		
		// common logic for binary & categorical variables
		else {
			local iscat = 0
			quietly inspect `var'
		
			if r(N_unique) > 10 {
				local convar "`convar' `var'"
			}
			if r(N_unique)==2 { 
				capture assert inlist(`var', 0 , 1)|missing(`var')
				if _rc {
					local iscat = 1
				}
				else {
					local binvar "`binvar' `var'"
				}
			}
			if inrange(r(N_unique),3,24)|`iscat' {
				local catvar "`catvar' `var'"
			}
		}
	}
}

return local binvar `"`= trim(itrim("`binvar'"))'"'
return local catvar `"`= trim(itrim("`catvar'"))'"'
return local convar `"`= trim(itrim("`convar'"))'"'
end
