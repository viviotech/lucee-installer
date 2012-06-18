<cfset request.page.section = "functions">

<!---
	This is the header for the category
	--->
<h1>CFML Functions</h1>

<cfset categoryArray = GetEngineFunctionCategories()>
<ul class="pills">
	<li<cfif ArrayLen(request.params) != 3> class="active"</cfif>><a href="./?/function/">All</a></li>
	<cfoutput><cfloop array="#categoryArray#" index="category"><cfif category == "unknown"><cfcontinue></cfif>
	<li<cfif ArrayLen(request.params) == 3 && request.params[3] == category> class="active"</cfif>><a href="./?/function/category/#category#" style="text-transform:capitalize">#category#</a></li></cfloop></cfoutput>
</ul>

<cfif ArrayLen(request.params) == 3>

	<cfset request.page.title 	= "#request.params[3]# Functions">
	<cfset request.page.desc 		= "All the OpenBD CFML functions for the #request.params[3]# category">

	<cfset funcArray = GetSupportedFunctions( request.params[3] )>

	<h2 style="text-transform:capitalize"><cfoutput>#request.params[3]#</cfoutput> Category functions</h2>


	<table class="zebra-striped">
	<cfoutput><cfloop array="#funcArray#" index="func"><cfsilent>
		<cfset funcMeta = GetEngineFunctionInfo( func )>
	</cfsilent><tr>
		<td width="1%" nowrap align="right"><a href="./?/function/#func#">#application.docs.getCamelCase( func )#</a></td>
		<td>#XmlFormat(funcMeta.summary)#</td>
	</tr></cfloop>
	</cfoutput>
	</table>

<cfelse>

	<h2 style="text-transform:capitalize">All Functions</h2>
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

	<cfset request.page.title 	= "All CFML Functions">
	<cfset request.page.desc 		= "All the OpenBD CFML functions">
	<cfset funcArray = GetSupportedFunctions( "" )>
	<cfset firstChar	= "">
	<cfset cols = 0>
	<cfset leftCols = 0>

	<cfoutput>
	<cfloop index="x" from="1" to="#ArrayLen(funcArray)#">
	<cfif funcArray[x].charAt(0) != firstChar>
		<cfset firstChar = funcArray[x].charAt(0)><cfset cols = 0>

		<cfif x != 1></div></div></cfif>

		<div class="row">
			<div class="span2"><h3>#firstChar#</h3></div>
			<div class="span14">
		</cfif>
			<div class="tag"><a href="./?/function/#funcArray[ x ]#">#application.docs.getCamelCase( funcArray[ x ] )#</a></div>

	</cfloop>
	</div>

	</cfoutput>

	<div style="clear:both"></div>

</cfif>