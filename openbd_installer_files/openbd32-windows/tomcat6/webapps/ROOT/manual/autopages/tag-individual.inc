
<cfset tagInfo = GetEngineTagInfo( url.tag )>
<cfset request.page.title = "#UCase(url.tag)#">

<h1><cfoutput>#UCase(url.tag)# - OpenBD CFML Function</cfoutput></h1>


<div class="functionSummary">
	<cfoutput><p>#XmlFormat(tagInfo.summary)#</p></cfoutput>
</div>

<div class="functionUsage">
	<p><strong>Usage: </strong></p>
	<div class="usage">
	<cfoutput>
	<span class="return">&lt;#url.tag#&gt; <cfif tagInfo.endtag>... &lt;/#url.tag#&gt;</cfif></span>

	<cfif ArrayLen(tagInfo.attributes) gt 0>
		<table style="margin-top: 20px; color: black; border:1px solid silver;" border="1" cellpadding="6" cellspacing="0">
		<tr>
			<th>attribute</th>
			<th>default</th>
			<th>required</th>
			<th>summary</th>
		</tr>
		<cfloop index="p" array="#tagInfo.attributes#">
		<tr>
			<td valign="top">#p.name#</td>
			<td valign="top">#p.default#</td>
			<td valign="top">#p.required#</td>
			<td valign="top">#p.summary#</td>
		</tr>
		</cfloop>
		</table>
	</cfif>

	</cfoutput>
	</div>
</div>

<cfif tagInfo.category neq "unknown">
	<div class="functionUsage" style="font-size:85%">
		<cfset funcArray = GetSupportedTags( tagInfo.category )>

		<cfoutput>
		<p><strong>Other functions from: <a href="./?/tag/category/#tagInfo.category#">#tagInfo.category#</a></strong></p>
		<div class="usage">
			<cfloop array="#funcArray#" index="func"><a href="./?/tag/#func#">#func#</a> &nbsp; </cfloop>
		</div>
		</cfoutput>
	</div>
</cfif>


<cfset codeSnippet = ExpandPath( "./pages/tagcode/#LCase(url.tag)#.inc" )>
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
