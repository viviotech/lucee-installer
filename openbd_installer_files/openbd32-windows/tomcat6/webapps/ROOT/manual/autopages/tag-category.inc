<cfsilent>

	<cfset funcArray = GetSupportedTags( url.category )>
	<cfset request.page.title = "#url.category# Tags">

</cfsilent>

<h1><cfoutput>#url.category#</cfoutput> tags</h1>

<p>The following tags all belong to the <cfoutput>#url.category#</cfoutput> category.</p>

<table width="90%" align="center" cellpadding="5" cellspacing="0">
<cfoutput><cfloop array="#funcArray#" index="func"><cfsilent>
	<cfset funcMeta = GetEngineTagInfo( func )>
</cfsilent><tr>
	<td width="1%" nowrap align="right"><a href="./?/tag/#func#">#func#</a></td>
	<td>#XmlFormat(funcMeta.summary)#</td>
</tr></cfloop>
</cfoutput>
</table>