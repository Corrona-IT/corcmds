*! v2.0.6  04aug2022  PLakin
*! v2.0.5  11nov2021  PLakin
*! v2.0.4  05jul2020  RMedeiros
*! v2.0.3  25jun2020  RMedeiros
*! v2.0.2  03jun2020  RMedeiros
*! v2.0.1  10dec2019  RMedeiros
*! v2.0.0  17nov2019  RRaciborski
*! v1.2.1  15nov2019  RRaciborski
*! v1.2.0  07sep2019  RMedeiros

program define cortable, rclass
version 16.1

syntax varlist(numeric) [if] [in] /// rowvariable list
	[, ///
    SAVing(string asis) /// SAVing(<filename>, [replace|append]) - docx file to save
	name(string) /// name(<handle>, replace append), used when not saving
	///
	SAVEDta(string) /// SAVEDta(<filename> , [replace|append])
	omitdta /// required if not saving data 
	clear /// runs -put* clear- 
	///
	/// options for what goes in the table
	COLvars(varlist numeric fv) /// list of (fv) variables for columns
	TOTal /// total column when colvar is specified
	SUPpress(integer 5) /// when to supress cells for small size 
	na(string) /// what to display when suppressed
	constat(string) /// stats for continuous variables 
	counts /// gives counts of non-missing values of variables
	NODENOMinator /// prevents printing of variable denominators
	///
	/// Options for formatting and titling the table
	noHEader /// supresses header
	ADDHeader /// forces the normal header below altheader
	HEADERFormat(string) /// this contains -`put'-  cell_fmt_options
	ALTHeader(string) /// altheader("text", optons) alternative header, 
	ALTROWheader(string) /// alternative to "Characteristics" in upper left
	TABNumber(string) /// table number/id, parses to tabnum(id, noprint) 
	title(string) ///
	font(passthru) /// font specification, goes straight to -`put'-
	LANDscape /// makes doc landscape
	pdf /// saves to putpdf 
	docx /// default but can be specified 
	TABLEOPTions(string) /// options at table creation time 
	PCTFoverride(string) /// percent format override for cat and binary
	CONFoverride(string) /// continuous statistics format override
	]
	
local fullcmd `"`0'"'

********************************
local user "`c(username)'"
local user plakin
mata: cortable_check()

local rowvarlist `varlist'
	
cortable_vartype `rowvarlist'
local binvar `r(binvar)'
local catvar `r(catvar)'
local convar `r(convar)'

opts_exclusive "`pdf' `docx'" "" 184
if "`pdf'"=="pdf" {
	local put putpdf
}
else {
	local put putdocx
}

// Checking validity of options 
    // SAVING()
        // first parse the saving option
if `"`saving'"'!="" {
	local 0 `"`saving'"'
	syntax [anything] [, replace append]
	local saving `"`anything'"'
	* can't specify replace and append
	if "`replace'"=="replace"&"`append'"=="append" {
		opts_exclusive "return append" "" 184
	}	
	* making sure file doesn't already exist
	if "`replace'"==""&"`append'"=="" {
		if `=ustrpos("`saving'",".docx")'==0 {
			capture noisily confirm new file `saving'.docx
		}
		else {
			capture noisily confirm new file `saving'
		}
		if _rc {
			display in smcl "{err:you must specify either {bf:replace}}" ///
                "{err: or {bf:append} in the {bf:saving()} option}"
			exit 198
		}
	}
}

    // NAME() 
        // table is new until we know otherwise
local newtable 1 
if "`name'"=="" {
	tempname tname
	local currow 1
}
else {
	tokenize `"`name'"', parse(",")
	confirm name `1'
	local tname `1'
	local currow 1
	// check to see if table already exists
	capture `put' describe `tname'
	if _rc==0 { // if table exists
		local currow = r(nrows)
		if strpos("`3'","replace") {
			local treplace replace
		}
		if strpos("`3'","append") {
			local tappend append
			local newtable 0
		}
		* can't specify replace and append
		if "`treplace'"=="replace"&"`tappend'"=="append" {
			display in smcl "{err:Option {bf:name()} misspecified.}"
			opts_exclusive "return append" "" 184
		}
		if "`treplace'"==""&"`tappend'"==""&"`clear'"=="" {
			di as err "Table {bf:`tname'} already exists. " ///
                "You must specify {bf:name(, append)}, " ///
                "{bf:name(, replace)}, or {bf:clear}."
			exit 198
		}
		
		if "`tappend'"==""&"`clear'"=="clear" {
			local newtable 1
		}
		else {
			local newtable 0 
		}
	}
}

    // PCTFoverride(), CONFoverride() 
        // table is new until we know otherwise
if "`pctfoverride'" != "" {
	di "`pctfoverride' format override specified for categorical statistics."
}

if "`confoverride'" != "" {
	di "`confoverride' format override specified for continuous statistics."
}

if "`na'"=="" {
	local na n/a
}

if `"`font'"'=="" {
	local font font("Calibri", 10.5)
}

* default statistics n msd
if "`constat'"=="" {
	local constat msd
}
local constat = usubinstr("`constat'","median","p50",.)

