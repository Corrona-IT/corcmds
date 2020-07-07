{smcl}
{* *! version 2.1.0  07jul2020}{...}
{vieweralsosee "[D] cf" "help cf"}{...}
{vieweralsosee "[D] compare" "help compare"}{...}
{vieweralsosee "[D] merge" "help merge"}{...}
{vieweralsosee "[D] sort" "help sort"}{...}
{viewerjumpto "Syntax" "corcf##syntax"}{...}
{viewerjumpto "Description" "corcf##description"}{...}
{viewerjumpto "Options" "corcf##options"}{...}
{viewerjumpto "Remarks" "corcf##remarks"}{...}
{viewerjumpto "Examples" "corcf##examples"}{...}
{hline}
{cmd:help corcf}{right:Compare values of variables in two datasets}
{hline}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:corcf} {varlist} using {it:{help filename}} [{cmd:,} {it:options}]


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{opth id:(varlist:idvars)}}use {it:idvars} as the ID variables{p_end}
{synopt :{opt v:erbose}}add table of discordant values for each variable{p_end}
{synopt :{opt all}}include note for variables without discordant values{p_end}
{synopt :{opt master:list}}add table of observations appearing only in master 
data{p_end}
{synopt :{opt using:list}}add table of observations appearing only in using data
{p_end}

{syntab :Matching}
{synopt :{opth reldif(#)}}threshold for relative difference in numeric values{p_end}
{synopt :{opt nodecr:ease}}decreases within relative difference are still errors{p_end}

{syntab :List}
{synopt :{opt noo:bs}}do not list observation numbers{p_end}
{synopt :{opt clean}}force table format with no divider or separator
lines{p_end}
{synopt :{opt sep:arator(#)}}draw a separator line every {it:#} lines; default 
    is {cmd:separator(5)}{p_end}
{synopt :{opth sepby:(varlist:varlist2)}}draw a separator line whenever
           {it:varlist2} values change{p_end}
{synopt :{opt nol:abel}}display numeric codes rather than label values{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:corcf} compares variables in the dataset in memory (the master dataset) 
to the corresponding variables in filename (the using dataset). 
Only the variable values are compared.  Variable labels, value labels, notes, 
characteristics, etc. are not compared.

{pstd}
Unlike the official {helpb cf} command, {cmd:corcf} will list the observations 
where differences exist. Lists are provided by variable with values identified
as coming from either the {bf:master_data} or {bf:using_data}. 

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt id(idvars)} specifies variables that uniquely identify records within the
    datasets. The {it:idvars} are used to match the
    observations in the using dataset to those in the master dataset. This 
	option is required if the master and using datasets have
    different numbers of observations.  

{phang2}
To merge observations on observation number, for example when the expected 
    change is in the values of the merge keys themselves and resulting sort
    order, omit the {bf:id()} option. 

{phang} 
{opt verbose} displays a table, by variable, comparing the master and using
    values that differ.  If not specified, only the number of differences is
    listed.

{phang}
{opt all} displays the result of the comparison for each variable in {varlist}.
    Unless {cmd:all} is specified, only the results of the variables that
    differ are displayed.

{phang}
{opt masterlist} displays a table of observations found only in the master 
	dataset. The list is sorted by {it:idvars}. 

{phang}
{opt usinglist} displays a table of observations found only in the using 
	dataset. The list is sorted by {it:idvars}. 
	

{dlgtab:Matching}

{phang}
{opt reldif(#)} specifies that {cmd:corcf} ignore differences within a
tolerance of |#| percent. Any positive number greater than 0 may be specified. 
For example, {cmd:reldif(1)} allows a difference of
-1% to 1% between the dataset in memory compared to the dataset on disk. 

{pstd}
The same value is applied to all variables in {it:varlist}. This option is
designed as a complement for the tables of descriptive statistics produced by
{helpb cortable}. If used with raw datasets, make sure to restrict the 
{it:varlist} to continuous variables.

{phang} 
{opt nodecrease} specifies that {opt reldif(#)} only apply to non-negative
changes. For example, if {cmd:reldif(1)} is specified, the allowed change is 0
to 1%. 

	
{dlgtab:List}

{pstd}
Options {opt clean}, 
{opt noobs},
{opt nolabel},
{opt separator(#)}, 
and 
{opt sepby(varlist2)} control the look of the listing output if {opt verbose}
is specified. See {helpb list} for additional details about the 
affect of specifying these options.

{phang}
{opt clean} will produce more readable output on the screen by removing all 
	dividing and separating lines.
	
{phang}
{opt noobs} suppresses the listing of the observation numbers.

{phang}
{opt nolabel} specifies	that the numeric code be displayed rather than label 
	values.


{marker remarks}{...}
{title:Remarks}

{pstd} 
Unlike the official {cmd:cf} command, the master and the using data need
not have the same number of observations or the same sort order. You should
verify the sort order before using {cmd:corcf} if you do not specify the 
{opt id()} option.

{pstd}
{cmd:corcf} is designed to primarily compare analytic datasets before and after
changes to registry set-up code or as part of validating changes made during a
mid-study update. As such, it is of most use for registry leads and others
working on registry data management. 

{pstd}
{it:Note}: Variable name length

{pstd}
Stata restricts variable name lengths to 32 characters. {cmd:corcf} requires an
extra character be added to each variable name. In the unlikely case that you
have variable names at the allowable limit, you will encounter an error. If
this happens, you must rename your long variable names in both the master and
the using data before issuing your {cmd:corcf} command or omit the long
variables from the compared {it:varlist}. Users with reasonable-length variable
names will not be affected by this extra step. 

{marker examples}{...}
{title:Examples}

{pstd}
{ul:Setup:}

{pstd}
{cmd:. sysuse nlsw88}

{pstd}
{cmd:. save nlswbase, replace}{break}
{cmd:. drop if grade==0}{break}
{cmd:. replace age=age+rbinomial(1,0.02)}{p_end}

    {hline}
{pstd}
Find variables that differ between current (master) and base (using)

{phang2}
{cmd:. corcf * using nlswbase, id(idcode)}{p_end}

    {hline}
{pstd}
Also see which IDs are in the using but not the master

{phang2}
{cmd:. corcf * using nlswbase, id(idcode) usinglist}{p_end}

    {hline}
{pstd}
See listing of observations that differ

{phang2}
{cmd:. corcf * using nlswbase, id(idcode) verbose}{p_end}

    {hline}
{pstd}
Also sort and group differing observations by another variable, suppressing the
observation number

{phang2}
{cmd:. corcf * using nlswbase, id(idcode) verbose sepby(occupation) noobs} 
{p_end}


{title:Author} 

{p 4 4 2}
Rebecca Raciborski {break}
Corrona, LLC {break}
rraciborski@corrona.org


{marker alsosee}{...}
{title:Also see}

{p 4 13 2}
Online:  help for
{browse "https://www.stata.com/manuals15/dcf.pdf#dcf":cf}, 
{browse "https://www.stata.com/manuals15/dcompare.pdf#dcompare":compare},
{browse "https://www.stata.com/manuals15/dsort.pdf#dsort":sort},
{browse "https://www.stata.com/manuals15/dmerge.pdf#dmerge":merge}
{p_end}
