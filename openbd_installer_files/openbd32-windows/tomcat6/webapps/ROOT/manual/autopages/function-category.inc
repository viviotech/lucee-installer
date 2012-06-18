<cfsilent>

	<cfset funcArray = GetSupportedFunctions( url.category )>
	<cfset request.page.title = "#url.category# Functions">

</cfsilent>

<h1><cfoutput>#url.category#</cfoutput> functions</h1>

<p>The following functions all belong to the <cfoutput>#url.category#</cfoutput> category.</p>

<table width="90%" align="center" cellpadding="5" cellspacing="0">
<cfoutput><cfloop array="#funcArray#" index="func"><cfsilent>
	<cfset funcMeta = GetEngineFunctionInfo( func )>
</cfsilent><tr>
	<td width="1%" nowrap align="right"><a href="./?/function/#func#">#application.docs.getCamelCase( func )#</a></td>
	<td>#XmlFormat(funcMeta.summary)#</td>
</tr></cfloop>
</cfoutput>
</table>