// options for post-file to save dta
tokenize `"`savedta'"', parse(",")
if `"`1'"'=="" {
	if "`omitdta'"=="" {
		display in smcl `"{err:No dta file specified to save results. This is probably an error }"' ///
			`"{err:if this is intentional, specify option {bf:omitdta}.}"'
	}
	else if "`omitdta'"=="omitdta" {
		local post = 0
	}
}
else {
	local post = 1
	local postfile `"`1'"'

	
	* checking replace and append options
	if `=ustrpos("`3'","append")' {
		local postappend append
	}
	if `=ustrpos("`3'","replace")' {
		local postreplace replace
	}
	if "`postreplace'"=="replace"&"`postappend'"=="append" {
		opts_exclusive "return append" "" 184
	}	
	
	tempname handle 
	tempfile temppost 
	
	* rowvar rowvarlevel colvar statistic value tableno 
	* note colvar uses factor variables, so no level is needed
	postfile `handle' str35 rowvar rowvarlevel str35 colvar ///
		str10 statistic value str35 tableno using `temppost' 
}


// process colvars() option
local ncols = 2
if "`colvars'"!="" {
	local colvarnames `colvars'
	 fvexpand ibn.(`colvars')
	 local colvars = r(varlist)
	 local ncols = `: list sizeof colvars' + 1
	 if "`total'"!="" {
		local ncols = `ncols'+1
	 }
}
if "`colvars'"==""|"`total'"=="total" {
	local colvars `touse' `colvars'
}

// process tabnumber(id, noprint)
if "`tabnumber'"!="" {
    local printtabnum 1
	tokenize `"`tabnumber'"', parse(,)
	local tabnumber `1'
	if "`3'"=="noprint" {
		local printtabnum 0
	}
}
else {
    local printtabnum 0
}

// Start writing table
if "`clear'"=="clear" {
	if "`tappend'"=="append" {
			display in smcl "You have specified {bf:name( , append)} and {bf:clear}. Option {bf:clear} ignored."
	}
	else {
		`put' clear
	}
}

capture `put' begin, `font' `landscape'

if `newtable' {	
	if `"`title'"'!= "" & "`tabnumber'"!="" & `printtabnum' {
		`put' paragraph
		`put' text (`"Table `tabnumber': "'), bold 
		`put' text (`"`title'"')
	}
	if `"`title'"'== "" & "`tabnumber'"!="" & `printtabnum' {
		`put' paragraph
		`put' text (`"Table `tabnumber'"'), bold 
	}
	if `"`title'"'!= "" & ("`tabnumber'"==""|!`printtabnum')  {
		`put' paragraph
		`put' text (`"`title'"')
	}
	
	
	// for new tables always 1 row, c depends on # of groups 
    // & whether a total is wanted or not 
	//n: di "tableoptions = `tableoptions'"
	local initrows = 1
	local hryn = ustrpos("`tableoptions'", "headerrow") 
	//n: di "hryn = `hryn'"
	if `hryn' > 0 {
		n: local toptswords = "`=wordcount("`tableoptions'")'"
		//n: di "toptswords = `toptswords'"
		tokenize "`tableoptions'"
		forvalues wordi = 1/`=`toptswords'' {
			//n: di "wordi = ``wordi''"
			if ustrpos("``wordi''", "headerrow") > 0 {
				//n: di "wordi = ``wordi''"
				local hrn = ustrregexra("``wordi''","\D","")
			}
		}
		n: di "hrn = `hrn'"
		local initrows = `hrn'
	}
	`put' table `tname' = (`initrows',`ncols'),  `tableoptions'
	local currow = 1
}
if !`newtable' {
	`put' table `tname'(`currow',.), addrows(1, after) nosplit
	local currow = `currow' + 1
}

