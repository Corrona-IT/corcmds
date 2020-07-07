*! v1.3  07jul2020  RRaciborski
program define cortable_split, rclass
version 15.1

syntax [if] ///
	[,  ///
	/// NEW STUFF
	put(string) /// putpdf | putdocx
	rowvarlist(varlist) /// rowvariable list
	binvar(string) /// variable types, string so if it's empty it doesn't complain
	catvar(string) /// 
	convar(string) /// 
	currow(integer 0) ///
	touse(varname) /// holds the touse variable
	post(integer 0) /// will be 0 or 1
	handle(string) /// name of handle file for postfile
	///
	na(string) /// what to display when suppressed
	tname(string) /// name(<handle>, replace append) name of table, used when you're not saving
	///
	/// options for what goes in the table
	COLvars(string) /// list of variables or factor variables for columns
	SUPpress(integer 5) /// when to supress cells for small size - may leave undocumented
	constat(string) /// stats can be anything produced by -summ , detail-
					/// OR msd (mean +- sd)		///
					/// mediqr (median [iqr])	medqt (median [p25, p75])  median (synonym p50)
	noHEader 		/// suppresses adding a first row
	ADDHeader /// forces the normal header below altheader
	TABNumber(string) /// table number, identifies data in file
	]

*v1.3: set suppress to suppress-1 so strictly less than specified (rar, 7/7/20)
local suppress = `suppress'-1

	
************ start actual statistics here*********************
tokenize `rowvarlist'
local vi = 1
while "``vi''"!="" {
	local var ``vi''
	
	local varlab
	local varlabprefix
	local tab
	local grcontinued = 0
	local parseonsemi = 0
	local bbrdr
	local xbrdr
	
	* check to see if variable has a group label set by corset or the registry
	if `"`: char `var'[corsetGroupLabel]'"'!=`""' | ///
	  `"`: char `var'[GroupLabel]'"'!=`""' | ///
	  ustrpos(`"`: var label `var''"',";")>0 {
		* Figure out which label to use - label set by corset overrides registry
		if `"`: char `var'[corsetGroupLabel]'"'!="" {
			local varlabprefix `"`: char `var'[corsetGroupLabel]'"'
		}
		else if `"`: char `var'[GroupLabel]'"'!="" {
			local varlabprefix `"`: char `var'[GroupLabel]'"'
		}
		else if ustrpos("`: var label `var''",";")>0 {
			psemi `var'
			local varlabprefix `"`r(prefix)'"'
			local parseonsemi = 1
		}
		
		* Now, figure out if we need to do anything
		if `vi'>1 { // make sure this isn't the first variable
			* If the previous variable had this same group label
			if `"`: char ``=`vi'-1''[corsetGroupLabel]'"'=="`varlabprefix'" | ///
			  `"`: char ``=`vi'-1''[GroupLabel]'"'=="`varlabprefix'" | ///
			  ustrpos("`: var label ``=`vi'-1'''","`varlabprefix';")>0 {
				
				* get the thing after the semicolon
				if `parseonsemi'==1 {
					psemi `var'
					local varlab = ustrtrim(`"`r(label)'"') 
				}
				else {
					* remove group label aka "prefix" from row label
					local varlab = ustrtrim(subinstr(`"`: var label `var''"', ///
					  `"`: char `var'[corsetGroupLabel]'"', /// thing to remove
					  "",1)) // replace it with nothing once
					  if "`varlab'"=="" {
						local varlab = " "
					  }
				}
				local grcontinued = 1
				local tab uchar(8195) + 
			}
		}
		*  next variable has the same group label
		* first check to make sure there is a next variable
		if "``=`vi'+1''"!="" {
			if `"`: char ``=`vi'+1''[corsetGroupLabel]'"'==`"`varlabprefix'"' | ///
			  `"`: char ``=`vi'+1''[GroupLabel]'"'==`"`varlabprefix'"' | ///
			  ustrpos(`"`: var label ``=`vi'+1'''"',`"`varlabprefix';"')>0 {
				
				// if it's not already continued
				if  (`grcontinued'==0) {
					if "`header'"!="noheader" {
						`put' table `tname'(`currow',.), addrows(1, after) 
						local currow = `currow' + 1
					}
					local header 
					`put' table `tname'(`currow',.), border(bottom, nil)
					`put' table `tname'(`currow',1) = ("`varlabprefix'")
				}
				
				
				* get the thing after the semicolon
				if `parseonsemi'==1 {
					psemi `var'
					local varlab = ustrtrim(`"`r(label)'"') 
				}
				else {
					* remove group label aka "prefix" from row label
					local varlab = ustrtrim(subinstr(`"`: var label `var''"', ///
					  `"`: char `var'[corsetGroupLabel]'"', /// thing to remove
					  "",1)) // replace it with nothing once
					if "`varlab'"=="" {
						local varlab = " "
					}
				}
				 
				local brdr border(bottom, nil)
				local tab uchar(8195) +
				local nforgroup
			}
		}
		* ELSE do nothing, you're not special
	}

	* if you didn't get a variable label in any of the above, set it now
