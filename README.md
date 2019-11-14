<h1>Utility commands for Corrona Biostats</h1>

The <b>corrona</b> suite of commands is a collection of internally-developed
utilities to increase productivity in the Biostatistics department. This help
file provides a reference to all currently-availabe commands along with
instructions for how to develop and maintain them.

<h2>Getting and maintaining commands</h2>

<p><i>Configuration</i></p>
<p>Before you can install any new <b>corrona</b> commands, you need to correctly
configure your installation settings.  Verify your settings by typing </p>

<code>. net query</code>

<p>which should show you</p>
<pre>
from    "~/Corrona LLC/Rebecca Raciborski - PsO Development/dev/cmd/</code>
ado     c:\ado\plus\</code>
other   (current directory)
</pre>

<p>You only need to do these steps once unless you change your <b>net</b> settings.</p>

<i>Getting commands</i>

The Corrona commands are installed using the <b>net</b> command from the 
Biostatistics SharePoint site. You set the install location by typing

<code>. net from "~/Corrona LLC/Rebecca Raciborski - PsO Development/dev/cmd/"</code>

You set the location for installing the <b>corrona</b> commands by typing

<code>. net set ado PLUS</code>

Short descriptions of each <b>corrona</b> command are displayed below. To view a
complete description, including the command's help file, you can click the link
that appears when you type <b>net describe</b>.

<i>Maintaining commands</i>

The <b>corrona</b> commands are periodically updated with improvements and bug
fixes.  As with all user-written commands, the <b>corrona</b> suite is not
updated automatically when you <b>update</b> Stata. You must make sure that
you maintain the commands yourself. To do this, use the <b>adoupdate</b>
command periodically. 

<code>. adoupdate</code>

<h2>Available commands</h2>

<p><i>Documentation</i></p>
<ul>
<item><b>cordd</b>: Create data dictionary</item>
</ul>

<p><i>Data management</i></p>
<ul>
<item><b>corcf</b>: Compare values of variables between two datasets</item>
  
<item><b>corset</b>: Set properties</item>
</ul>

<p><i>Tables</i></p>
<ul>
<item><b>cortable</b>: create formatted tables in Word</item>
</ul>
