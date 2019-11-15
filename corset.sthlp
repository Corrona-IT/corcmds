{smcl}
{* *! version 1.0.0  22aug2019}{...}
{vieweralsosee "cortable" "help cortable"}{...}
{viewerjumpto "Syntax" "corset##syntax"}{...}
{viewerjumpto "Description" "corset##description"}{...}
{viewerjumpto "Options" "corset##options"}{...}
{viewerjumpto "Remarks" "corset##remarks"}{...}
{viewerjumpto "Examples" "corset##examples"}{...}
{hline}
{cmd:help corset}{right:Manage variable settings for table automation}
{hline}

{marker syntax}{...}
{title:Syntax}

{p 4}
Define the variable type

{p 8}
{cmd:corset} {opt d:efine} {it:{help corset##spec:spec}} {varlist} 


{p 4}
Set groupings

{p 8 32}
{cmd:corset} {opt gro:up} {varlist}
[, {opt l:abel(text)}
{opt first:var} 
{opt clear} 
{opt replace} 
{opt noreport}]


{p 4}
Report the current settings

{p 8 32}
{cmd:corset} {opt r:eport} [{varlist}] 
[, {opth spec:(corset##spec:spec)} 
{opt verbose}]

{p 8 36}
{cmd:corset} {opt gre:port} [{varlist}] 
[, {cmdab:l:abel(}{it:{help exp}}{cmd:)} 
{cmdab:var:iable(}{it:{help varlist:varname}}{cmd:)} 
{opt verbose}]

{p 4}
Clear the settings

{p 8 32}
{cmd:corset} {cmd:clear} {varlist}

{p 8 32}
{cmd:corset} {cmd:clear} [ {cmd:_all} | {cmd:*} ]

{pstd}
{it:spec} is one of the following: 

{p2colset 9 25 27 2}{...}
{p2col :{opt bin:ary}}Set variables to have frequency and percentages 
calculated only for the level where the value is 1{p_end}
{p2col :{opt cat:egorical}}Set variables to 
have frequency and percentages calculated for each observed nonmissing value
{p_end}
{p2col :{opt con:tinuous}}Set variables to have meaures of central tendency and dispersion calculated{p_end}
{p2colreset}{...}


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Group}
{synopt :{opt label(text)}}define label for group{p_end}
{synopt :{opt firstvar}}copy label from first listed variable{p_end}
{synopt :{opt clear}}remove group settings{p_end}
{synopt :{opt replace}}replace existing labels{p_end}
{synopt :{opt noreport}}suppress table of variable group results{p_end}

{syntab :Report}
{synopt :{opth spec:(corset##spec:spec)}}specify 
analytic treatment of each variable{p_end}
{synopt :{opt v:erbose}}include 
all variables in output{p_end}
{synopt :{opt l:abel(text)}}report 
only variables with this label{p_end}
{synopt :{cmdab:var:iable(}{it:{help varlist:varname}}{cmd:)}}report only 
variables that are in a group with {it:varname}{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:corset define} declares the variable type, for table display
purposes, of variables before using {helpb cortable}. 

{pstd}
{cmd:corset group} causes {helpb cortable} to display a set of nonmutually
exclusive categorical variables as a group within the table. It can also be
used to group continuous and categorical treatments of the same measure.

{pstd}
{cmd:corset report} and {cmd:corset greport} provide information about the
current table automation settings for the specified {it:varlist}.  
{cmd:corset report} reports the analysis settings. 
{cmd:corset greport} lists the variable name and group label.
Omitting the {varlist} will print information about all variables that have 
settings applied.

{pstd}
{cmd:corset clear} removes the variable specification and group settings for
the variables in {varlist}.  {cmd:corset clear all} and {cmd:corset clear *}
are synonyms. They are a shortcut to remove settings from all variables.  


{marker options}{...}
{title:Options}

{dlgtab:Group}

{phang}
One of {opt label(exp)}, {opt firstvar}, or {opt clear} must be specified.
These options cannot be specified together. 

{phang2}
{cmd:label(}{it:{help exp}}{cmd:)} defines the label that should be applied to
the group when displayed in the table. If {it:exp} includes spaces it must be
enclosed in double quotes ({cmd:""}). 

{phang2}
{opt firstvar} copies the label from first variable listed in the {it:varlist}
and uses it as the group label. 

{phang2}
{opt clear} clears the currently-applied group labels from the variables 
specified in {it:varlist}. Use {cmd:_all} or {cmd:*} to clear group labels
from all variables in the dataset.

{phang}
{opt replace} replaces the existing group label. You must specify this option
if one or more variables in {it:varlist} is already a member of a group.

{phang}
{opt noreport} suppresses the table showing the results of {cmd:corset group}. 

{pstd}
Options {opt replace} and {opt noreport} are ignored if {opt clear} is
specified.
	
	
{dlgtab:Report}

{phang}
{opth spec:(corset##spec:spec)} will list all variables of the specified 
{it:spec}. {cmd:spec()} is only available with {cmd:corset report}.

{phang}
{opt verbose} with {cmd:corset report} prints a list for either all variables
listed or all in the dataset. When used with {cmd:corset greport}, the 
{opt verbose} option causes {cmd:corset} to list the variable name and
group label for all variables in the {it:varlist} or all in the dataset.

{phang}
{cmdab:l:abel(}{it:{help exp}}{cmd:)} specifies that {cmd:corset} report only
variables with the label given by {it:exp}. If {it:exp} includes spaces it must
be enclosed in double quotes ({cmd:""}).

{phang}
{cmdab:var:iable(}{it:{help varlist:varname}}{cmd:)} 
report {it:varname} and all other variables that are part of its group.

	
{title:Remarks}

{pstd}
{cmd:corset define} is used to declare the variable type, for table display
purposes, of each variable in the dataset before using {helpb cortable}. 
You are not required to declare a variable type. If you do not declare a type, 
the following defaults are used:

{phang2}
{cmd:binary} is assigned to all variables with only values 0 and 1 or missing.

{phang2}
{cmd:categorical} is assigned to all variables with between two and twenty 
unique values. Missing values are ignored when counting unique values.

{phang2}
{cmd:continuous} is assigned to all variables with more than twenty 
unique values or if the value label {cmd:cmiss} has been applied. 
Missing values are ignored when counting unique values.

{pstd}
By specifying the {opt verbose} option with {cmd:corset greport}, you also are
able to see variables without labels in the output. This is a good way to check
that you have created all the groups that you intended to create. 


{title:Examples}

{hline}
{p 2}
Group location of residence variables together

{phang}
{cmd:. sysuse nlsw88}{p_end}
{phang}
{cmd:. corset group south smsa c_city, label("Location")}{p_end}

{hline}
{p 2}
Check number of unique values of grade and make continuous

{phang}
{cmd:. codebook grade}{p_end}
{phang}
{cmd:. corset define continuous grade}{p_end}

{hline}
{p 2} 
Report settings 

{phang}
{cmd: . corset report}{p_end}

{hline}
{p 2}
Report group settings (most common use)

{phang}
{cmd:. corset greport, var(south)}


{title:Author} 

{p 4 4 2}
Rose Medeiros {break}
Corrona, LLC {break}
rmedeiros@corrona.org
