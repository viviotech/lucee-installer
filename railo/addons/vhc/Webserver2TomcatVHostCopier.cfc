<cfcomponent output="no">
<!---
/*
 * Webserver2TomcatVHostCopier.cfc, developed by Paul Klinkenberg
 * http://www.railodeveloper.com/post.cfm/apache-iis-to-tomcat-vhost-copier-for-railo
 *
 * Date: 2011-04-19 17:57:00 +0100
 * Revision: 0.4.01
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

	<cffunction name="copyWebserverVHosts2Tomcat" access="public" returntype="void" output="yes">
		<cfargument name="testOnly" type="boolean" required="no" default="false" />
		<cfargument name="sendCriticalErrors" type="boolean" required="no" default="true" />
		<cflock name="copyWebserverVHosts2Tomcat" timeout="5" throwontimeout="no">
			<cftry>
				<cfset var tomcatConfigManager = createObject("component", "TomcatConfigManager").init(sendCriticalErrors=arguments.sendCriticalErrors) />
				<!---  log the fact that we're running this function --->
				<cfset tomcatConfigManager.handleError(msg="Function copyWebserverVHosts2Tomcat called", type="Information") />
				<cfset var parserConfig = tomcatConfigManager.getConfig() />
				<!---  server.separator.file is not available when file is used as a gateway listener :-( --->
				<cfset var sep = find("\", expandPath('/somedir/')) ? "\":"/" />
				
				<!--- apache --->
				<cfif parserConfig.webservertype eq "apache">
					<cfset var apacheConfigManager = createObject("component", "ApacheConfigManager").init(sendCriticalErrors=arguments.sendCriticalErrors) />
					<!--- get all Vhosts from Apache--->
					<cfset var VHosts = apacheConfigManager.getVHostsFromHTTPDFile(file=parserConfig.httpdfile) />
				<!--- IIS6 --->
				<cfelseif parserConfig.webservertype eq "IIS6">
					<cfset var IISConfigManager = createObject("component", "IISConfigManager").init(sendCriticalErrors=arguments.sendCriticalErrors) />
					<!--- for testing, get the config file from a different location --->
					<cfif structKeyExists(parserConfig, "IIS6File")>
						<cfset var VHosts = IISConfigManager.getVHostsFromIIS6File(parserConfig.IIS6File) />
					<cfelse>
						<cfset var VHosts = IISConfigManager.getVHostsFromIIS6File() />
					</cfif>
				<!--- IIS7 --->
				<cfelseif parserConfig.webservertype eq "IIS7">
					<cfset var IISConfigManager = createObject("component", "IISConfigManager").init(sendCriticalErrors=arguments.sendCriticalErrors) />
					<!--- for testing, get the config file from a different location --->
					<cfif structKeyExists(parserConfig, "IIS7File")>
						<cfset var VHosts = IISConfigManager.getVHostsFromIIS7File(parserConfig.IIS7File) />
					<cfelse>
						<cfset var VHosts = IISConfigManager.getVHostsFromIIS7File() />
					</cfif>
				<cfelse>
					<cfset tomcatConfigManager.handleError(msg="Webserver type '#parserConfig.webservertype#' is not yet implemented in the VHostParser. Only one of the following is allowed: IIS6, IIS7, Apache", type="fatal") />
					<cfreturn />
				</cfif>
			
				<!--- The Vhosts array which we have now, is very detailed. It has entries for every ip+port+host+webroot.
				This means that we can have the same hostname+webroot multiple times, but listening on different ips or ports.
				Since the tomcat config does not need this/ can not handle this, we will simplify the VHosts here.
				Also, a check will be done to see if the same hostname is used with multiple webroots. This cannot be dealt with by tomcat. --->
				<cfset var tomcatVHosts = {} />
				<cfset var duplicates = [] />
				<cfset var stVHost = "" />
				<cfset var hostname = "" />
				<cfloop array="#VHosts#" index="stVHost">
					<cfloop list="#iif(not len(stVHost.host), de('__allhostnames__'), 'stVHost.host')#,#structKeyList(stVHost.aliases)#" index="hostname">
						<cfif structKeyExists(tomcatVHosts, hostname) and rereplace(stVHost.path, '[/\\]$', '') neq rereplace(tomcatVHosts[hostname].path, '[/\\]$', '')>
							<cfif hostname eq "__allhostnames__">
								<cfset arrayAppend(duplicates, "        More then one website found which listens to all hostnames, with different webroots! Since tomcat does not distuingish between listener ip addresses, we can not handle this exception! Path1=#tomcatVHosts[hostname].path#, path2=#stVHost.path#") />
							<cfelse>
								<cfset arrayAppend(duplicates, "        Same host found twice, with different webroots! Host=#hostname#, path1=#tomcatVHosts[hostname].path#, path2=#stVHost.path#") />
							</cfif>
						<cfelse>
							<cfset structInsert(tomcatVHosts, hostname, {path=stVHost.path, mappings=stVHost.mappings}, true) />
						</cfif>
					</cfloop>
				</cfloop>
				
				<!--- if we found a host named 'localhost', and a '__allhostnames__', then we have a problem. --->
				<cfif structKeyExists(tomcatVHosts, "__allhostnames__")>
					<cfif structKeyExists(tomcatVHosts, "localhost")>
						<cfset arrayAppend(duplicates, "        Both a host 'localhost' and a website 'listening to all hostnames' was found. Since tomcat is configured to use 'localhost' as the default webhost, we have a problematic situation, which this tool can't fix. localhost=#tomcatVHosts['localhost'].path#, __allhostnames__=#tomcatVHosts['__allhostnames__'].path#") />
						<cfset structDelete(tomcatVHosts, "localhost") />
					</cfif>
					<cfset tomcatVHosts['localhost'] = tomcatVHosts['__allhostnames__'] />
					<cfset structDelete(tomcatVHosts, '__allhostnames__') />
				</cfif>
				
				<!--- do we have a localhost entry?
				If not, we default it to the tomcat root at {tomcat-install}/webapps/ROOT/ --->
				<cfif not structKeyExists(tomcatVHosts, "localhost")>
					<cfset var tomcatWebrootPath = rereplace(parserConfig.tomcatrootpath, '[\\/]$', '') & "#sep#webapps#sep#ROOT#sep#" />
					<cfset structInsert(tomcatVHosts, "localhost", {path=tomcatWebrootPath, mappings={}}, true) />
				</cfif>
				
				<!---did we find duplicates? Log it.--->
				<cfif arrayLen(duplicates)>
					<cfset tomcatConfigManager.handleError("One or more duplicate hosts with different webroots were found in #parserConfig.webservertype#. This tool can not handle this.#chr(10)##arrayToList(duplicates, chr(10))#", "WARNING") />
				</cfif>
			
				<!--- check if there are VHost changes --->
				<cfset var stChangedVHosts = tomcatConfigManager.getChangedHosts(tomcatVHosts) />
				<cfif not structIsEmpty(stChangedVHosts)>
					<cfset var temp = "" />
					<cfsavecontent variable="temp">
						Changed hosts (and/or mappings): 
						<cfset var host = "" />
						<cfloop collection="#stChangedVHosts#" item="host">
							<br /> - #UCase(stChangedVHosts[host])#: #host#
							<cfif stChangedVHosts[host] neq "deleted" and not structIsEmpty(tomcatVHosts[host].mappings)>
								(mappings: <cfloop collection="#tomcatVHosts[host].mappings#" item="key">
									#key#=#tomcatVHosts[host].mappings[key]# &nbsp;
								</cfloop>)
							</cfif>
						</cfloop>
					</cfsavecontent>
					#temp#
					<br /><br />
					<cfset tomcatConfigManager.handleError(rereplace(temp, '(<.*?>| &nbsp;|[\r\n\t])+', chr(10), 'all'), "information") />
					
					<!--- create the xml text with the VHosts for tomcat --->
					<cfset var VHostsText = tomcatConfigManager.createTomcatVHosts(tomcatVHosts) />
					
					The xml to write to tomcat:
					<cfoutput><pre>#HTMLEditFormat(VHostsText)#</pre></cfoutput>
					
					<cfif arguments.testOnly>
						TEST-ONLY, so nothing will be written to tomcat. Exiting now.
						<cfreturn />
					</cfif>
					
					<!--- write/change the VHost context data for tomcat (delteion comes later on) --->
					<cfset var key = "" />
					<cfloop collection="#stChangedVHosts#" item="key">
						<cfif stChangedVHosts[key] eq "new" or stChangedVHosts[key] eq "changed">
							<cfset tomcatConfigManager.writeContextXMLFile(host=key, path=tomcatVHosts[key].path, mappings=tomcatVHosts[key].mappings) />
						</cfif>
					</cfloop>
					
					<!--- overwrite the tomcat VHosts --->
					<cfset tomcatConfigManager.overwriteVHostSettings(VHostsText) />
					
					All files have been written<br /><br />
					
					<!--- now de/activate the new and deleted hosts by using the Tomcat host-manager --->
					<cfset var tomcatHostManager = createObject("component", "TomcatHostManager").init(sendCriticalErrors=arguments.sendCriticalErrors) />
					<cfloop collection="#stChangedVHosts#" item="key">
						<cfif stChangedVHosts[key] eq "new">
							<cfset tomcatHostManager.addHost(key) />
							<cfoutput>Added host #key#</cfoutput> with the tomcat host-manager<br /><br />
							<cfflush />
						<cfelseif stChangedVHosts[key] eq "changed">
							<!--- no need to do anything; the new xml file will be picked up automatically by tomcat --->
						<cfelseif stChangedVHosts[key] eq "deleted">
							<cfset tomcatHostManager.removeHost(key) />
							<cfoutput>Removed host #key#</cfoutput> with the tomcat host-manager<br /><br />
							<cfflush />
						</cfif>
					</cfloop>
				
					<!--- delete the obsolete VHost context data for tomcat --->
					<cfloop collection="#stChangedVHosts#" item="key">
						<cfif stChangedVHosts[key] eq "deleted">
							<cfset tomcatConfigManager.removeContextXMLFile(host=key) />
						</cfif>
					</cfloop>
					
					<!--- save the current vhost settings --->
					<cfset tomcatConfigManager.saveCurrentVHosts(tomcatVHosts) />
					
					Data saved to tomcat. Done.
				<cfelse>
					<cfset tomcatConfigManager.handleError("No changes in the VHosts", "information") />
					No changes in the VHosts.
				</cfif>
				<cfcatch>
					<cfset var debugdata = "" />
					<cfsavecontent variable="debugdata">
						Date: #now()#<br />
						<!---<cfdump var="#parserConfig#" label="parserConfig" />--->
						<cfdump var="#arguments#" label="args" />
						<cfdump var="#cfcatch#" label="error data" />
					</cfsavecontent>
					<cfif arguments.sendCriticalErrors>
						<!--- check how many mails have been sent in the meanwhile --->
						<cfset var mailsSentCounterFile = "mailsSentCounter.txt" />
						<cfif fileExists(mailsSentCounterFile)>
							<cfset var numMailsSent = int(fileRead(mailsSentCounterFile)) />
						<cfelse>
							<cfset var numMailsSent = 0 />
						</cfif>
						<cfif numMailsSent lt 10>
							<cfset fileWrite(mailsSentCounterFile, ++numMailsSent) />
							<cfmail to="paul@ongevraagdadvies.nl" from="paul@ongevraagdadvies.nl" subject="Webserver2Tomcat dirwatcher error" type="html">
								#debugdata#
							</cfmail>
						</cfif>
					</cfif>
					<cffile action="write" file="dirwatcher-error.html" output="#debugdata#" />
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cflock>
	</cffunction>
	
</cfcomponent>