program define cortable_counts, rclass
version 15.1

syntax ///
	[,  ///
	/// NEW STUFF
	put(string) /// putpdf | putdocx
	rowvarlist(varlist) /// rowvariable list
	currow(integer 0) ///
	touse(varname) /// holds the touse variable
	post(integer 0) /// will be 0 or 1
	handle(string) /// name of handle file for postfile
	///
	na(string) /// what to display when suppressed
	tname(string) /// name(<handle>, replace append) name of table, used when you're not saving
	///
	/// options for what goes in the table
	COLvars(varlist numeric fv) /// list of variables or factor variables for columns
	SUPpress(integer -1) /// when to supress cells for small size - may leave undocumented
	TABNumber(string) /// table number, used to identify rows in data
	]


************ start actual statistics here*********************

foreach var of varlist `rowvarlist' {
	`put' table `tname'(`currow',.), addrows(1,after)
	local currow = `currow' + 1
	`put' table `tname'(`currow',1) = (`"`: var label `var''"')
	
	// calculate N & percent for binary variable		
	local col = 2
	* loop through column vars
	foreach cvar of local colvars {
		* add the total non-missing N, for non-grouped and first of group
		quietly count if !missing(`var')&`touse'&`cvar'==1
		if r(N)<=`suppress'&`col'>2 { 
			`put' table `tname'(`currow',`col') = ("`na'"), halign(center)
		}
		else {
			local n : display %9.0fc r(N)
			local n = trim("`n'")
			`put' table `tname'(`currow',`col') = ("`n'"), halign(center)
		}
		if `post' {
				post `handle' ("`var'") (1) ("`cvar'") ("n") (r(N))  ("`tabnumber'")
		}
		local col = `col' + 1
	}  
}

return scalar currow = `currow'

end



