<cfcomponent output="no" extends="VHostsConfigManager">
<!---
/*
 * IISConfigManager.cfc, developed by Paul Klinkenberg
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


	<cfset variables.config = getConfig() />


	<cffunction name="getVHostsFromIIS7File" access="public" returntype="array" output="no">
		<cfargument name="file" type="string" required="yes" hint="Optional path to IIS7 applicationHost.config file"
			default="%systemroot%\System32\inetsrv\config\applicationHost.config" />
		<cfset var VHosts = [] />
		<cfset var IISFileContents = fileRead(getAbsPath(arguments.file)) />
		<cfset var binding = "" />
		<cfset var key = "" />
		<cfset var xmlIndex = -1 />
		<cfset var xmlChild = "" />
		<cfset var bindingIndex = -1 />
		<!--- clean the xml file a bit --->
		<cfset var IISFileXML = xmlParse(IISFileContents) />
		<cfset var sitesXML = xmlSearch(IISFileXML, "//system.applicationHost/sites/") />
		<cfif not arrayLen(sitesXML)>
			<cfset handleError(msg="No virtual sites are found in IIS7. Do you have any sites setup yet? The xml search path was '//system.applicationHost/sites/'; the config file '#arguments.file#'.", type="WARNING") />
			<cfreturn [] />
		</cfif>
		<cfset sitesXML = sitesXML[1] />
		<cfloop from="1" to="#arraylen(sitesxml.xmlchildren)#" index="xmlIndex">
			<cfset xmlChild = sitesxml.xmlChildren[xmlIndex] />
			<cfif xmlChild.xmlName eq "site">
				<!--- get root directory --->
				<cfset var VHostPath = xmlSearch(xmlChild, "./application/virtualDirectory[@path='/']/")[1].xmlAttributes.physicalPath />
				<!--- get mappings (including the root directory, which is not a mapping...) --->
				<cfset var mappingsXML = xmlSearch(xmlChild, "./application/virtualDirectory/") />
				<cfset var mappings = {} />
				<cfset var mappingIndex = -1 />
				<cfloop from="1" to="#arrayLen(mappingsXML)#" index="mappingIndex">
					<cfif mappingsXML[mappingIndex].xmlAttributes.path neq "/">
						<cfset mappings[mappingsXML[mappingIndex].xmlAttributes.path] = mappingsXML[mappingIndex].xmlAttributes.physicalPath />
					</cfif>
				</cfloop>
				<cfset var bindings = xmlSearch(xmlChild, ".//binding/") />
				<cfset var VHostPortAndIPLookup = {} />
				<!--- create one VHost per same port+ip ('binding' is a combination of IP+port+hostname) --->
				<cfloop from="1" to="#arrayLen(bindings)#" index="bindingIndex">
					<cfif listFindNoCase("http,https", bindings[bindingIndex].xmlAttributes.protocol)>
						<cfset var bindingElements = listToArray(bindings[bindingIndex].xmlAttributes.bindingInformation, ":", true) />
						<cfset var ipAndPort = bindingElements[1] &":"& bindingElements[2] />
						<cfif not structKeyExists(VHostPortAndIPLookup, ipAndPort)>
							<cfset VHostPortAndIPLookup[ipAndPort] = {host=bindingElements[3], aliases={}} />
						<cfelse>
							<cfset VHostPortAndIPLookup[ipAndPort].aliases[bindingElements[3]] = "" />
						</cfif>
					</cfif>
				</cfloop>
				<cfloop collection="#VHostPortAndIPLookup#" item="key">
					<cfset arrayAppend(VHosts, createVHostContainer(
						  path=VHostPath
						, host=VHostPortAndIPLookup[key].host
						, aliases=VHostPortAndIPLookup[key].aliases
						, port=rereplace(key, '^[^:]*:', '')
						, ip=rereplace(key, ':.*$', '')
						, mappings=mappings)) />
				</cfloop>
			</cfif>
		</cfloop>
		<cfreturn VHosts />	
	</cffunction>
<!---<?xml version="1.0" encoding="UTF-8"?>
<sites>
	<site id="1" name="Default Web Site">
		<application path="/">
			<virtualDirectory path="/" physicalPath="%SystemDrive%\inetpub\wwwroot" />
			<virtualDirectory path="/aliastest" physicalPath="C:\whatever" />
		</application>
		<bindings>
			<binding bindingInformation="*:80:" protocol="http"/>
		</bindings>
	</site>
	<site id="2" name="pietfriet.nl">
		<application applicationPool="pietfriet.nl" path="/">
			<virtualDirectory path="/" physicalPath="C:\sqldata"/>
		</application>
		<bindings>
			<binding bindingInformation="*:80:pietfriet.nl" protocol="http"/>
			<binding bindingInformation="*:80:test.pietfriet.nl" protocol="http"/>
			<binding bindingInformation="*:890:poort890.pietfriet.nl" protocol="http"/>
		</bindings>
	</site>
	<site id="3" name="ipadrestest">
		<application applicationPool="ipadrestest" path="/">
			<virtualDirectory path="/" physicalPath="c:\Freelang Dictionary"/>
		</application>
		<bindings>
			<binding bindingInformation="10.211.55.5:80:ipadres1.test.com" protocol="http"/>
		</bindings>
	</site>
	<siteDefaults>
		<logFile directory="%SystemDrive%\inetpub\logs\LogFiles" logFormat="W3C"/>
		<traceFailedRequestsLogging directory="%SystemDrive%\inetpub\logs\FailedReqLogFiles"/>
	</siteDefaults>
	<applicationDefaults applicationPool="DefaultAppPool"/>
	<virtualDirectoryDefaults allowSubDirConfig="true"/>
</sites>
--->	
	
	<cffunction name="getVHostsFromIIS6File" access="public" returntype="array" output="no">
		<cfargument name="file" type="string" required="yes" hint="Optional path to IIS6 metabase.xml file"
			default="%systemroot%\System32\inetsrv\Metabase.xml" />
		<cfset var VHosts = [] />
		<cfset var IISFileContents = fileRead(getAbsPath(arguments.file)) />
		<cfset var binding = "" />
		<cfset var key = "" />
		
		<!--- clean the xml file a bit --->
		<cfset IISFileContents = rereplace(IISFileContents, "<\!--.*?-->", "", "all") />
		
		<cfset var stFoundPos = "" />
		<cfset var lastFoundPos = 1 />
		<cfset var iiswebserverTag = "" />
		<cfset var iiswebserverRegex = "<IIsWebServer[^>]+>" />
<!---<IIsWebServer	Location ="/LM/W3SVC/1551821403"
		ServerBindings=":80:awstats.site.com
			:80:awstats.site.nl"
		ServerComment="awstats.site.com">--->		
		<cfloop condition="refind(iiswebserverRegex, IISFileContents, lastfoundpos)">
			<cfset stFoundPos = refind(iiswebserverRegex, IISFileContents, lastfoundpos, true) />
			<cfset lastfoundpos = stFoundPos.pos[1] + 1 />
			<cfset iiswebserverTag = mid(IISFileContents, stFoundPos.pos[1], stFoundPos.len[1]) />
			<cfset var iiswebserverTagXML = xmlParse(rereplace(iiswebserverTag, '>$', '/>')) />
			<!--- in IIS6, there is an administration website listening for any host on port 80999.
			We need to skip that one, because it isn't a 'real' site.--->
			<cfif structKeyExists(iiswebserverTagXML.xmlRoot.XMLattributes, "serverBindings")
			and iiswebserverTagXML.xmlRoot.XMLattributes.serverBindings neq ":8099:">
				<cfset var VHostIISPathName = iiswebserverTagXML.xmlRoot.XmlAttributes.Location />
				<!--- get path: is located in <IIsWebVirtualDir	Location ="/LM/W3SVC/1551821403/root"
				AppRoot="/LM/W3SVC/1551821403/Root" Path="D:\www\awstats.xitesystem.com\data">--->
				<cfset var VHostPath = rereplaceNoCase(IISFileContents, '.*<IIsWebVirtualDir[^>]*[[:space:]]Location[[:space:]]*=[[:space:]]*"#VHostIISPathName#/root"[^>]*[[:space:]]Path[[:space:]]*=[[:space:]]*"([^"]+)".*', "\1") />
				<cfif VHostPath eq IISFileContents>
					<cfset handleError(msg="Web root for IIS site could not be found. Current VHost: #rereplace(iiswebserverTag, '[\r\n]+', ' ', 'all')##chr(13)#Filecontent:#chr(13)##IISFileContents#", type="fatal") />
				</cfif>
				<!--- get the mappings --->
				<!---<IIsWebVirtualDir	Location ="/LM/W3SVC/15500/Root/aliastest/aliasinalias" ...
				Path="C:\dell\"></IIsWebVirtualDir> --->
				<cfset var mappingRegex = '<IIsWebVirtualDir[[:space:]][^>]*Location[[:space:]]*=[[:space:]]*"#VHostIISPathName#/Root(/[^"]+)"[^>]*[[:space:]]Path[[:space:]]*=[[:space:]]*"([^"]+)"' />
				<cfset var lastMappingFoundIndex = 1 />
				<cfset var mappings = {} />
				<cfset var loopCounter = 0 />
				<cfloop condition="refindNoCase(mappingRegex, IISFileContents, lastMappingFoundIndex)">
					<cfset var mappingFoundPos = refindNoCase(mappingRegex, IISFileContents, lastMappingFoundIndex, true) />
					<cfset lastMappingFoundIndex = mappingFoundPos.pos[1] + 1 />
					<cfset mappings[mid(IISFileContents, mappingFoundPos.pos[2], mappingFoundPos.len[2])] = mid(IISFileContents, mappingFoundPos.pos[3], mappingFoundPos.len[3]) />
					<cfif ++loopCounter gt 50>
						<cfset handleError(msg="An infinite loop seems to occur in fnc getVHostsFromIIS6File(), where the Mappings are to be retrieved.", type="fatal") />
					</cfif>
				</cfloop>
				
				<cfset var VHostPortAndIPLookup = {} />
				<!--- create one VHost per same port+ip ('binding' is a combination of IP+port+hostname) --->
				<cfloop list="#iiswebserverTagXML.xmlRoot.XMLattributes.ServerBindings#" index="binding" delimiters=" #chr(9)##chr(10)##chr(13)#">
					<cfset var bindingElements = listToArray(binding, ":", true) />
					<cfset var ipAndPort = bindingElements[1] &":"& bindingElements[2] />
					<cfif not structKeyExists(VHostPortAndIPLookup, ipAndPort)>
						<cfset VHostPortAndIPLookup[ipAndPort] = {host=bindingElements[3], aliases={}} />
					<cfelse>
						<cfset VHostPortAndIPLookup[ipAndPort].aliases[bindingElements[3]] = "" />
					</cfif>
				</cfloop>
				<cfloop collection="#VHostPortAndIPLookup#" item="key">
					<cfset arrayAppend(VHosts, createVHostContainer(
						  path=VHostPath
						, host=VHostPortAndIPLookup[key].host
						, aliases=VHostPortAndIPLookup[key].aliases
						, port=rereplace(key, '^[^:]*:', '')
						, ip=rereplace(key, ':.*$', '')
						, mappings=mappings)) />
				</cfloop>
			</cfif>
		</cfloop>
		<cfreturn VHosts />
	</cffunction>
	
	
</cfcomponent>