* and remove the varlabprefix
	if "`varlab'"=="" {
		local varlab : variable label `var'
		local varlab = ustrtrim("`varlab'")
		local varlabprefix
	}
	
    local con : list var in convar
    if `con' { 

		// row heading for continuous variable: variable label 
		* if continued
		if `grcontinued' {	
			`put' table `tname'(`currow',.), addrows(2, after) 
			`put' table `tname'(`currow'/`=`currow'+2',.), border(bottom, nil) border(top, nil) 
			local currow = `currow' + 2
			`put' table `tname'(`currow',1) = (`tab' `"`varlab'"')
		}
		* if not continued
		if `grcontinued'==0 {
			if "`varlabprefix'"!="" {
				local xbrdr border(bottom, nil)
			}
			if "`header'"!="noheader" {
				`put' table `tname'(`currow',.), addrows(1, after) `xbrdr'
				local currow = `currow' + 1
			}
			`put' table `tname'(`currow',1) = (`tab' `"`varlab'"')
		}
		
		local i = 0
		foreach stat of local constat {	
			`put' table `tname'(`=`currow'+`i'',.), addrows(1, after) border(bottom, nil)
			local i = `i' + 1
			* msd = mean +-sd
			if "`stat'"=="msd" {
				// row subheadings for continuous variable are fixed w/ statistic names 
				`put' table `tname'(`=`currow'+`i'',1) = (`tab' uchar(8195) + "Mean (SD)") 
			}	
			
			* mediqr = Median [IQR]
			else if "`stat'"=="mediqr" {
				`put' table `tname'(`=`currow'+`i'',1) = (`tab' uchar(8195) + "Median [IQR]")
			}
			
			* medqt = Median [p25, p75]
			else if "`stat'"=="medqt" {
				`put' table `tname'(`=`currow'+`i'',1) = (`tab' uchar(8195) + "Median [p25, p75]")
			}
			
			* p50 -> Median
			else if "`stat'"=="p50" {
				local s = ustrupper("`stat'")
				`put' table `tname'(`=`currow'+`i'',1) = (`tab' uchar(8195) + "Median")
			}
			
			* sd -> SD, iqr -> IQR
			else if "`stat'"=="sd"|"`stat'"=="iqr" {
				local s = ustrupper("`stat'")
				`put' table `tname'(`=`currow'+`i'',1) = (`tab' uchar(8195) + "`s'")
			}
			else if "`stat'"!="n" {
				local s = strproper("`stat'")
				`put' table `tname'(`=`currow'+`i'',1) = (`tab' uchar(8195) + "`s'")
			}
		}

		
		* actual stats start here
			local c = 2
			* note column variables are all factor variables
			foreach cv of local colvars {
				* we need to add to these tables, based on what was done above
				local sup = 0			
				
				// calculate statistics for continuous variable
				quietly summarize `var' if `touse'==1 & `cv'==1, detail
				local n : display %9.0fc r(N)
				local n = trim("`n'")
				
				* list N if not part of a coninuting table
					if r(N)<=`suppress' {
						`put' table `tname'(`currow',`c') = ("N = `n'") ///
							, nformat(%9.0fc) halign(center)
							if `post' {
								post `handle' ("`var'") (-99) ("`cv'") ("n") (r(N))  ("`tabnumber'")
							}
						local sup = 1
					}
					else {
						`put' table `tname'(`currow',`c') = ("N = `n'") ///
							, nformat(%9.0fc) halign(center)
							if `post' {
								post `handle' ("`var'") (-99) ("`cv'") ("n") (r(N))  ("`tabnumber'")
							}
					}
					
				local i = 1 
				* now list all other stats
				foreach stat of local constat {

					if `sup' {
						`put' table `tname'(`=`currow'+`i'',`c') = ("`na'") ///
							, nformat(%9.0fc) halign(center)
					}
					else {						
						* mean, sd
						if "`stat'"=="msd" {
							local msd = strofreal(`r(mean)',"%9.1fc")+" (" + ///
								strofreal(`r(sd)',"%9.1fc") + ")"
							`put' table `tname'(`=`currow'+`i'',`c') = ("`msd'"), halign(center)
							if `post' {
								post `handle' ("`var'") (-99) ("`cv'") ("mean") (r(mean))  ("`tabnumber'")
								post `handle' ("`var'") (-99) ("`cv'") ("sd") (r(sd))  ("`tabnumber'")
							}
						}
						
						* median, IQR
						else if "`stat'"=="mediqr" {
							tempname iqr
							scalar `iqr' = `r(p75)'-`r(p25)'
							local miqr = strofreal(`r(p50)',"%9.2gc")+" ["+strofreal(`iqr',"%9.2gc")+"]"
							`put' table `tname'(`=`currow'+`i'',`c') = ("`miqr'"), halign(center)
							if `post' {
								post `handle' ("`var'") (-99) ("`cv'") ("median") (r(p50))  ("`tabnumber'")
								post `handle' ("`var'") (-99) ("`cv'") ("iqr") (scalar(`iqr'))  ("`tabnumber'")
							}
						}
						
						* median [p25 , p75]
						else if "`stat'"=="medqt" {
							local medqt = strofreal(`r(p50)',"%9.2gc")+ ///
								" ["+strofreal(`r(p25)',"%9.2gc")+", "+strofreal(`r(p75)',"%9.2gc")+"]"
							`put' table `tname'(`=`currow'+`i'',`c') = ("`medqt'"), halign(center)
							if `post' {
								post `handle' ("`var'") (-99) ("`cv'") ("median") (r(p50))  ("`tabnumber'")
								post `handle' ("`var'") (-99) ("`cv'") ("p25") (r(p25))  ("`tabnumber'")						
								post `handle' ("`var'") (-99) ("`cv'") ("p75") (r(p75))  ("`tabnumber'")								
							}
						}
						
						* IQR
						else if "`stat'"=="iqr" {
							tempname iqr
							scalar `iqr' = `r(p75)'-`r(p25)'
							local siqr = ustrtrim(strofreal(scalar(`iqr'),"%9.2gc"))
							`put' table `tname'(`=`currow'+`i'',`c') = ("`siqr'"), halign(center)
							if `post' {
								post `handle' ("`var'") (-99) ("`cv'") ("iqr") (scalar(`iqr'))  ("`tabnumber'")
							}

						}
						* anything -summ , detail- produces
						else {
							local s = ustrtrim(strofreal(scalar(r(`stat')),"%9.2gc"))
							`put' table `tname'(`=`currow'+`i'',`c') = ("`s'"), halign(center)
							if `post' {
								post `handle' ("`var'") (-99) ("`cv'") ("`stat'") (r(`stat'))  ("`tabnumber'")
							}
						}
					} // of it else for non-supressed
					local i = `i' + 1
				} // end loop for stats
				local c = `c' + 1
		} // end loop for column variables
		local currow = `currow' + `i' - 1
    } // end of if for continuous variables

	
**************************	not continuous 
    else {
      local cat : list var in catvar
      if `cat' {
            tempname freq levs p
			
			
			if `grcontinued' {	
				`put' table `tname'(`currow',.), addrows(1, after) 
				local currow = `currow' + 1
				`put' table `tname'(`currow',.), border(bottom, nil) border(top, nil) 
			}
		    
            // add "heading" row for variable label	to subtable
			if "`header'"!="noheader" {
				`put' table `tname'(`currow',.), addrows(1, after)
				local currow = `currow' + 1
			}
			`put' table `tname'(`currow',1) = (`tab' `"`varlab', n (%)"')

			if `grcontinued'|(`grcontinued'==0&`"`varlabprefix'"'!="") {	
				`put' table `tname'(`currow',.), border(top, nil) 
			}
 
 
			quietly levelsof `var'
			local nlevs = r(r)
			local levs = r(levels)
			// add row for each level forvalues i = 1/`nleves' {
			`put' table `tname'(`currow',.), addrows(`nlevs', after)
			`put' table `tname'(`=`currow'+1'/`=`currow'+`nlevs'',.), border(top, nil)
           
            local mylist
            local isunk 0
            // this loop pushes unknown to the end of the list
			local i = 1
			foreach l of local levs {
                // get the value of the level
                local vlab: label (`var') `l'
				* if label contains "Unk"
                if `= strpos(proper("`vlab'"),"Unk")' {
                    local isunk `l'
                }
                else {
                    local mylist `mylist' `l'
                }
            }
            if `isunk' {
                local mylist `mylist' `isunk'
            }
			local i = 1
			foreach l of local mylist {
				local vlab: label (`var') `l'
				local vlab = ustrtrim("`vlab'")
				`put' table `tname'(`=`currow'+`i'',1) = (`tab' uchar(8195) + "`vlab'")	
				local i = `i' + 1
			}
						

			local c = 2

			* loop through column vars
			* within each column, move down the rows
			foreach cvar of local colvars {
				local sup = 0
				local r = 1
				* total
				quietly count if !missing(`var')&`touse'&`cvar'==1
				local cn = r(N)
				if r(N)<=`suppress' {
					local sup = 1		
				}
				local n : display %9.0fc r(N)
				local n = trim("`n'")
				`put' table `tname'(`currow',`c') = ("N = `n'"), ///
					nformat(%9.0fc) halign(center)
	
				foreach i of local mylist {
					quietly count if `var'==`i'&`touse'&`cvar'==1
					if `sup' {
						`put' table `tname'(`=`currow'+`r'',`c') = ///
							("`na'"), halign(center)	
					}
					else {
						local pct = trim("`: display %5.2g 100*r(N)/`cn''") 
						local n = trim("`: display %10.2gc r(N)'")
						`put' table `tname'(`=`currow'+`r'',`c') = ///
							("`n' (`pct'%)"), halign(center)	
					}
					
					if `post' {
						post `handle' ("`var'") (`i') ("`cvar'") ("n") (r(N))  ("`tabnumber'")
						local ppct = 100*r(N)/`cn'
						post `handle' ("`var'") (`i') ("`cvar'") ("percent") (`ppct')  ("`tabnumber'")
					}
					local r = `r'+1
						
				} // end row levels loop
				local c = `c' + 1
			}  // end column vars loop
			local currow = `currow' + `r' - 1 
		}
