<cfcomponent output="no">
<!---
/*
 * VHostsConfig.cfc, developed by Paul Klinkenberg
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

	<cfset variables.errorMailTo = "paul@ongevraagdadvies.nl" />
	<cfset variables._sendCriticalErrors = true />
	
	
	<cffunction name="init" returntype="any" access="public" output="no">
		<!--- zero or more arguments --->
		<cfset var key = "" />
		<cfloop collection="#arguments#" item="key">
			<cfif structKeyExists(this, "set#key#")>
				<cfset this["set#key#"](arguments[key]) />
			</cfif>
		</cfloop>
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getConfig" access="public" returntype="struct">
		<cfset var stConfig = {} />
		<cfset var line = "" />
		<cfloop file="config.conf" index="line">
			<cfset line = trim(line) />
			<cfif listlen(line, '=') gt 1>
				<cfset stConfig[listFirst(line, '=')] = listRest(line, '=') />
			</cfif>
		</cfloop>
		<cfreturn stConfig />
	</cffunction>
	
	
	<cffunction name="handleError" access="public" returntype="void">
		<cfargument name="msg" type="string" required="yes" />
		<cfargument name="type" type="string" required="no" default="WARNING" />
		<cfset var cflogfilename = "VHostCopier" />
		
		<cflog file="#cflogfilename#" type="#arguments.type#" text="#arguments.msg#" />
		
		<!--- CRITICAL? Abort the operation, and optionally send debug mail --->
		<cfif arguments.type eq "FATAL">
			<cfif variables._sendCriticalErrors>
				<!--- check how many mails have been sent in the meanwhile --->
				<cfset var mailsSentCounterFile = "mailsSentCounter.txt" />
				<cfif fileExists(mailsSentCounterFile)>
					<cfset var numMailsSent = int(fileRead(mailsSentCounterFile)) />
				<cfelse>
					<cfset var numMailsSent = 0 />
				</cfif>
				<cfif numMailsSent lt 20>
					<cfset fileWrite(mailsSentCounterFile, ++numMailsSent) />
					
					<cfmail to="#variables.errorMailTo#" from="#variables.errorMailTo#" subject="VHostParser error" type="html">
						Date: #now()#<br />
						<cfdump var="#getConfig()#" label="config" />
						<cfdump eval=arguments />
						<cfif isDefined("form")>
							<cfdump var="#form#" label="form data" />
						</cfif>
					</cfmail>
					<cfoutput>Debug mail for this critical error has been sent to the developer<br /></cfoutput>
				<cfelse>
					<cflog file="#cflogfilename#" type="WARNING"
						text="The maximum amount of debug mails has been reached. No mail was sent." />
				</cfif>
			</cfif>
			<cfoutput><p style="color:red;">CRITICAL ERROR: #msg#</p>
				<p><em>aborting the request</em></p>
			</cfoutput>
			<cfabort />
		</cfif>
	</cffunction>
	
	
	<cffunction name="setSendCriticalErrors" returntype="void" access="public" output="no">
		<cfargument name="sendCriticalErrors" type="boolean" required="yes" />
		<cfset variables._sendCriticalErrors = arguments.sendCriticalErrors />
	</cffunction>
	
	
</cfcomponent>