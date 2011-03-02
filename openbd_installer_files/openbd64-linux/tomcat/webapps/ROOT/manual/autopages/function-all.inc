<cfsilent>

	<cfset funcArray = GetSupportedFunctions( "" )>
	<cfset firstChar	= "">
	<cfset cols = 0>

	<cfset request.page.title = "All CFML Functions">

</cfsilent>
<h1>All CFML Functions</h1>

<p>CFML comes with a very rich pre-defined set of functions that are available for immediate use within tags and script blocks.</p>

<cfoutput>
<table class="functionTable">
<tr>
<cfloop index="x" from="1" to="#ArrayLen(funcArray)#">
	<cfif funcArray[x].charAt(0) != firstChar><cfset firstChar = funcArray[x].charAt(0)><cfset cols = 0><tr><td colspan="5"><div class="letter">#firstChar#</div></td></tr></cfif>
	<td><a href="./?/function/#funcArray[ x ]#">#application.docs.getCamelCase( funcArray[ x ] )#</a></td>
	<cfset cols++><cfif cols mod 5 eq 0></tr><tr><cfset cols = 0></cfif></cfloop>
</tr>
</table>
</cfoutput>