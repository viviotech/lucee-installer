<cfsilent>
	<cfset request.page.section = "tags">

	<cfset url.tag	= request.params[2]>

	<cfset tagInfo = GetEngineTagInfo( url.tag )>
	<cfset request.page.title = "#UCase(url.tag)#">

	<cfset desc = Left( tagInfo.summary, 200 )>
	<cfset desc = Replace( desc, Chr(13), "", "ALL" )>
	<cfset request.page.desc = "#UCase(url.tag)# :: #XmlFormat(desc)#">


</cfsilent>
<style>
span.inparam {
	color: maroon;
}

span.paramDetail{
	color: #808080;
}

span.optional{
	font-style:italic
}

span.return {
	color: blue;
}

.row {
	margin-bottom: 30px;
}

.row h3 {
	line-height: inherit;
}
</style>

<cfoutput>

<h1>#UCase(url.tag)#</h1>

<ul class="breadcrumb">
	<li><a href="./?/tag/">CFML Tags</a> <span class="divider">/</span></li>
	<li><a href="./?/tag/category/#tagInfo.category#" style="text-transform:capitalize">#tagInfo.category# Category</a> <span class="divider">/</span></li>
	<li class="active">&lt; #UCase(url.tag)# &gt;</li>
</ul>


<div class="row">
	<div class="span2">
	<h3>Description</h3>
	</div>
	<div class="span14">
		<p>#XmlFormat(tagInfo.summary)#</p>
	</div>
</div>


<div class="row">
	<div class="span2">
		<h3>Usage</h3>
	</div>

	<div class="span14">
		<code>&lt;#url.tag#&gt; <cfif tagInfo.endtag>... &lt;/#url.tag#&gt;</cfif></code>
	</div>
</div>


<cfif ArrayLen(tagInfo.attributes) != 0>

<div class="row">
	<div class="span2">
		<h3>Attributes</h3>
	</div>
	<div class="span14">
		<table>
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
	</div>
</div>
</cfif>



<cfif tagInfo.category neq "unknown">
<div class="row">
	<div class="span2">
	<h3>See Also</h3>
	</div>
	<div class="span14">
		<cfset funcArray = GetSupportedTags( tagInfo.category )>
		<div class="usage">
			<cfloop array="#funcArray#" index="func"><a href="./?/tag/#func#">#func#</a> &nbsp; </cfloop>
		</div>
	</div>
</div>
</cfif>



<cfset codeSnippet = ExpandPath( "./pages/tagcode/#LCase(url.tag)#.inc" )>
<cfif FileExists(codeSnippet)>
<div class="row">

	<div class="span2">
		<h3>Extra</h3>
	</div>

	<cfset contents = FileRead( codeSnippet )>
	<cfset contents = Replace(contents,"<cf", "&lt;cf", "all")>
	<cfset contents = Replace(contents,"</cf", "&lt;/cf", "all")>
	<cfset contents = Replace(contents,"<!---", "&lt;!---", "all")>
	<cfset contents = Replace(contents, Chr(9), "  ", "all")>
	<div class="span14">#contents#</div>
</div>
</cfif>

</cfoutput>