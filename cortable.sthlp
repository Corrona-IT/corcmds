{smcl}
{* *! version 1.0.2  13sep2019}{...}
{vieweralsosee "corcf" "help corcf"}{...}
{vieweralsosee "corset" "help corset"}{...}
{vieweralsosee "[R] summarize" "help summarize"}{...}
{vieweralsosee "[P] putdocx" "help putdocx"}{...}
{vieweralsosee "[P] putdocx" "mansection P putdocx"}{...}
{viewerjumpto "Syntax" "cortable##syntax"}{...}
{viewerjumpto "Description" "cortable##description"}{...}
{viewerjumpto "Options" "cortable##options"}{...}
{* viewerjumpto "Remarks" "cortable##remarks"}{...}
{viewerjumpto "Examples" "cortable##examples"}{...}
{hline}
{cmd:help cortable}{right:Create automated tables in Word or PDF}
{hline}

{marker syntax}{...}
{title:Syntax}

{p 4 8 2}
Write table to Word and save table contents to a dataset

{p 8 12 2}
{cmd:cortable} {varlist} {ifin},  
	{cmdab:sav:ing(}{it:{help filename}} 
        [{cmd:, }{opt replace} | {opt append}]{cmd:)} 
	{bind:{cmdab:saved:ta(}{it:filename}} 
        [{cmd:, }{opt replace} | {opt append}]{cmd:)} 
    [{it:options}]

{p 4 8 2}
Write table to Word without saving table contents to a dataset

{p 8 12 2}
{cmd:cortable} {varlist} {ifin},  
	{cmdab:sav:ing(}{it:{help filename}} 
        [{cmd:, }{opt replace} | {opt append}]{cmd:)} 
	{opt omitdta}
    [{it:options}]
	
{p 4 8 2}
Create table in memory, but do not write it to Word, saving contents to a dataset 

{p 8 12 2}
{cmd:cortable} {varlist} {ifin}, {bind:{cmdab:saved:ta(}{it:filename}} 
        [{cmd:, }{opt replace} | {opt append}]{cmd:)} 
    [{it:options}]


{phang}
where {varlist} is a list of numeric variables for the table rows. 

{synoptset 34 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{cmdab:sav:ing(}{it:sspec}{cmd:)}}the {cmd:.docx} or {cmd:.pdf} file to save{p_end}
{synopt :{cmdab:saved:ta(}{it:sspec}{cmd:)}}the name of the {cmd:.dta} file to save{p_end}
{synopt :{opt omitdta}}do not save dataset{p_end}
{synopt :{opt pdf}}save table to a PDF using {cmd:putpdf}{p_end}
{synopt :{opt docx}}save table to Word using {cmd:putdocx} (default){p_end}

