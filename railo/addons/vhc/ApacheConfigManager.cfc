<cfcomponent output="no" extends="VHostsConfigManager">
<!---
/*
 * ApacheConfigManager.cfc, developed by Paul Klinkenberg
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
--->	

	<cffunction name="getVHostsFromHTTPDFile" access="public" returntype="array" output="no">
		<cfargument name="file" type="string" required="yes" hint="Path to an httpd file" />
		<cfset var VHosts = [] />
		<cfset var httpdContents = fileRead(arguments.file) />
		<cfset var qConfFiles = "" />
		<cfset var subIncludeFilePath = "" />
		<cfset var regexFoundPos = "" />
		<cfset var mainIncludeFilePath = "" />
		<cfset var relativeIncludeFilePath = "" />
		<cfset var includeFileContents = "" />
		<cfset var loopcounter2 = 0 />
		<cfset var line = "" />
		<cfset var ipList = "" />
		<cfset var VHostData = "" />
		<cfset var hostAliases = "" />
		<cfset var ali = "" />
		
		<!--- include all include files --->
		<cfset var includeLineRegex = '[\r\n][ \t]*(Include[[:space:]]+[''"]?([^##\r\n\t''"]+))' />
		<cfset var loopcounter = 0 />
		<cfloop condition="refind(includeLineRegex, httpdContents)">
			<cfif ++loopcounter gt 50>
				<cfset handleError(msg="Infinite loop seems to occur with the following filecontent:#chr(13)##httpdContents#", type="fatal") />
			</cfif>
			
			<cfset regexFoundPos = refind(includeLineRegex, httpdContents, 1, true) />
			<cfset relativeIncludeFilePath = mid(httpdContents, regexFoundPos.pos[3], regexFoundPos.len[3]) />
			<!--- clean the path, and change the include file path to an absolute path --->
			<cfset mainIncludeFilePath = getCleanedAbsPath(relativeIncludeFilePath, arguments.file) />
			
			<!--- I just found out, 12 hours after I thought I was ready to release this code to the public,
			that httpd.conf takes the apache-install-dir as root directory for any incudes.
			So, if httpd.conf is located at C:/Apache/conf/httpd.conf, then it will have 
			Include conf/extra/httpd-vhosts.conf, instead of just extra/httpd-vhosts.conf.
			Since I'm starting to get irritated, I will just go one directory deeper, since that will match most situations.
			Edit: since Includes can also have the format "Include /bla/bla/*.conf", I will check this too. --->
			<cfif not fileExists(mainIncludeFilePath)
			and (not findNoCase('*.', mainIncludeFilePath) or not directoryExists(GetDirectoryFromPath(mainIncludeFilePath)))>
				<cfset relativeIncludeFilePath = "../" & relativeIncludeFilePath />
				<cfset mainIncludeFilePath = getCleanedAbsPath(relativeIncludeFilePath, arguments.file) />
			</cfif>
			<cfif fileExists(mainIncludeFilePath)
			or (findNoCase('*.', mainIncludeFilePath) and directoryExists(GetDirectoryFromPath(mainIncludeFilePath)))>
				<!--- Since the include directive allows for "Include /dir/*.conf", we'll do a dir listing --->
				<cfdirectory action="list" directory="#getdirectoryFromPath(mainIncludeFilePath)#" filter="#listLast(mainIncludeFilePath, '/\')#" name="qConfFiles" sort="name" />
				
				<!--- now read the include file(s) --->
				<cfset includeFileContents = "" />
				<cfloop query="qConfFiles">
					<cfset includeFileContents &= "## #qConfFiles.directory#/#qConfFiles.name#:" & chr(10) & fileRead(qConfFiles.directory & "/" & qConfFiles.name) & chr(10) & "## END #qConfFiles.directory#/#qConfFiles.name#" & chr(10) />
				</cfloop>
				<cfif not len(includeFileContents)>
					<cfset includeFileContents = "## THE FILE #mainIncludeFilePath# DOES NOT EXIST!" />
				</cfif>
				
				<!--- change relative Include paths in the content to absolute ones --->
				<cfset loopcounter2 = 0 />
				<cfloop condition="refind(includeLineRegex, includeFileContents)">
					<cfif ++loopcounter2 gt 50>
						<cfset handleError(msg="Infinite loop seems to occur with the following filecontent (main file=#mainIncludeFilePath#):#chr(13)##includeFileContents#", type="fatal") />
					</cfif>
					<cfset regexFoundPos = refind(includeLineRegex, includeFileContents, 1, true) />
					<cfset subIncludeFilePath = mid(includeFileContents, regexFoundPos.pos[3], regexFoundPos.len[3]) />
					<cfset subIncludeFilePath = getCleanedAbsPath(subIncludeFilePath, mainIncludeFilePath) />
			
					<cfset includeFileContents = rereplace(includeFileContents, includeLineRegex & "[^\r\n]*", "#chr(10)#REMOVETHESEWORDS Include #replace(subIncludeFilePath, '\', '/', 'all')#") />
				</cfloop>
				<cfset includeFileContents = replace(includeFileContents, "REMOVETHESEWORDS Include", "Include", "all") />
				
				<!--- now insert the retrieved Includes' file contents into the http contents --->
				<cfset httpdContents = rereplace(httpdContents, includeLineRegex & "[^\r\n]*", "#chr(10)### THE CONTENTS OF \1 HAS BEEN INCLUDED UNDERNEATH HERE#chr(10)#ADD-SUB-CONTENTS-HERE-8291543056278252165") />
				<cfset httpdContents = replace(httpdContents, "ADD-SUB-CONTENTS-HERE-8291543056278252165", includeFileContents) />
			<cfelse>
				<cfset handleError(msg="In the httpd.conf file, the Include path '#mainIncludeFilePath#' does not exist?!", type="fatal") />
			</cfif>
		</cfloop>
		
		<!--- temp debugging --->
		<cfset fileWrite('parsed-httpd.txt', httpdContents) />
		
		<!--- now that we have all content, let's clean it --->
		<cfset httpdContents = cleanApacheConfFile(httpdContents) />
		<cfoutput><pre>#htmleditformat(httpdContents)#</pre></cfoutput>
		
		<!--- If VHosts is not turned on --->
		<cfif not refindNoCase("(^|\n)[[:space:]]*NameVirtualHost[[:space:]]", httpdContents)>
			<!--- not turned on, so only get the default directory for the default (and only) site --->
			<cfset var defaultWebroot = rereplace(httpdContents, "(.*\n|^)[\t ]*DocumentRoot[\t ]+['""]?([^\n##""']+).*", "\2") />
			<!--- no webroot found! --->
			<cfif defaultWebroot eq httpdContents>
				<cfset handleError(msg="The httpd.conf file does not have any webroot setup! #httpdContents#", type="fatal") />
			</cfif>
	
			<cfset arrayAppend(VHosts, createVHostContainer(path=defaultWebroot)) />
			<cfreturn VHosts />
		</cfif>
		
		<!--- get the Apache ServerRoot, so we can calculate any relative DocumentRoots--->
		<cfset var serverRoot = rereplace(httpdContents, "(.*\n|^)ServerRoot ([^##\n]+)(\n.*|$)", "\2") />
		<cfif ServerRoot eq httpdContents>
			<cfset serverRoot = "" />
			<cfset handleError(msg="No ServerRoot was found in httpd.conf", type="WARNING") />
		<cfelse>
			<cfset serverRoot = rereplace(serverRoot, "['""]", "", "all") & "/" />
		</cfif>
		<cfset var VHostContainerRegex = "<VirtualHost.*?</VirtualHost>" />
		<cfset var lastFoundPos = 1 />
		<cfset var VHostContainer = "" />
		<cfloop condition="refind(VHostContainerRegex, httpdContents, lastFoundPos)">
			<cfset regexFoundPos = refind(VHostContainerRegex, httpdContents, lastFoundPos, true) />
			<cfset VHostContainer = mid(httpdContents, regexFoundPos.pos[1], regexFoundPos.len[1]) />
			<cfset lastFoundPos = regexFoundPos.pos[1] + 1 />
			<!--- put all directives on a new line --->
			<cfset VHostContainer = rereplace(VHostContainer, "(<VirtualHost[^>]+>)([^\n]+)", "\1#chr(10)#\2") />
			<cfset VHostContainer = rereplace(VHostContainer, "([^\n]+)(</VirtualHost>)", "\1#chr(10)#\2") />
			<!--- get settings within the container: servername, documentroot, serveralias --->
			<cfset VHostData = {aliases={}, mappings={}} />
			<cfoutput><pre>#HTMLEditFormat(VHostContainer)#</pre></cfoutput>
			<cfloop list="#VHostContainer#" delimiters="#chr(10)#" index="line">
				<cfif findNoCase("ServerName ", line) eq 1>
					<cfset VHostData.host = listFirst(rereplace(trim(listRest(line, " ")), "['""]", "", "all"), ':') />
				<cfelseif findNoCase("ServerAlias ", line) eq 1>
					<cfloop list="#listRest(line, ' ')#" index="ali" delimiters=" ">
						<cfset VHostData.aliases[listFirst(rereplace(ali, "['""]", "", "all"), ':')] = "" />
					</cfloop>
				<cfelseif findNoCase("Alias ", line) eq 1>
					<cfset var mappingAlias = trim(rereplace(listRest(line, " "), "^(['""])(.*?)\1", "\2")) />
					<cfif mappingAlias eq trim(listRest(line, " "))>
						<cfset mappingAlias = listFirst(listRest(line, " "), " ") />
					</cfif>
					<cfset var mappingPath = trim(rereplace(listRest(line, " "), "(['""])(.*?)(['""]) ?$", "\2")) />
					<cfif mappingPath eq trim(listRest(line, " "))>
						<cfset mappingPath = listLast(trim(listRest(line, " ")), " ") />
					</cfif>
					<cfset VHostData.mappings[mappingAlias] = mappingPath />
				<cfelseif findNoCase("DocumentRoot ", line) eq 1>
					<cfset VHostData.path = rereplace(trim(listRest(line, " ")), "['""]", "", "all") />
					<cfset VHostData.path = getCleanedAbsPath(VHostData.path, serverRoot) />
				</cfif>
			</cfloop>
			<!--- now create a VHost for every ip (or *) in the <virtualhost> tag
			Examples:
			<VirtualHost *:80>
			<VirtualHost 172.20.30.50>
			<VirtualHost 192.168.1.1 172.20.30.40>
			<VirtualHost 172.20.30.40:80>
			<VirtualHost *:*>
			<VirtualHost _default_:*>
			 --->
			<cfset ipList = rereplace(VHostContainer, ".*<VirtualHost([^>]+)>.+", "\1") />
			<cfloop list="#iplist#" delimiters=" " index="line">
				<cfset VHostData.ip = "" />
				<cfset VHostData.port = "" />
				<!--- ipv6? --->
				<cfif find("[", line) eq 1>
					<cfset VHostData.ip = rereplace(line, '\].*', ']') />
					<cfif find(']:', line)>
						<cfset VHostData.port = listLast(line, ':') />
					</cfif>
				<cfelse>
					<cfif find(':', line)>
						<cfset VHostData.port = listLast(line, ':') />
					</cfif>
					<cfif not listFind("*,_default_", listFirst(line, ':'))>
						<cfset VHostData.ip = listFirst(line, ':') />
					</cfif>
				</cfif>
				<cfset arrayAppend(VHosts, createVHostContainer(argumentCollection=VHostData)) />
			</cfloop>
		</cfloop>
		<cfreturn VHosts />
	</cffunction>


	<cffunction name="cleanApacheConfFile" access="public" returntype="string" output="no">
		<cfargument name="text" type="string" required="yes" />
		<cfset var httpdContents = rereplace(arguments.text, "[\r\n]+", chr(10), "all") />
		<cfset httpdContents = rereplace(httpdContents, "[ \t]+", " ", "all") />
		<cfset httpdContents = rereplace(httpdContents, "\n( ?\n)+", chr(10), "all") />
		<cfset httpdContents = rereplace(httpdContents, "\n ", chr(10), "all") />
		<cfset httpdContents = rereplace(httpdContents, "\n* ?##[^\n]*", "", "all") />
		<cfreturn httpdContents />
	</cffunction>
	
	
</cfcomponent>