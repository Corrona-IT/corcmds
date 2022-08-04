<h1>Utility commands for Corrona Biostats</h1>

The <b>corrona</b> suite of commands is a collection of internally-developed
utilities to increase productivity in the Biostatistics department. 

<p>These commands should not be used by those not employed by or affiliated 
with CorEvitas LLC. Attempting to use them on non-CorEvitas resources without
permission will result in an error or invalid results.</p>

<h2>Available commands</h2>

<p><i>Documentation</i></p>
<ul>
<item><b>cordd</b>: Create data dictionary</item>
</ul>

<p><i>Data management</i></p>
<ul>
<item><b>corcf</b>: Compare values of variables between two datasets</item>
  
<item><b>corset</b>: Set properties of variables for tabling</item>
</ul>

<p><i>Tables</i></p>
<ul>
<item><b>cortable</b>: create formatted tables in Word</item>
</ul>

<h2>Getting and maintaining commands</h2>

<p><i>Configuration</i></p>
<p>Before you can install any new <b>corrona</b> commands, you need to correctly
configure your installation settings.</p>

<p>Verify your settings by typing </p>

<code>. net query</code>

<p>which should show you</p>
<pre>
from    "https://raw.githubusercontent.com/Corrona-IT/corcmds/master"
ado     c:\ado\plus\
other   (current directory)
</pre>

<p>If it does not, follow the appropriate steps below for configuring your 
  installation. Otherwise, skip to the <i>Getting commands</i> section.</p> 

<i>Configuring installation</i>

If your <b>ado</b> path does not show as 

<code>c:\ado\plus</code>(Windows)<br>
<code>~/ado/plus  </code>(Mac)

You need to change the installation location. You set the location for installing 
the <b>corrona</b> commands by typing

<code>. net set ado PLUS</code>

The Corrona commands are installed using the <b>net</b> command. To change the 
location the commands are downloaded from, 

<code>. net from "https://raw.githubusercontent.com/Corrona-IT/corcmds/master" </code>

<i>Getting commands</i>

To install the commands, you can click the "corrona" link that appears when you
type the <code>net from</code> command above and then click the install link
in the help file. Alternately, you can install the full package of Corrona commands by typing

<code>. net install corrona</code>

Short descriptions of each <b>corrona</b> command are displayed above. To view
a complete description, including the command's help file, you can click the
link that appears when you type <b>net describe</b>.

<i>Maintaining commands</i>

The <b>corrona</b> commands are periodically updated with improvements and bug
fixes.  As with all user-written commands, the <b>corrona</b> suite is not
updated automatically when you <b>update</b> Stata. You must make sure that
you maintain the commands yourself. To do this, use the <b>adoupdate</b>
command periodically. 

<code>. adoupdate</code>

<h2>Getting help</h2>

All <b>corrona</b> commands come with help files. If you run into a specific problem, 
see the <i>Troubleshooting</i> section below. If you encounter a bug that is not already 
described, please report it by creating a 
<a href=https://github.com/Corrona-IT/corcmds/issues>new issue</a>.

<h2>Troubleshooting</h2>

<i>Unable to change installation directory</i>

<p>You do not need to use the <code>net set</code> command unless you see something
  other than the listed <b>plus</b> directory for your OS. If you try, you may get a
  message that Stata is not able to change the directory. There are two known causes
  of this error.
  <ol>
    <li>The appropriate plus directory does not yet exist on your 
      computer. Solve this by creating the directory.</li>
    <li>You do not have administrator privelages to the ado directory. 
      Please contact IT to resolve this issue.</li>
   </ol>
   
<i>Files exist already</i>

<p>If you previously helped with the testing of these commands, you may have copies 
  in your personal directory or you may have copies in plus that conflict with the 
  versions installed from the official distribution location. Make sure you delete any
  copies in your personal directory and, if you get an error about conflicts, follow
  the prompts to force installation (or specify the <b>force</b> option if you use
  the <code>net install</code> command instead of clicking through the links).</p>
  
 <i>Integrity check error</i>
 
<p>If you receive an integrity check error, the most likely cause is that you do not 
  have permissions for the commands. There are three ways to resolve this: </p>
  <ol>
  <li>Ensure you have a valid OneDrive account through Corrona that is syncing
    on your computer. This is the same location you use when sending links to
    attachments via Outlook instead of the attachment itself.</li>
  <li>Sync to any of the registry data locations on SharePoint.</li>
  <li>Open a <a href=https://github.com/Corrona-IT/corcmds/issues>new issue</a>
    showing the results of listing Corrona directories as
    well as your user name. Attach the log that is created by the following
    to the issue that you create.
    <pre>
log using myinfo.txt, text replace
ls ~/*Corrona*
display "`c(username)'"
log close</pre>
   </li>
 </ol>
 

 

