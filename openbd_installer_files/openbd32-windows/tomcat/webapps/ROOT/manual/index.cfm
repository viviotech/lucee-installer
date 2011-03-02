<cfsilent>

	<!--- Determine the page we are looking for --->
	<cfset pageName = cgi.QUERY_STRING>
	<cfif pageName.startsWith("/")>
		<cfset pageName = LCase( pageName.substring(1) )>
	</cfif>

	<cfset pageTemplate = "pages/index.inc">


	<cfif pageName != "">
		<cfset topLevel = ListGetAt( pageName, 1, "/")>

		<cfif topLevel == "function">
			<cfset secondLevel = ListGetAt( pageName, 2, "/")>

			<cfif secondLevel == "all">
				<cfset pageTemplate = "autopages/function-all.inc">
			<cfelseif secondLevel == "category">
				<cfset url.category = ListGetAt( pageName, 3, "/")>
				<cfset pageTemplate = "autopages/function-category.inc">
			<cfelse>
				<cfset url.function	= ListGetAt( pageName, 2, "/")>
				<cfset pageTemplate = "autopages/function-individual.inc">
			</cfif>

		<cfelseif topLevel == "tag">
			<cfset secondLevel = ListGetAt( pageName, 2, "/")>

			<cfif secondLevel == "all">
				<cfset pageTemplate = "autopages/tag-all.inc">
			<cfelseif secondLevel == "category">
				<cfset url.category = ListGetAt( pageName, 3, "/")>
				<cfset pageTemplate = "autopages/tag-category.inc">
			<cfelse>
				<cfset url.tag	= ListGetAt( pageName, 2, "/")>
				<cfset pageTemplate = "autopages/tag-individual.inc">
			</cfif>

		<cfelse>
			<cfset pageTemplate = "pages/" & pageName & ".inc">
		</cfif>

	</cfif>


	<cftry>
		<cfsavecontent variable="page"><cfinclude template="#pageTemplate#"></cfsavecontent>
	<cfcatch>
		<cfset page = "<p>This page has not yet been written.</p><p>We would love to receive your contribution if you would like to help pen this section.</p>">
	</cfcatch>
	</cftry>

</cfsilent><cfinclude template="_header.inc">

<cfoutput>#page#</cfoutput>

<cfinclude template="_footer.inc">