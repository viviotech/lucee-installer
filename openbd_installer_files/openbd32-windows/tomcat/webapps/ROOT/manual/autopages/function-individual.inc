
<cfset func = GetEngineFunctionInfo( url.function )>
<cfset request.page.title = "#application.docs.getCamelCase( url.function )#()">

<h1><cfoutput>#application.docs.getCamelCase( url.function )#() - OpenBD CFML Function</cfoutput></h1>

<div class="functionSummary">
	<cfoutput>
	<p>#XmlFormat(func.summary)#</p>
	</cfoutput>
</div>

<div class="functionUsage">
	<p><strong>Usage: </strong></p>
	<div class="usage">
	<cfoutput>
	<span class="return">#func.return#</span> = #application.docs.getCamelCase( url.function )# (
	<cfloop index="p" from="1" to="#func.max#">
		<cfif p LTE func.min>
			p#p#<cfif p LT func.max>, </cfif>
		<cfelseif p GT func.min>
			<span class="optional">p#p#<cfif p LT func.max>, </cfif></span>
		</cfif>
	</cfloop>
	)</span>

	<cfif func.max gt 0>
		<table style="margin-top: 20px;">
		<cfloop index="p" from="1" to="#func.max#">
		<tr>
			<td valign="top"><strong>p#p#: &nbsp;</strong></td>
			<td valign="top">#func.params[p]#</td>
		</tr>
		</cfloop>
		</table>
	</cfif>

	</cfoutput>
	</div>
</div>


<cfif func.category neq "unknown">
	<div class="functionUsage" style="font-size:85%">
		<cfset funcArray = GetSupportedFunctions( func.category )>

		<cfoutput>
		<p><strong>Other functions from: <a href="./?/function/category/#func.category#">#func.category#</a></strong></p>
		<div class="usage">
			<cfloop array="#funcArray#" index="func">
			<a href="./?/function/#func#">#application.docs.getCamelCase(func)#</a> &nbsp; </cfloop>
		</div>
		</cfoutput>
	</div>
</cfif>



<cfset codeSnippet = ExpandPath( "./pages/functioncode/#LCase(url.function)#.inc" )>
<cfif FileExists(codeSnippet)>
<div class="functionUsage">
	<p><strong>Code Sample:</strong></p>
	<cfset contents = FileRead( codeSnippet )>
	<cfset contents = Replace(contents,"<cf", "&lt;cf", "all")>
	<cfset contents = Replace(contents,"</cf", "&lt;/cf", "all")>
	<cfset contents = Replace(contents,"<!---", "&lt;!---", "all")>
	<cfset contents = Replace(contents, Chr(9), "  ", "all")>
	<cfoutput>#contents#</cfoutput>
</div>
</cfif>
