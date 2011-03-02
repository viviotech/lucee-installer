<cfsilent>

	<cfset funcArray = GetSupportedTags( "" )>
	<cfset firstChar	= "">
	<cfset cols = 0>

	<cfset request.page.title = "All CFML Tags">

</cfsilent>
<h1>All CFML Functions</h1>

<p>CFML comes with a very rich pre-defined set of tags that are available for immediate use within CFML pages and CFC components.</p>

<cfoutput>
<table class="functionTable">
<tr>
<cfloop index="x" from="1" to="#ArrayLen(funcArray)#"><cfif Len(funcArray[x]) == 2><cfcontinue></cfif>
	<cfif funcArray[x].charAt(2) != firstChar><cfset firstChar = funcArray[x].charAt(2)><cfset cols = 0><tr><td colspan="5"><div class="letter">#firstChar#</div></td></tr></cfif>
	<td><a href="./?/tag/#funcArray[ x ]#">#application.docs.getCamelCase( funcArray[ x ] )#</a></td>
	<cfset cols++><cfif cols mod 5 eq 0></tr><tr><cfset cols = 0></cfif></cfloop>
</tr>
</table>
</cfoutput>