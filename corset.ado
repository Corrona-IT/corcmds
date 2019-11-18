*! v2.0.0  17nov2019  RRaciborski
*! v1.2.1  15nov2019  RRaciborski
*! v1.2.0  26aug2019  RMedeiros
program define corset
version 15.1
syntax anything, [verbose /// for report and greport
				spec(passthru) LISTDefault /// for report
				Label(passthru) /// for group and greport
				VARiable(passthru) /// for greport
				FIRSTvar clear replace noREPort /// for group
				]

gettoken myarg list : anything

local user "`c(username)'"

// v2.0.0: determine subcommand and check data
mata: corset("`myarg'")

if "`subcmd'"=="report" & `valid'==1 {
	report `list', `verbose' `spec' `listdefault'
}
else if "`subcmd'"=="define" & `valid'==1 { 
	define `list'
}
else if "`subcmd'"=="group" & `valid'==1 {
	group `list' , `label' `firstvar' `clear' `replace' `report'
}
else if "`subcmd'"=="greport" & `valid'==1 {
	greport `list', `verbose' `label' `variable'
}
else if "`subcmd'"=="clear" {
		clear `list'
}
// else error
else {
	display in smcl "{err:invalid syntax; {bf:`subcmd'} not recognized}"
	exit 198
}
end


program define define
version 15.1
syntax anything

gettoken spec varlist : anything

