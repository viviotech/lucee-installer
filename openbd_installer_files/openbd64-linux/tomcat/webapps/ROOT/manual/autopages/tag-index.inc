<cfset request.page.section = "tags">


<h1>CFML Tags</h1>

<cfset tagArray = GetEngineTagCategories()>
<ul class="pills">
<li<cfif ArrayLen(request.params) != 3> class="active"</cfif>><a href="./?/tag/">All</a></li>
<cfoutput><cfloop array="#tagArray#" index="category">
<li<cfif ArrayLen(request.params) == 3 && request.params[3] == category> class="active"</cfif>><a href="./?/tag/category/#category#" style="text-transform:capitalize">#category#</a></li></cfloop></cfoutput>
</ul>


<cfif ArrayLen(request.params) == 3>

	<cfset request.page.title 	= "#request.params[3]# Tags">
	<cfset request.page.desc 		= "#request.params[3]# Tags">


	<cfoutput>
	<h2 style="text-transform:capitalize">#request.params[3]# Tags</h2>

	<cfset funcArray = GetSupportedTags( request.params[3] )>

	<table class="zebra-striped">
	<cfloop array="#funcArray#" index="func"><cfsilent>
		<cfset funcMeta = GetEngineTagInfo( func )>
	</cfsilent><tr>
		<td width="1%" nowrap align="right"><a href="./?/tag/#func#">#func#</a></td>
		<td>#XmlFormat(funcMeta.summary)#</td>
	</tr></cfloop>
	</table>
	</cfoutput>

<cfelse>

	<h2 style="text-transform:capitalize">All Tags</h2>

	<style>
	.tag {
		width: 180px; height: 30px;
		vertical-align: middle;
		float: left;
		margin-right: 20px;
	}

	.row {
		margin-bottom: 30px;
	}

	.row h3 {
		line-height: inherit;
	}
	</style>

	<cfset request.page.title 	= "All CFML Tags">
	<cfset request.page.desc 		= "All the OpenBD CFML tags">
	<cfset funcArray = GetSupportedTags( "" )>
	<cfset firstChar	= "">
	<cfset cols = 0>

	<cfoutput>
	<cfloop index="x" from="1" to="#ArrayLen(funcArray)#"><cfif Len(funcArray[x]) == 2><cfcontinue></cfif>
	<cfif funcArray[x].charAt(2) != firstChar>
		<cfset firstChar = funcArray[x].charAt(2)><cfset cols = 0>

	<cfif x != 1></div></div></cfif>

	<div class="row">
		<div class="span2"><h3>#firstChar#</h3></div>
		<div class="span14">
	</cfif>

		<div class="tag"><a href="./?/tag/#funcArray[ x ]#">#application.docs.getCamelCase( funcArray[ x ] )#</a></div>

	</cfloop>


	</div>
	</cfoutput>

	<div style="clear:both"></div>

</cfif>


<!---
<p>The following tags all belong to the <cfoutput>#url.category#</cfoutput> category.</p>
<cfoutput>
<table width="90%" align="center" cellpadding="5" cellspacing="0">
<cfloop array="#funcArray#" index="func"><cfsilent>
	<cfset funcMeta = GetEngineTagInfo( func )>
</cfsilent><tr>
	<td width="1%" nowrap align="right"><a href="./?/tag/#func#">#func#</a></td>
	<td>#XmlFormat(funcMeta.summary)#</td>
</tr></cfloop>
</table>
</cfoutput>
--->
