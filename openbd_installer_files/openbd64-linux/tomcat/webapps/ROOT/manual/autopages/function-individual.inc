<cfsilent>

	<cfset url.function = request.params[2]>

	<cfset func = GetEngineFunctionInfo( url.function )>
	<cfset request.page.title 	= "#application.docs.getCamelCase( url.function )#()">
	<cfset request.page.section = "functions">

	<cfset desc = Left( func.summary, 200 )>
	<cfset desc = Replace( desc, Chr(13), "", "ALL" )>
	<cfset request.page.desc = "#application.docs.getCamelCase( url.function )#() :: #XmlFormat(desc)#">

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

<h1>#application.docs.getCamelCase( url.function )#()</h1>

<ul class="breadcrumb">
	<li><a href="./?/function/">CFML Functions</a> <span class="divider">/</span></li>
	<li><a href="./?/function/category/#func.category#" style="text-transform:capitalize">#func.category# Category</a> <span class="divider">/</span></li>
	<li class="active">#application.docs.getCamelCase( url.function )#()</li>
</ul>


<div class="row">
	<div class="span2">
	<h3>Description</h3>
	</div>
	<div class="span14">
		<p>#XmlFormat(func.summary)#</p>
	</div>
</div>


<div class="row">
	<div class="span2">
		<h3>Usage</h3>
	</div>

	<div class="span14">
		<div class="usage">
		<code><span class="return">#func.return#</span> = #application.docs.getCamelCase( url.function )# (
		<cfloop index="p" from="1" to="#func.max#">
			<cfif !func.namedparamsupport><cfset paramName = "p" & p><cfelse><cfset paramName = func.namedparams[p]></cfif>
			<cfif (p <= func.min)>
				<span class="inparam">#paramName#<cfif (p < func.max)>, </cfif></span>
			<cfelseif (p > func.min)>
				<span class="inparam optional">#paramName#<cfif (p < func.max)>, </cfif></span>
			</cfif>
		</cfloop>
		)</span></code>

		<cfif (func.max > 0)>
			<table style="margin-top: 20px;">
			<cfloop index="p" from="1" to="#func.max#">
				<cfif !func.namedparamsupport><cfset paramName = "p" & p><cfelse><cfset paramName = func.namedparams[p]></cfif>
			<tr>
				<td valign="top"><span class="paramDetail">#paramName# &nbsp;</span></td>
				<td valign="top">#func.params[p]# <cfif (p > func.min)>[optional]</cfif></td>
			</tr>
			</cfloop>
			</table>
		</cfif>
		</div>
	</div>
</div>


<cfif func.namedparamsupport>
<div class="row">

	<div class="span2">
		<h3>Calling</h3>
	</div>

	<div class="span7">
		<p>Supports <a href="./?/language_tagsfunctions##namedparams">named-parameter calling</a> allowing you to use the function like:</p>
		<pre class="cfml" style="font-size: 100%;">#application.docs.getCamelCase( url.function )#(
<cfloop index="p" from="1" to="#func.max#">   #func.namedparams[p]#=?<cfif (p < func.max)>, </cfif>
</cfloop>);</pre>
	</div>

	<div class="span7">
		<p>Supports passing parameters as a structure using <strong>ArgumentCollection</strong>:</p>
		<pre class="cfml" style="font-size: 100%;">#application.docs.getCamelCase( url.function )#( ArgumentCollection={
<cfloop index="p" from="1" to="#func.max#">   #func.namedparams[p]# : ?<cfif (p < func.max)>, </cfif>
</cfloop>} );</pre>
	</div>

</div>
</cfif>


<cfif func.category != "unknown">
<div class="row">

	<div class="span2">
		<h3>See Also</h3>
	</div>

	<div class="span14">
		<div class="usage" style="font-size: 95%;">
			<cfset funcArray = GetSupportedFunctions( func.category )>
			<cfloop array="#funcArray#" index="func">
			<a href="./?/function/#func#">#application.docs.getCamelCase(func)#</a> &nbsp; </cfloop>
		</div>
	</div>
</div>

</cfif>


<cfset codeSnippet = ExpandPath( "./pages/functioncode/#LCase(url.function)#.inc" )>
<cfif FileExists(codeSnippet)>
<div class="row">

	<div class="span2">
		<h3>Extra</h3>
	</div>

	<div class="span14">
	<cfset contents = FileRead( codeSnippet )>
	<cfset contents = Replace(contents,"<cf", "&lt;cf", "all")>
	<cfset contents = Replace(contents,"</cf", "&lt;/cf", "all")>
	<cfset contents = Replace(contents,"<!---", "&lt;!---", "all")>
	<cfset contents = Replace(contents, Chr(9), "  ", "all")>
	#contents#
	</div>

</div>
</cfif>

<cfif url.function.startsWith("mongo")>
<div class="row">

	<div class="span2">
		<h3>Extra</h3>
	</div>

	<div class="span14">
	<cfset contents = FileRead( ExpandPath("./pages/functioncode/mongo.inc") )>
	<cfset contents = Replace(contents,"<cf", "&lt;cf", "all")>
	<cfset contents = Replace(contents,"</cf", "&lt;/cf", "all")>
	<cfset contents = Replace(contents,"<!---", "&lt;!---", "all")>
	<cfset contents = Replace(contents, Chr(9), "  ", "all")>
	#contents#
	</div>

</div>
</cfif>

</cfoutput>