if `:list sizeof varlist' < 1 {
	display as error "Too few variables or no spec specified."
	exit 198
}

unab varlist: `varlist'
confirm numeric variable `varlist'

// checking spec
// if spec is not at least 3 letters, reject
if ustrlen("`spec'")<2 {
	display smcl {err:{bf:`spec'} is not a valid variable spec}
	exit 197
}

// then check for an assign spec
if regexm("continuous","^`spec'") {
	foreach var of local varlist {
		char define `var'[corsetVarType] "continuous"
	}
}
else if regexm("categorical","^`spec'") {
	foreach var of local varlist {
		char define `var'[corsetVarType] "categorical"
	}
}
else if regexm("binary","^`spec'") {
	foreach var of local varlist {
		char define `var'[corsetVarType] "binary"
	}
}
else {
	display as error "Unrecognized spec `spec'."
	exit 197
}

end



program define clear 
version 15.1
syntax varlist
foreach var of local varlist {
	char define `var'[corsetVarType]
}
end



program define report
version 15.1
syntax [varlist], [verbose spec(string) listdefault]
unab varlist: `varlist'

capture confirm numeric variable `varlist'
local skipstrings = _rc

if "`verbose'"=="verbose"&"`spec'"!="" {
	display in smcl ///
        "{err:options {bf:verbose} and {bf:spec()} may not be combined.}"
	exit 184
}
if wordcount("`spec'")>1 {
	display in smcl "{err:option {bf:spec()} incorrectly specified}"
	exit 198
}

// then check for an assign spec
if "`spec'"!="" {
	if regexm("continuous","^`spec'") {
		local spec continuous
	}
	else if regexm("categorical","^`spec'") {
		local spec categorical
	}
	else if regexm("binary","^`spec'") {
		local spec binary
	}
	else {
		display as error "Unrecognized spec `spec'."
		exit 197
	}
}
// end error checking
if "`listdefault'"=="listdefault" {
	cortable_vartype `varlist'
	local binary `r(binvar)'
	local categorical `r(catvar)'
	local continuous `r(convar)'
}

display as text _col(2) %15s "Variable" _col(20) "Type"
di as text "{hline 32}"
if "`verbose'"==""&"`spec'"=="" {
	foreach var of local varlist {
		if  "`: char `var'[corsetVarType]'"!="" {
			display _col(2) %15s ///
                "`=abbrev("`var'",15)'" _col(20) "`: char `var'[corsetVarType]'"
		}
		else {
			if `: list var in binary' {
				display _col(2) %15s ///
                    "`=abbrev("`var'",15)'" _col(20) "binary*"
			}
			if `: list var in categorical' {
				display _col(2) %15s ///
                    "`=abbrev("`var'",15)'" _col(20) "categorical*"
			}
			if `: list var in continuous' {
				display _col(2) %15s ///
                    "`=abbrev("`var'",15)'" _col(20) "continuous*"
			}
		}

	}
}
if "`spec'"!="" {
	foreach var of local varlist {
		if  "`: char `var'[corsetVarType]'"=="`spec'" {
			display _col(2) %15s ///
                "`=abbrev("`var'",15)'" _col(20) "`: char `var'[corsetVarType]'"
		}
		else if `: list var in `spec'' {
			display _col(2) %15s "`=abbrev("`var'",15)'" _col(20) "`spec'*"
		}
	}
}
if "`verbose'"=="verbose" {
	foreach var of local varlist {
        display _col(2) %15s ///
            "`=abbrev("`var'",15)'" _col(20) "`: char `var'[corsetVarType]'"
	}
	else {
		if `: list var in binary' {
			display _col(2) %15s "`=abbrev("`var'",15)'" _col(20) "binary*"
		}
		if `: list var in categorical' {
			display _col(2) %15s "`=abbrev("`var'",15)'" _col(20) "categorical*"
		}
		if `: list var in continuous' {
			display _col(2) %15s "`=abbrev("`var'",15)'" _col(20) "continuous*"
		}
	}
}

di as text "{hline 32}"
if "`listdefault'"=="listdefault" {
	di as text "* Default setting used by cortable."
}
if `skipstrings' {
	di as text "Note: String variables not shown in table."
}
end


program define group
syntax varlist, [Label(string) /// label to apply
				FIRSTvar /// copy label from first var
				clear /// clear labels
				replace /// replace existing labels
				noREPort /// supress report at end
				]

unab varlist: `varlist'

if "`clear'"=="" {
	// must supply either label() or firstvar 
	if "`label'"==""&"`firstvar'"=="" {
		display in smcl ///
            "{err:you must specify either {bf:label()} or {bf:firstvariable}}"
		exit 198
	}

	// cannot specify both label() and firstvar
	if "`label'"!=""&"`firstvar'"!="" {
		display in smcl ///
            "{err:you cannot specify both {bf:label()} and {bf:firstvariable}}"
		exit 198
	}

	// if firstvar, check to see that first variable has a label
	if "`firstvar'"!="" {
		gettoken thefirstvar varlist : varlist
		* check to see that firstvar has a label
		if `"`: char `thefirstvar'[corsetGroupLabel]'"'=="" {
			display in smcl ///
                "{err:variable {bf:`thefirstvar'} does not have a group label}"
			exit 198
		}
		else {
			local label `"`: char `thefirstvar'[corsetGroupLabel]'"'
		}
	}

	// if replace not specified, 
    // check to make sure none of the variables have labels
	local needreplace 0
	local firsterror 1
	if "`replace'"=="" {
		foreach var of local varlist {
			if `"`: char `var'[corsetGroupLabel]'"'!="" & ///
			  `"`: char `var'[corsetGroupLabel]'"'!=`"`label'"' {
				// if this is the first pre-existing label
				if `needreplace'==0 {
					display _n
					display in smcl "{err:The variables listed below already have labels;}" ///
						"{err: to replace those labels, specify {bf:replace}.}"
					local needreplace = 1
				}
				grprint `firsterror' `var' "as error"
				local firsterror 0
			}
		}
		if `needreplace' {
			di as error "{hline 70}"
			exit 198
		}
	}
	// now set the label
	foreach var of local varlist {
		char define `var'[corsetGroupLabel] `"`label'"'
	}

	// now the report all variables that share that group label
	if "`report'"!="noreport" {
		di _n "The following variables are now grouped"
		greport , label(`"`label'"')

	}
}
if "`clear'"=="clear" {
	if "`label'"!="" | "`firstvar'"!="" | "`replace'"!="" | "`noreport'"!="" {
		di in smcl ///
            "{err:{bf:clear} may not be specified with any other options.}"
		exit 198
	}
	foreach var of local varlist {
		char define `var'[corsetGroupLabel] 
	}
}
end


program define greport
syntax [varlist], [	Label(string) /// lists variables with matching label
					VARiable(varname) /// lists variables with same label
					verbose /// variables without labels are listed
					]
local first 1

if "`variable'"!=""&`"`label'"'!="" {
		display in smcl ///
            "{err:you cannot specify both {bf:label()} and {bf:variable()}}"
		exit 198
}
// to match a variable, grab it's label
if "`variable'"!="" {
	local label `"`: char `variable'[corsetGroupLabel]'"'
	if "`label'"=="" {
		display _n "Variable `variable' does not have a label."
		exit
	}
}
if `"`label'"'!="" {
	foreach var of varlist * {
		if  `"`: char `var'[corsetGroupLabel]'"'==`"`label'"' {
			grprint `first' `var'
			local first 0
		}
	}
}
// print all labels
if `"`label'"'==""&"`verbose'"=="" {
	foreach var of varlist `varlist' {
		if  `"`: char `var'[corsetGroupLabel]'"'!="" {
			grprint `first' `var'
			local first 0
		}
	}
}
// print variables with no label
if `"`label'"'==""&"`verbose'"=="verbose" {
	foreach var of varlist `varlist' {
		grprint `first' `var' 
		local first 0
	}
}

if `first' {
	di _n as result "No grouped variables found"
}
if `first'==0 {
	di as text "{hline 70}"
}
end

program define grprint
args first var type
if "`type'"=="" {
	local type as text
}

if `first' {
	di `type' "{hline 70}"
	display `type' _col(2) %20s "Variable" _col(25) "Group label"
	di "{hline 70}"
}
display `type' _col(2) %20s "`=abbrev("`var'",20)'" _col(25) ///
	"`: char `var'[corsetGroupLabel]'"
end

