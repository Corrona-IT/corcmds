*! version 1.1.1  17sep2019	
*! Create data dictionary from metadata	
program cordd
    version 15
    syntax anything [using/]   /// variables from data in memory or on disk
        [if] [in]             /// subset
        ,                     ///
        SAVing(string asis)   /// name of workbook
        [                     ///
        SHeet(passthru)       ///  name of worksheet
        SHEETMODify           ///  modify sheet
        SHEETREPlace          ///   replace sheet
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

    if "`sheetreplace'"=="" {
        check_saving `saving'
    }
    local saving "`r(saving)'"
    local replace `r(replace)'

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
        FormSection /// char2 "Enrollment/Follow-up Section"
        CDWvarname /// char3 "DW variable name"
        note1 /// char4 "Question" 
        ResponseType /// char5 "Response Type"
        MaxChars /// char6 "Digit/character" length
        Range ///  char 7 "Range"
        FirstVersion /// char8 "Earliest Version"
        LastVersion /// char9 "Last Version (if retired)"
        RevisionDates /// char10 "Revision Dates"
        EffectiveDate /// char11 -- not used in output
        note2 /// char 12 "Important Notes"
        note3 /// char 13 "Important Notes"
        note4 /// char 14 "Important Notes"
        note5 /// char 15 "Important Notes"
        note6 /// char 16 "Important Notes"
        note7 /// char 17 "Important Notes"
        note8 /// char 18 "Important Notes"
        note9 /// char 19 "Important Notes"
        note10 /// char 20 "Important Notes"
        ) 

    qui drop if name=="todrop"
     
    label var char1 "Form Type"
    label var char2 "Section"
    label var char3 "DW Variable Name"
    label var char4 "Question" 
    label var char5 "Response Type"
    label var char6 "Maximum Allowed Length"
    label var char7 "Range"
    label var char8 "Earliest Version"
    label var char9 "Last Version (if retired)"
    label var char10 "Revision Dates"
    label var char12 "Important Notes"

    sort vallab
    qui merge m:1 vallab using `"`tmp'"', nogenerate

    sort order
    drop order

    label var values "Variable code"

    qui {
        // replace semicolon delimiters with in-cell linebreak 
        replace values = subinstr(values,";","`=char(13)+char(10)'",.) 
         
        order char1 char2 char3 name char4 char5 ///
            varlab values char6 char7 format char8 char9 char10 char12

        replace format = "" if missing(char6) & char5!="date"
        replace format = "string" if strpos(format,"s") & strpos(format,"%")
        replace format = "numeric" if strpos(format,"g") & strpos(format,"%")

        replace char10 = char10+", "+char12 if !missing(char10) & char8!="1"

        replace char8 = "V"+char8
        replace char9 = "V"+char9 if !missing(char9)

        forval i=13/20 {
            count if !missing(char`i')
            if `r(N)'==0 drop char`i'
            else {
                replace char12=char12+";"+char`i'
                drop char`i'
            }
        }

        replace char12 = subinstr(char12,";","`=char(13)+char(10)'",.) 
    }
    drop char11 type

    export excel char1-char12 using `saving' if name!="", `sheet' ///
        `replace' `sheetreplace' `sheetmodify' firstrow(varlabels)

end

program check_saving, rclass
    syntax [anything] [, replace sheetmodify sheetreplace]
    // where to save?
    if `"`anything'"'=="" {
        di as err "You must specify the name of the data dictionary"
        exit 198
    }

    return local saving `anything'

    if "`replace'"!="" {
        return local replace `replace'
    }
end