{syntab :Table contents}
{synopt :{cmdab:col:vars(}{it:{help varlist:colvarlist}}{cmd:)}}list of variables or factor variables for 
columns{p_end}
{synopt :{opt tot:al}}include total column in table{p_end}
{synopt :{opt sup:press(#)}}threshold to supress cells for small size; default is 5{p_end}
{synopt :{opt na(text)}}display {it:text} instead of {cmd:n/a} when cell is 
suppressed{p_end}
{synopt :{cmd:counts}}request table containing counts of non-missing observations{p_end}
{synopt :{cmd:constat(}{it:{help cortable##statname:statname}} [{it:...}]{cmd:)}}statistics for continuous variables{p_end}

{syntab :Table header}
{synopt :{cmdab:headerf:ormat(}{it:{help putdocx##cellfmtopts:cell_fmt_options}}{cmd:)}}options that control the look of cell contents in first row{p_end}
{synopt :{cmdab:altrow:header(}{it:text}{cmd:)}}show {it:text} in place of {cmd:Characteristics} for description of rows{p_end}
{synopt :{cmdab:alt:header(}{it:text}[,{it:options}]{cmd:)}}specify alternative header cell or row{p_end}
{synopt :{cmdab:nohe:ader}}suppress header{p_end}
{synopt :{cmdab:addh:eader}}force usual header when {cmd:altheader()} is specified{p_end}

{syntab :Table title}
{synopt :{cmdab:tabn:umber(}{it:text}{cmd:)}}display {it:text} as the table number before title and use to identify values in data file{p_end}
{synopt :{opt title(text)}}show {it:text} as title of table{p_end}
{synopt :{cmdab:addh:eader}} forces the normal header below altheader when {cmd:altheader} is specified                                   

{syntab :putdocx and putpdf}
{synopt :{opt land:scape}}change orientation to landscape{p_end}
{synopt :{opth font:(putdocx##fspec:fspec)}}set font, font size, and font color{p_end}
{synopt :{opt clear}}close document without saving{p_end}

{syntab :Advanced}
{synopt :{opt name(tablename[,append|replace])}}use {it:name} to refer to table{p_end}
{synopt :{cmdab:tableopt:ions(}{it:tableopts}{cmd:)}}specify additional {cmd:putdocx} or {cmd:putpdf} options{p_end}
	
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cortable} 
calculates summary statistics and creates a table based on variable properties.
{cmd:cortable} recognizes three classes of variable: binary, categorical, and
continuous. The variable class may either be declared by the user with 
{helpb corset define} or defaults are used given variable properties that exist in
metadata.

{pstd}
{cmd:cortable} archives a copy of the table contents to a dataset of
your choosing. This is particularly useful for comparing regular updates to
reports. The dataset archive can be optionally omitted.


{marker options}{...}
{title:Options}

{pstd}
Options are presented under the following headings:

	{help cortable##opts_cortable_storage:Main}
	{help cortable##opts_cortable_contents:Table contents}
	{help cortable##opts_cortable_header:Table header}
	{help cortable##opts_cortable_title:Table title}
	{help cortable##opts_cortable_putdocx:putdocx nad putpdf options}
	{help cortable##opts_cortable_advanced:Advanced}

{marker opts_cortable_storage}{...}
{dlgtab:Main}

{phang}
{cmd:saving(}{it:{help filename}}[{cmd:,} {cmd:replace} | {cmd:append}]{cmd:)}
specifies the name of the Word document to save the table to.  The {cmd:.docx}
extension is used by default. Remember to enclose the name in double quotation
marks if it contains spaces.  If {it:filename} already exists, it can be
overwritten by specifying {cmd:replace}.  Specifying the {opt append} option
will append the new table to the contents of the existing document
{it:filename}. 
{opt saving()} is required if you want to immediately save the table to Word. 

{phang}
{cmd:savedta(}{it:{help filename}}[{cmd:,} {cmd:replace} | {cmd:append}]{cmd:)}
specifies the name of the Stata dataset where statistics should be saved. The
{cmd:.dta} extension is used by default.  Remember to enclose the name in
double quotation marks if it contains spaces.  If the dataset already exists,
it can be overwritten by specifying {cmd:replace}.  
{opt savedta()} is required unless {opt omitdta} is specified.

{phang}
{opt omitdta} specifies that the dataset of statistics not be saved. {opt omitdta} 
is required unless {opt savedta()} is specified.

{phang}
{opt pdf} saves the table to a PDF using {cmd:putpdf}. Note that the available options for {cmd:tableoptions()}, {cmd:headerformat()}, and {cmd:altheader()} may differ because while {cmd:putpdf} and {cmd:putdocx}{cmd: share many options, they do not share all options.

{phang}
{opt docx} saves table to Word using {cmd:putdocx} (default).


{marker opts_cortable_contents}{...}
{dlgtab:Table contents}

{phang}
{cmd:colvars(}{it:{help varlist:colvarlist}}{cmd:)}
is a list of numeric variables or {it:{help fvvarlist:factor variables}}
for columns. These variables form the groups over which statistics on each row variable specified are calculated.

{phang}
{opt total} specifies that a total column be included as the first column of
statistics in the table. If no {it:colvarlist} is specified, a total is
included by default.

{phang}
{opt suppress(#)} changes the threshold for suppressing small cell sizes from
the default level of 5. 

{phang}
{opt na(text)} specifies alternate text that {cmd:cortable} should display when
a statistic is suppressed due to small cell size. The default value is
{cmd:n/a}. 

{phang}
{opt counts} requests a table containing the count of non-missing observations for each variable in {it:varlist}.

{phang}
{* {cmd:statistics(}{it:statname} [{it:...}]{cmd:)}}
{cmd:constat(}{it:statname} [{it:...}]{cmd:)}
specifies the statistics to be displayed for continuous variables; the
default is {cmd:msd}.  Available statistics are

{marker statname}{...}
{synoptset 17}{...}
{synopt:{space 4}{it:statname}}Definition{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt mean}}mean{p_end}
{synopt:{space 4}{opt sd}}standard deviation{p_end}
{synopt:{space 4}{opt msd}}mean with standard deviation (mean +/- s.d.){p_end}
{synopt:{space 4}{opt variance}}variance{p_end}
{synopt:{space 4}{opt skewness}}skewness{p_end}
{synopt:{space 4}{opt kurtosis}}kurtosis{p_end}
{synopt:{space 4}{opt median}}median (same as {opt p50}){p_end}
{synopt:{space 4}{opt mediqr}}median with interquartile range (med [IQR]){p_end}
{synopt:{space 4}{opt medqt}}median with 25th and 75th percentiles (med [p25, p75]){p_end}
{synopt:{space 4}{opt p1}}1st percentile{p_end}
{synopt:{space 4}{opt p5}}5th percentile{p_end}
{synopt:{space 4}{opt p10}}10th percentile{p_end}
{synopt:{space 4}{opt p25}}25th percentile{p_end}
{synopt:{space 4}{opt p50}}50th percentile (same as {opt median}){p_end}
{synopt:{space 4}{opt p75}}75th percentile{p_end}
{synopt:{space 4}{opt p90}}90th percentile{p_end}
{synopt:{space 4}{opt p95}}95th percentile{p_end}
{synopt:{space 4}{opt p99}}99th percentile{p_end}
{synopt:{space 4}{opt max}}maximum{p_end}
{synopt:{space 4}{opt min}}minimum{p_end}
{synopt:{space 4}{opt sum}}sum of the variable{p_end}
{synopt:{space 4}{opt sum_w}}sum of the weights{p_end}
{space 4}{synoptline}
{p2colreset}{...}

{marker opts_cortable_header}{...}
{dlgtab:Table header}

{phang}
{cmd:headerformat(}{it:{help putdocx##opts_cell_fmt_options:cell_fmt_options}}{cmd:)}
specifies valid {helpb putdocx} cell format options to be applied to the header row. 
If you have specified {cmd:pdf} the options {helpb putpdf} are described in {it:{help putpdf##opts_cell_fmt_options:cell_fmt_options}}.   See {mansection P putdocxOptions:Options} in {cmd:[P] putdocx} or {mansection P putpdfOptions:Options} in {cmd:[P] putpdf}  for additional
guidance.

{phang}
{cmd:altrowheader(}{it:text}{cmd:)}} specifies the text to show in place of 
the default row header. By default, {cmd:Characteristics} is used for the 
description of rows. 

{phang}
{opt altheader(text, opts)} replaces the first cell in the header row with {it:text}. Implies {cmd:noheader} unless {cmd:addheader} is used. 
{it:opts} can be either {it:{help putdocx##opts_cell_fmt_options:cell_fmt_options}} or {it:{help putdocx##opts_cell_options:cell_options}}. If {cmd:pdf} is specified see {it:{help putpdf##opts_cell_fmt_options:cell_fmt_options}} and {it:{help putpdf##opts_fmt_options:cell_options}}.
See !!examples for most common usage. 

{phang}	
{opt noheader} supresses the table header. 
                                                            
{phang}	
{opt addheader} places the usual header below the header specified using {cmd:altheader()}.

{marker opts_cortable_title}{...}
{dlgtab:Table title}

{phang}	
{cmd:tabnumber(}{it:text}{cmd:)} specifies the text to display as the table number. 
If {cmd:tabnumber()} is specfied {it:text} is displayed after {cmd:Table} {it:tabnumber}{cmd::} above the table. 
 
{phang}	 
{cmd:tabnumber(}{it:tabnumber} [,noprint]{cmd:)} The value specified in {it:tabnumber} serves two purposes, it is used to number the table in the document, and it identifies the table in the dataset written using the {cmd:savedta()} option. The value is most likely a number, but any value of 35 characters or less can be used. 

{phang2}{opt noprint} suppresses printing of {cmd:Table} {it:tabnumber}{cmd::} above the table, but will still use the {it:tabnumber} to identify the table in the saved data file.
 
{phang}	
{opt title(text)} causes {cmd:cortable} to include the specified text in the Word document above table as a title. 

{marker opts_cortable_putdocx}{...}
{dlgtab:putdocx options}

{phang}
The following subset of {helpb putdocx:putdocx begin} options are available for
use with {cmd:cortable}. 
See {mansection P putdocxOptions:Options} in {cmd:[P] putdocx} for additional
guidance.

{phang2}
{opt landscape} changes the document orientation from portrait to landscape.

{phang2:}
{cmd:font(}{it:{help putdocx##fontname:fontname}}[{cmd:,} {it:{help putdocx##size:size}}[{cmd:,} {it:{help putdocx##color:color}}]]{cmd:)}
sets the font, font size, and font color for the document.  Note that the font
size and font color may be specified individually without specifying
{it:fontname}.  Use {cmd:font("",} {it:size}{cmd:)} to specify font size only.
Use {cmd:font("", "",} {it:color}{cmd:)} to specify font color only.  For both
cases, the default font will be used.

{phang}
{opt clear} closes a previously started {cmd:.docx} file without saving the
changes. It is equivalent to using the {helpb putdocx:putdocx clear} command.

{marker opts_cortable_advanced}{...}
{dlgtab:Advanced}	

{phang}
{cmd:name(}{it:tname}[,append|replace]{cmd:)} specifies a name for the table. {it:tname} is used to refer to the table across multiple calls to {cmd:cortable}, or directly using {cmd:putdocx} or {cmd:putpdf}.  If {it:tname} already exists, it can be overwritten by specifying {cmd:replace}.  Specifying the {cmd:append} option will append the new rows to the bottom of the existing table. 

{phang}
{cmd:tableoptions(}{it:table_options}{cmd:)} additional {cmd:putdocx} or {cmd:putpdf} table options. This passes directly to putpdf/putdocx at table creation time. This must be specified when table is created, not when adding to table using repeated calls to {cmd:cortable}. One use for this option is to specify column widths. Another is to specify {cmd:memtable} to create subtables using {cmd:cortable} and then place them in a larger table. See {it:{help putdocx##opts_table_options:table_options}} for {helpb putdocx}, and {it:{help putpdf##opts_table_options:table_options}} for {helpb putpdf}.

{marker examples}{...}
{title:Examples}

{hline}
{p 2}
Write table of summary statistics to a word document

{cmd:. cortable age sex race, saving(mytable) savedta(tabledata) }

{p 2}
Add table number and title

{cmd:. cortable age sex race, saving(mytable) savedta(tabledata) ///}
{cmd:	tabnum(1) title(Demographic Information)}

{p 2}	
Include columns for region and total

{cmd:. cortable age sex race, saving(mytable) savedta(tabledata) ///}
{cmd:	colvar(region) total}

{hline}
{p 2}
Use repeated called to {cmd:cortable} to create a table with a spacing row 
between sets of variables

{cmd:. cortable age sex race, savedta(tabledata) ///}
{cmd:	tabnum(1) title(Demographic Information) colvar(region) total name(tab, replace) ///}
{cmd:	altheader("Demographic information", colspan(10)) addheader ///}
{cmd:	headerformat(bold halign(left) shading(, , pct15))}

{cmd:. cortable bpsystol bpdiast diabetes, saving(mytable) savedta(tabledata, append) ///}
{cmd:	colvar(region) total name(tab, append) ///}
{cmd:	altheader("Health information", colspan(10)) ///}
{cmd:	headerformat(bold halign(left) shading(, , pct15))}

{hline}
{title:Author} 

{p 4 4 2}
Rose Medeiros {break}
Corrona, LLC {break}
rmedeiros@corrona.org

{p 4 4 2}
Rebecca Raciborski {break}
Corrona, LLC {break}
rraciborski@corrona.org

{title:Also see}

{p 4 13 2}
Online:  help for 
{browse "https://www.stata.com/manuals15/rsummarize.pdf#rsummarize":summarize}{break} 
{browse "https://www.stata.com/manuals15/pputdocx.pdf#pputdocx":putdocx}{break}
{browse "https://www.stata.com/manuals15/pputpdf.pdf#pputpdf":putpdf} 
{p_end}

