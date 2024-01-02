*! version 1.3.0  25jun2020
*! Create data dictionary from metadata	
program cordd
    version 15
    syntax anything [using/]  /// variables from data in memory or on disk
        [if] [in]             /// subset
        ,                     ///
        SAVing(string asis)   /// name of workbook
        [                     ///
        SHeet(passthru)       ///  name of worksheet
        SHEETMODify           ///  modify sheet
        SHEETREPlace          ///   replace sheet
        SAVEDTA               ///  save copy of data dictionary dataset
	    SAVEDta(string)       /// DTAsaving(<filename> , [replace|append])
        ] 

    local user "`c(username)'"

    // data in memory or on disk? 
    if "`using'"=="" {
        unab varlist : `anything'
        confirm variable `varlist'
        tempfile currdata
        qui save `"`currdata'"'
        local using `"`currdata'"'
    }
    else {
        local using: subinstr local using ".dta" ""
        local using `using'.dta
        capture confirm file "`using'"
        if _rc {
            di as err `"file `using' not found"'
            exit 601
        }
        capture describe `anything' using "`using'"
        if _rc {
            noisily describe `anything' using "`using'"
        }
    }
    preserve

    check_saving `saving'
    local saving "`r(saving)'"
    local replace `r(replace)'

    opts_exclusive "`replace' `sheetmodify' `sheetreplace'" "" 184

    check_savedta `savedta'
    local dsaving "`r(saving)'"
    local dreplace `r(replace)'
    local dappend `r(append)'

    // v.1.1: added code to make sure end user has descsave installed & updated
    // v2.0.0: removed update/install of -descsave- from SSC
    // Corrona version of the command comes packaged with an older
    // version of Roger Newson's -descsave-. The modern one does not run
    // the same way that is required here. 


    // Get mapping of value labels
    use `"`using'"', clear
    if "`anything'"!="" {
        unab varlist: `anything'
    }
    else {
        unab varlist: *
    }
    mata: cordd_check()
    // marksample touse, novarlist
    qui keep if `touse' 
    keep `varlist'
    uselabel, clear var 

    qui gen temp = strofreal(value)+`"=""'+label+`"""'
    keep lname temp

        // put all value labels in same "cell"
    qui {
        bys lname: gen n = _n
        reshape wide temp, i(lname) j(n)
        egen test = concat(temp*), punct(";")
            // cleans up concatentation w/ null values
        split test, gen(x) parse(;;)	
    }

    keep lname x1

    rename (lname x1) (vallab values)

    sort vallab

    tempfile tmp
    qui save `"`tmp'"'

    // Get other dataset properties
    qui use `"`using'"', clear
    mata: cordd_check() 
    // marksample touse, novarlist
    qui keep if `touse'
    keep `varlist'

    qui gen todrop = .
    forval i=1/10 {
        note todrop : ""
        local ++i
    }

    descsave, norestore charlist(FormType /// char1 "Form Type"
        note1 /// char2 "Question" 
        Range ///  char 3 "Range"
        note2 /// char 4 "Important Notes"
        note3 /// char 5 "Important Notes"
        note4 /// char 6 "Important Notes"
        note5 /// char 7 "Important Notes"
        note6 /// char 8 "Important Notes"
        note7 /// char 9 "Important Notes"
        note8 /// char 10 "Important Notes"
        note9 /// char 11 "Important Notes"
        note10 /// char 12 "Important Notes"
        ) 

    qui drop if name=="todrop"
     
    label var char1 "Current CRF Form" // updated order2
    label var char2 "Question Text" // updated order3
    label var char3 "Analytic Range (Expected)"  //updated order6
    label var char4 "Important Notes"

    sort vallab
    qui merge m:1 vallab using `"`tmp'"', nogenerate

    sort order
    drop order

    label var values "Analytic Variable code/values"  // order 5
	label var varlab "Analytic Variable label"  //order 4
	label var name "Analytic File Variable name"  // updated order1
	label var format "Analytic Format" // updated order7
	
	// new variables
	gen unit="" 
	label var unit "Analytic Measurement Unit" // order8
	
	gen validation=""
	label var validation "Analytic validation (Biostat QC)"  //order9
	
	

    qui {
        // replace semicolon delimiters with in-cell linebreak 
        replace values = subinstr(values,";","`=char(13)+char(10)'",.) 
         
        order name char1 char2 varlab values char3 format unit validation char4

	
        *replace format = "" if missing(char6) & char5!="date"
        replace format = "string" if strpos(format,"s") & strpos(format,"%")
        replace format = "numeric" if strpos(format,"g") & strpos(format,"%")

*v1.3.0: removed line causing notes to be added to revision date (rraciborski)
        *replace char10 = char10+", "+char12 if !missing(char10) & char8!="1"

        *replace char8 = "V"+char8
        *replace char9 = "V"+char9 if !missing(char9)

		
        forval i=5/12 {
            count if !missing(char`i')
            if `r(N)'==0 drop char`i'
            else {
                replace char4=char4+";"+char`i'
                drop char`i'
				
            }
        }

        replace char4 = subinstr(char4,";","`=char(13)+char(10)'",.) 
    }
    *drop char11 type

    if "`savedta'"!="" {
        qui {
            drop if name==""
            keep name-char4
            gen dta="`c(filename)'"
            replace dta=`"`using'"' if dta==""
            gen dtadate = .
            format dtadate %tc 
            if "`c(filedate)'"=="" {
                replace dtadate = .x 
            }
            else {
                replace dtadate = tc("`c(filedate)'")
            }
        }
        if "`dappend'"!="append" {
            save `"`dsaving'"', `dreplace' emptyok
        }
        else {
            append using `"`dsaving'"'
            save `"`dsaving'"', replace 
        }
    }

    export excel name-char4 using `"`saving'"' if name!="", `sheet' ///
        `replace' `sheetreplace' `sheetmodify' firstrow(varlabels)

end

program check_saving, rclass
    syntax [anything] [, replace]
    // where to save?
    if `"`anything'"'=="" {
        di as err "You must specify the name of the data dictionary"
        exit 198
    }

    parse `anything', parse(".")

*v1.3.0: made xlsx default format (rraciborski)
    if "`2'"=="" {
        local saving `anything'
        return local saving "`saving'.xlsx"
    }
    else { 
        return local saving `anything'
    }

    if "`replace'"!="" {
        return local replace `replace'
    }
end

program check_savedta, rclass
    syntax [anything] [, replace append]
    // where to save?

    opts_exclusive "`replace' `append'" "savedta" 184

    return local saving `anything'

    if "`replace'"!="" {
        return local replace `replace'
    }
    else if "`append'"!="" {
        return local append `append'
    }
end