*************** binary ******************
        else {
			local addtocols = 0
			* no prefix = no special treatment
			if "`header'"!="noheader" {
				`put' table `tname'(`currow',.), addrows(1,after)
				local currow = `currow' + 1
			}
			if "`varlabprefix'"=="" {
				// binary adds variable name and label of target category
				`put' table `tname'(`currow',1) = (`"`varlab', n (%)"')
				`put' table `tname'(`currow',.), addrows(1, after) border(bottom, nil)
				local currow = `currow' + 1

				`put' table `tname'(`currow',1) = (`tab' uchar(8195) + `"`=ustrtrim(`"`:label (`var') 1'"')'"')
			}
			else {
				* update the group label for these
				if `grcontinued'==0 {
					`put' table `tname'(`=`currow'-1',1) = (`"`varlabprefix', n (%)"')
				}
				`put' table `tname'(`currow',1) = (uchar(8195) + `"`varlab'"')
				`put' table `tname'(`currow',.), border(top, nil)
			}


		
		// calculate N & percent for binary variable		
			local col = 2
			* loop through column vars
			foreach cvar of local colvars {
				* add the total non-missing N, for non-grouped and first of group
				if `grcontinued'==0 {
					quietly count if !missing(`var')&`touse'&`cvar'==1
					if r(N)<=`suppress' {
						local sup = 1		
					}
					local n : display %9.0fc r(N)
					local n = trim("`n'")
					*local j `subt`col''
					`put' table `tname'(`=`currow'-1',`col') = ("N = `n'"), ///
						nformat(%9.0fc) halign(center)

					local nforgroup`col' = r(N)
				}
				* add to list if N varies
				if `grcontinued' {
					quietly count if !missing(`var')&`touse'&`cvar'==1
					if r(N)!=`nforgroup`col'' {
						local nvaries `nvaries' `var' (n=`=r(N)') ,
					}
				}
				
				
				quietly summarize `var' if `touse'&`cvar'==1, meanonly
				local postpct = r(mean)*100
				if r(N)<=`suppress' {
					`put' table `tname'(`currow',`col') = ("`na'"), halign(center)
				}
				else {
					local pct : display %5.2g  `=r(mean)*100' // was %3.1f
					local pct = trim("`pct'")
					quietly count if `touse'&`var'==1& `cvar'==1
					local n : display %9.0fc r(N)
					local n = trim("`n'")
					`put' table `tname'(`currow',`col') = ("`n' (`pct'%)"), halign(center)
				}
				local col = `col' + 1
				if `post' {
					post `handle' ("`var'") (1) ("`cvar'") ("n") (r(N))  ("`tabnumber'")
					post `handle' ("`var'") (1) ("`cvar'") ("percent") (`postpct')  ("`tabnumber'")
				}
			}  
						
			
        }
    } 
	local header
	local vi = `vi' + 1 // increment variable
}

return local nvaries "`nvaries'"
return scalar currow = `currow'

end

program define psemi, rclass
	args var
	parse `"`: var label `var''"', parse(";")
	return local prefix = `"`1'"'
	return local label = `"`3'"' 
end


