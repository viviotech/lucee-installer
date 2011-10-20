<!---
/*
 * test.cfm, developed by Paul Klinkenberg
 * http://www.railodeveloper.com/post.cfm/apache-iis-to-tomcat-vhost-copier-for-railo
 *
 * Date: 2011-05-26 23:10:00 +0100
 * Revision: 0.5.01
 *
 * Copyright (c) 2011 Paul Klinkenberg, Ongevraagd Advies
 * Licensed under the GPL license.
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *    ALWAYS LEAVE THIS COPYRIGHT NOTICE IN PLACE!
 */
---><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Webserver2Tomcat VHost Copier test page</title>
	<style type="text/css">
		body { font-size:12px; font-family:Verdana, Geneva, sans-serif; }
		pre { background-color:#eee; padding:5px; width:auto; max-height:150px; overflow:auto; border:1px solid #000; }
		h1, h2, h3 { padding: 6px 0px 6px 15px; background-color:#CCC; margin:25px 0px 10px 0px; }
	</style>
</head>
<body>
	<h1>Test page for the Webserver2TomcatVHostCopier</h1>
	<p><em>If you encounter any errors which are not already sent by email, and also if everything went smoothly, please mail <a href="mailto:paul@ongevraagdadvies.nl">Paul Klinkenberg</a> about it, or add a comment to</em>
		<a href="http://www.railodeveloper.com/post.cfm/apache-iis-to-tomcat-vhost-copier-for-railo" target="_blank" title="Opens in new window">http://www.railodeveloper.com/post.cfm/apache-iis-to-tomcat-vhost-copier-for-railo</a>
	</p>
	<cfif structKeyExists(form, "configdata")>
		<cftry>
			<h3>Your parsing results</h3>
			<!--- delete the old log file --->
			<cfif fileExists('parserLog.log')>
				<cfset fileDelete('parserLog.log') />
				<em>parser log was cleared</em><br /><br />
			</cfif>
			<!--- write the new configuration to disk --->
			<cfset fileWrite('config.conf', form.configdata) />
			<!--- can we send debug data to the developer? --->
			<cfset variables.emailErrors = structKeyExists(form, "sendErrorsToPaul") />
			<!--- call the copier, but only to test the config --->
			<cfset createObject("component", "Webserver2TomcatVHostCopier").copyWebserverVHosts2Tomcat(testOnly=true, sendCriticalErrors=variables.emailErrors) />
			
			<br />--&gt; Don't forget to look at the parser log underneath this page!
			
			<!--- error occured? --->
			<cfcatch>
				<h3 style="color:red;">An error occured :-(</h3>
				<cfif structKeyExists(form, "sendErrorsToPaul")>
					<cfmail to="paul@ongevraagdadvies.nl" from="paul@ongevraagdadvies.nl" subject="Webserver2Tomcat error at #cgi.http_host#" type="html">
						Date: #now()#<br />
						<cfdump var="#form#" label="form data" />
						<cfdump var="#cfcatch#" label="error data" />
						<cfdump var="#cgi#" label="cgi vars" />
					</cfmail>
					<p>A mail about this has been sent to the developer</p>
				<cfelse>
					<p>NO mail has been sent. But it would be great if you could let me know if something in the code went wrong.</p>
				</cfif>
				<cfdump var="#cfcatch#" abort />
			</cfcatch>
		</cftry>
	</cfif>
	
	<h3>Test the parsing of your webserver configuration</h3>
	<p>Please edit the following config file, and then press "TEST". Also see the requirements underneath this page.</p>
	
	<form method="post" action="test.cfm">
		<label for="sendErrorsToPaul"><input id="sendErrorsToPaul" type="checkbox" name="sendErrorsToPaul" value="1" checked="checked" />
			Send errors to the developer for debugging purposes?
		</label><br />
		<textarea cols="60" rows="8" name="configdata"><cfif fileExists('config.conf')><cfoutput>#fileRead('config.conf')#</cfoutput></cfif></textarea>
		<br /><input type="submit" value="TEST" />
	</form>
	
	<h3>Example configuration</h3>
	<pre>webservertype=Apache (or IIS6 or IIS7)
httpdfile=/private/etc/apache2/httpd.conf
Windowsroot=C:\windows\</pre>
	<em>(which lines are actually used depends on the first line, 'webservertype')</em>
	
	<h3>Parser log</h3>
	<cfif fileExists('parserLog.log')>
		<cfoutput><textarea cols="100" rows="8">#fileRead('parserLog.log')#</textarea></cfoutput>
	<cfelse>
		<em>no log created</em>
	</cfif>

	<h3>Requirements</h3>
	<ul>
		<li>The tomcat hostmanager must be enabled and running. Check this by going to http://localhost:8080/host-manager/html (or your own custom tomcat port)</li>
		<li>You must have a valid user for the host-manager: add or edit the file {tomcat installation directory}/conf/tomcat-users.xml to contain the following:<br />
			&lt;tomcat-users&gt;&lt;role rolename=&quot;manager&quot;/&gt;&lt;role rolename=&quot;admin&quot;/&gt;&lt;user name=&quot;SOME NAME&quot; password=&quot;SOME PASSWORD&quot; roles=&quot;admin,manager&quot;/&gt;&lt;/tomcat-users&gt;</li>
		<li>createObject() function must be allowed (not sandboxed)</li>
		<li>&lt;cfinvoke&gt; tag must be allowed (not sandboxed)</li>
		<li>Railo must have read access to the Apache or IIS config files (you will supply the paths in the next step, so you will know what paths to allow)</li>
		<li>Railo must have write access to Tomcat's server.xml file</li>
	</ul>
</body>
</html>