{smcl}
{* *! version 1.1.1  25aug2019}{...}
{vieweralsosee "corrona" "help corrona"}{...}
{vieweralsosee "export excel" "help import excel"}{...}
{viewerjumpto "Syntax" "cordd##syntax"}{...}
{viewerjumpto "Description" "cordd##description"}{...}
{viewerjumpto "Options" "cordd##options"}{...}
{viewerjumpto "Remarks" "cordd##remarks"}{...}
{viewerjumpto "Examples" "cordd##examples"}{...}
{hline}
{cmd:help cordd}{right:Create data dictionary from metadata}
{hline}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:cordd} {varlist} [using {it:{help filename}}] {ifin}{cmd:,} 
{cmdab:sav:ing(}{it:{help filename}}[{cmd:,} {opt replace}]{cmd:)}
[{it:options}]


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{cmdab:sh:eet("}{it:sheetname}{cmd:")}}save to Excel worksheet{p_end}
{synopt :{opt sheetmod:ify}}modify Excel worksheet{p_end}
{synopt :{opt sheetrep:lace}}replace Excel worksheet{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cordd} creates a data dictionary from metadata properities of the dataset
currently in memory or specified in the command line. 

{marker options}{...}
{title:Options}

{phang} 
{cmd:saving(}{it:{help filename}}[{cmd:,} {cmd:replace}]{cmd:)}
specifies the name of the workbook in which the new data dictionary should be
saved.  If {it:filename} already exists, it can be overwritten by specifying
{cmd:replace}.  

{phang}
{cmd:sheet("}{it:sheetname}{cmd:")} saves to the data dictionary contents to a 
worksheet named {it:sheetname}.  If there is no worksheet named 
{it:sheetname} in the workbook, a new sheet named {it:sheetname} is created.
If this option is not specified, the first worksheet of the workbook is used.

{phang}
{cmd:sheetmodify} writes updated data dictionary information to the existing
worksheet without changing any cells outside the exported range. 
This option is cannot be combined with
{cmd:sheetreplace} or the {cmd:replace} suboption of {cmd:saving()}.

{phang} 
{cmd:sheetreplace} clears the worksheet before the new data dictionary
information are exported to it. {cmd:sheetreplace} cannot be combined with
{cmd:sheetmodify} or the {cmd:replace} suboption of {cmd:saving()}.

	
{marker remarks}{...}
{title:Remarks}


{marker examples}{...}
{title:Examples}


{title:Author} 

{p 4 4 2}
Rebecca Raciborski {break}
Corrona, LLC {break}
rraciborski@corrona.org

{p 4 4 2}
Ning Guo {break}
Corrona, LLC {break}
nguo@corrona.org


{title:Also see}

{p 4 13 2}
Online:  help for
{browse "https://www.stata.com/manuals15/dimportexcel.pdf#dimportexcel":export excel} 
{p_end}
