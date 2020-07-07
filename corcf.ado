*! version 2.0.0  15nov2019  RARaciborski
program define corcf, rclass sortpreserve
   version 14
   syntax varlist using/ [, ID(varlist) /// id variables to print in output
        Verbose /// print obs-level details on variables
        Verbose1(string) /// optional number of obs for printing
        All /// include note for variables w/o problems
		MASTERlist /// list observations appearing only in the master data
		USINGlist /// list observations appearing only in the using data
        CLEAN /// passthru to list
        NOObs /// passthru to list 
        NOLabel /// passthru to list
		SEParator(numlist max=1 integer) /// passthru to list 
		SEPBY(varlist) /// passthru to list
        RELDIF(numlist max=1)  /// allowed degree of difference
        NODECRease  /// difference must be positive
        /* need to add abbreviate(), string() */ ///
    ]

    local user "`c(username)'"

    // Error checking
	if "`separator'"!="" | "`sepby'" != "" {
		if "`separator'"!="" {
			capture assert "`sepby'"=="" 
			if _rc {
				di as error ///
                    "options separator() and sepby() may not be combined"
				exit 198
			}
			else local sep "separator(`separator')"
		}
		else local sep "sepby(`sepby')"
	}

    if "`verbose1'" != "" {
        capture confirm integer number `verbose1'
        if _rc {
            di as err "option verbose() requires an integer >0"
            exit 198
        }
        local max `verbose1'
        else if `max' < 1 {
            di as err "option verbose() invalid; # must be >0"
            exit 198
        }
        local verbose verbose
    }
    else local max 0

    if "`decrease'" == "nodecrease" {
        if "`reldif'"=="" {
            di as error ///
                "option nodecrease may only be specified with option reldif()"
            exit 198
        }
        else {
            local ndcr "& `var'>=_`var'"
        }
    }
 
    local varlist : list varlist - id
	
    quietly {
        describe, short
        local nmaxvar = r(k)*2
        local smaxvar = `c(maxvar)'
        
       local obs = _N
       local dif "0"
       describe using "`using'"
       // 1st check = same # of obs 
       if (r(N) != _N) { 
            noi di as text "note: master has " ///
                as result `obs' ///
                as text " observations; using has "  ///
                as result  r(N) as text " observations"
       }
   
       preserve
       keep `id' `varlist'
       tempfile tempcfm
       save `"`tempcfm'"', replace 
       
       use `"`using'"', clear       
 
       // 2nd check (not an error; just note): variables exist in using data
       // only do ONE confirm unless there is an error
       capture confirm variable `varlist'
       if _rc {
           foreach var of local varlist {
                capture confirm variable `var'
                 if _rc {
                    noisily di as input "`var': " ///
                        as text "does not exist in using"
                    local notexist `notexist' `var'
                }
            }
            // and now b/c we won't need to match these later...     
            local varlist : list varlist - notexist
            // make sure there is still something to compare
            local nvars : word count `varlist'
            capture assert `nvars'
            if _rc {
                di as err "No common variables"
                exit 102
            }
        }
        
        // prepare for later - rename all the using variables 
        rename (`varlist') _=
        tempfile tempcfu
        save `"`tempcfu'"'
    }
    // end of initial checks
    
    if "`id'"=="" {
        local mkey _n
		local comp "records"
    }
    else {
        local mkey `id'
		local comp "IDs"
    }

    // return results
    local type 0
    local values 0
    local nomatch 0    

    // define new "using" varlist   
    local uvarlist `varlist'
    foreach var of local varlist {
        local uvarlist : subinstr local uvarlist "`var'" "_`var'", word
    }

    // make sure there is space for 2x variables
    if `nmaxvar'>`smaxvar' {
        clear 
        set maxvar `nmaxvar'
    }

    // Check properties
    quietly {
		
        use `varlist' `id' using `"`tempcfm'"', clear
	    
        tempvar source 
        // Check datasets and flag observation source
        mata: corcf_source()
		
        tempvar cf
        gen byte `cf'=0
      
        // Display results 
        // v1.1.0: print IDs for obs distinct to each dataset if unequal obs 
        if "`id'"!="" {
            if "`masterlist'"!="" {
                count if `source'==1
                local Nmonly r(N)
                if `Nmonly' > 0 {
                    noi {
                        di "Master-only IDs"
                        list `id' if `source'==1
                    }
                }
                else noi display "No master-only IDs"
             }
             
             if "`usinglist'"!="" {
                count if `source'==2
                local Nmonly r(N)
                if `Nmonly' > 0 {
                    noi {
                        di "Using-only IDs"
                        list `id' if `source'==2
                    }
                }
                else noi display "No using-only IDs"
            }
        }
        drop if `source'!=3
    
        noi di "Comparison of common `comp' follows"
        
        // Check each variable in varlist for mismatches
        foreach var of local varlist {
           // Check storage type
           local tm : type `var'
           local tms = "`=substr("`tm'",1,3)'"=="str"
           local tu : type _`var'
           local tus = "`=substr("`tu'",1,3)'"=="str"
           capture assert `tms'==`tus' 
           if _rc {
                local ++nomatch 
                local ++type
                di as err ///
                    "variable `var' is `tm' in master but `tu' in using data"
                local ecode 106
            }
           // Check values
           else {
                local mismatches none

                // 2a. in all cases, report # of mismatches/tolerance exceeded
                // !! nonegative to be inserted here
                if "`reldif'"!="" & "`tms'"!="str" {
                    qui count if reldif(`var',_`var')>`reldif' `ndcr'
                    if `r(N)'>0 {
                        local mismatches found
                    }
                }
                else {
                    capture assert `var'==_`var'
                    if _rc {
                        local mismatches found
                    }
                }
                if "`mismatches'"=="found" { 
                    local ++nomatch 
                    local ++values
                    quietly {
                        if "`reldif'"=="" {
                            replace `cf'=(`var'!=_`var')
                        }
                        else {
                            replace `cf'=(reldif(`var',_`var')>`reldif' `ndcr')
                        }
                        count if `cf'==1
                        di as err "`var': " r(N) " mismatches"
                        if "`verbose'"!="" {
                            rename (`var' _`var') (master_data using_data)
                            if "`sepby'"!="" {
                                sort `sepby'
                            }
                            noi list `id' `sepby' master_data using_data ///
                                if `cf', ///
                                `clean' `noobs' `nolabel' `sep' ///
                                abbrev(15) string(30)
                            noi di _newline(2) 
                            rename (master_data using_data) (`var' _`var')
                        }
                    }
                    local ecode 9
                }
                else {
                    if "`all'"!="" {
                        di as text "`var': match"
                    }
                }
            }
        }
        // end check for mismatches

        // put maxvar back to original if needed
        if `nmaxvar'>`smaxvar' {
            clear 
            set maxvar `smaxvar'
        }
    }    
restore
exit `ecode'
end

