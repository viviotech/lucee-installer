<cfcomponent output="no">
<!---
/*
 * DirectoryListener.cfc, developed by Paul Klinkenberg
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
	
	<cfset variables.webserver2TomcatVHostCopier = createObject("component", "Webserver2TomcatVHostCopier") />
	
	<!--- Make sure that we do the copy action on start-up --->
	<cfset startWebserver2TomcatVHostCopier( data:{} ) />
	
	<cffunction name="startWebserver2TomcatVHostCopier" access="public" returntype="void">
    	<cfargument name="data" type="struct" required="yes" />
		<cfset variables.webserver2TomcatVHostCopier.copyWebserverVHosts2Tomcat() />
	</cffunction>
	
</cfcomponent> 