if "`altheader'"!="" {
	if "`header'"==""&"`addheader'"=="" {
		local header noheader
	} 
}
// write the first rows/headers
if "`header'"!="noheader" {
	if `"`altrowheader'"' == "" {
		local altrowheader "Characteristics"
	}
	// title adds a row, insert into 2nd row, not first
	`put' table `tname'(`currow',1) = (`"`altrowheader'"')
	`put' table `tname'(`currow',.), `headerformat' nosplit

	if `: list sizeof colvars'==1 {
		`put' table `tname'(`currow',.), addrows(1, after) nosplit
		local currow = `currow' + 1
		`put' table `tname'(`currow',.), `headerformat' nosplit
		qui count if `touse'
		`put' table `tname'(`currow',1) = ("Total (N)")
		`put' table `tname'(`currow',2) = ("N = `=trim("`: display %9.0fc r(N)'")'"), halign(center)
	}
	// header if you have multiple column variables specified
	else {
	    local col = 2
		`put' table `tname'(`currow',.), addrows(1, after) nosplit
		`put' table `tname'(`=`currow'+1',.), `headerformat' nosplit
		if "`total'"!="" {
			`put' table `tname'(`currow',`col') = ("Total"), halign(center)
			qui count if `touse'
			`put' table `tname'(`=`currow'+1',`col') = ///
                ("N = `=trim("`: display %9.0fc r(N)'")'"), halign(center)
			local col = `col' + 1
		}
		local cj = 0
            // for each fv term, except touse
		foreach cvar in `=usubinstr("`colvars'","`touse'","",.)' { 
			parse "`cvar'", parse(".")
			// take on bn and o from factor vars
			local l `=usubinstr(usubinstr("`1'","bn","",.),"o","",.)'
			local cvar `3'
			local vlab: label (`cvar') `l'
			`put' table `tname'(`=`currow'',`=`col'+`cj'') = ///
                ("`vlab'"), halign(center)
			qui count if `touse' & `cvar'==`l'
			`put' table `tname'(`=`currow'+1',`=`col'+`cj'') = ///
                ("N = `=trim("`: display %9.0fc r(N)'")'"), halign(center)
			local cj = `cj' + 1
		}
		local col = `col' + `cj'
		local currow = `currow'+1
	}
	`put' table `tname'(`currow',.), border(bottom,single) nosplit
}

if "`altheader'"!="" {
	tokenize `"`altheader'"', parse(",")
	local alttext `"`1'"'
	local altoptions = subinstr("`altheader'", "`alttext'","",1)
	* note comma in option
	if "`addheader'"=="addheader" {
		`put' table `tname'(`currow',.), addrows(1, after) nosplit
		local currow = `currow' + 1
	}
	`put' table `tname'(`currow',1) = (`"`alttext'"') `altoptions'
	`put' table `tname'(`currow',.), `headerformat' nosplit
	*`put' table `tname'(`currow',.), border(bottom,single)
	if "`addheader'"=="" {
		`put' table `tname'(`currow',.), addrows(1, after) nosplit
		local currow = `currow' + 1
	}
}

if "`counts'"=="counts" {
	`put' table `tname'(`currow',.), drop
	local currow = `currow' - 1 // overwrite that header row with N = 
	cortable_counts,  ///
		put(`put') ///
		rowvarlist(`rowvarlist') /// rowvariable list
		currow(`currow') ///
		touse(`touse') /// holds the touse variable
		post(`post') /// will be 0 or 1
		handle(`handle') /// name of handle file for postfile
		na(`"`na'"') /// what to display when suppressed
		tname(`tname') /// name(<handle>, replace append) name of table
		colvars(`colvars') /// list of variables or factor variables for columns
		tabnumber(`tabnumber') /// table number
		// suppress(integer -1) // purposefully leaving this blank here
		
	
	local currow = r(currow)
}
else {
	cortable_split, /// 
		put(`put') ///
		rowvarlist(`rowvarlist') /// rowvariable list
		binvar("`binvar'") /// variable types
		catvar("`catvar'") /// 
		convar("`convar'") /// 
		currow(`currow') ///
		touse(`touse') /// holds the touse variable
		post(`post') /// will be 0 or 1
		handle("`handle'") /// name of handle file for postfile
		///
		na(`"`na'"') /// what to display when suppressed
		tname("`tname'") /// name(<handle>, replace append) name of table
		///
		/// options for what goes in the table
		colvars(`colvars') /// list of variables or factor variables for columns
		suppress(`suppress') /// when to supress cells for small size 
		constat("`constat'") /// stats can be anything produced by -summ 
		tabnumber(`tabnumber') /// table number
		`header' `addheader' font(`font') ///
		`nodenominator' /// option to suppress denominator
		pctfoverride(`pctfoverride') ///
		confoverride(`confoverride')
	local currow = r(currow)
}

if `newtable' {
		if `initrows' > 1 {
			local delrows = `initrows' - 1
			forvalues i = 1/`=`delrows'' {
				putdocx table `tname'(`=`currow'+1', .), drop
			}
		}
}

if "`r(nvaries)'"!="" {
	di as error "The following variable(s) have non-missing counts that do not match the header shown in the table:"
	di as error "`nvaries'"
	`put' paragraph
	`put' text ("The following variable(s) have non-missing counts that do not match the header shown in the table: ")
	`put' text ("`r(nvaries)'."), bold 
}

// end looping for rows

if `"`saving'"'!="" {
	`put' save "`saving'", `replace' `append'
}

if `post' {
	postclose `handle' 
	
	preserve
	if "`postappend'"=="append" {
		use `"`postfile'"', clear
		capture confirm variable append
		if _rc {
			append using `temppost', generate(append)
			replace colvar = "total" if colvar=="`touse'"
			save , replace
		}
		else {
			qui summ append
			local max = r(max)
			use `temppost', clear
			quietly: gen append = r(max) + 1
			quietly: replace colvar = "total" if colvar=="`touse'"
			append using `"`postfile'"'
			note _dta: append = `=`r(max)'+1' table `tabnumber' command `fullcmd'
		}
	}
	else {
		use `temppost', clear
		quietly: replace colvar = "total" if colvar=="`touse'"
		note _dta: table `tabnumber' command `fullcmd'
		save `"`postfile'"', `postreplace'
	}
	restore
}

return scalar nrows = `currow'
return local binvar = "`binvar'"
return local catvar = "`catvar'"
return local convar = "`convar'"
return local colvars = "`colvars'"
return local tableoptions = "`tableoptions'"

end
