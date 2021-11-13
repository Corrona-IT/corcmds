{smcl}
{* *! version 1.0.2  06jul2020}{...}
{vieweralsosee "[D] net" "help d_net"}{...}
{vieweralsosee "[R] adoupdate" "help r_adoupdate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] Glossary" "help d_glossary"}{...}
{viewerjumpto "Description" "corrona##description"}{...}
{viewerjumpto "Getting and maintaining commands" "corrona##get"}{...}
{viewerjumpto "Documentation" "corrona##documentation"}{...}
{viewerjumpto "Data management" "corrona##data"}{...}
{viewerjumpto "Tables" "corrona##tables"}{...}
{hline}
{cmd:help corrona}{right:Utility commands for Corrona Biostats}
{hline}

{marker description}{...}
{title:Description}

{pstd}
The {cmd:corrona} suite of commands is a collection of internally-developed
utilities to increase productivity in the Biostatistics department. This help
file provides a reference to all currently-availabe commands along with
instructions for how to develop and maintain them.


{marker get}{...}
{title:Getting and maintaining commands}

{p 2 4 2}{it:Configuration}

{pstd}
Before you can install any new {bf:corrona} commands, you need to correctly
configure your installation settings.  Verify your settings by typing

{p 8 30 2}
{cmd:. net query}

{pstd}
which should show you 

{p 8 8 8}
{cmd:from    "https://raw.githubusercontent.com/Corrona-IT/corcmds/master"}
{break}
{cmd:ado     c:\ado\plus\}{break}
{cmd:other   (current directory)}

{pstd}
You only need to do these steps once unless you change your {cmd:net} settings.  

{p 2 4 2}{it:Getting commands}

{pstd}
The Corrona commands are installed using the {helpb net} command from the 
Biostatistics SharePoint site. You set the install location by typing

{p 8 30 2}
{cmd:. net from "https://raw.githubusercontent.com/Corrona-IT/corcmds/master"}

{pstd}
You set the location for installing the {cmd:corrona} commands by typing

{p 8 30 2}
{cmd:. net set ado PLUS}

{pstd}
Short descriptions of each {cmd:corrona} command are displayed below. To view a
complete description, including the command's help file, you can click the link
that appears when you type {cmd:net describe}.


{p 2 4 2}{it:Maintaining commands}

{pstd}
The {cmd:corrona} commands are periodically updated with improvements and bug
fixes.  As with all user-written commands, the {cmd:corrona} suite is not
updated automatically when you {helpb update} Stata. You must make sure that
you maintain the commands yourself. To do this, use the {helpb adoupdate}
command periodically. 

{p 8 30 2}
{cmd:. adoupdate} 


{title:Available commands}

{pstd}{marker documentation}{...}
    {it:Documentation}

{p 8 30 2}
{helpb cordd}{space 10}Create data dictionary{p_end}


{pstd}{marker data}{...}
    {it:Data management}

{p 8 30 2}{helpb corcf}{space 10}Compare values of variables between two
datasets{p_end}

{p 8 30 2}{helpb corset}{space 9}Set variable properties for table automation{p_end}


{pstd}{marker tables}{...}
    {it:Tables}

{p 8 30 2}{helpb cortable}{space 7}Create formatted tables in Word{p_end}


{title:Author} 

{pstd}
Paul R. Lakin {break}
CorEvitas, LLC {break}
plakin@corevitas.com
{p_end}
