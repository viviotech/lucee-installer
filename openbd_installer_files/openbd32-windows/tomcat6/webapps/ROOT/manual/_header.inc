<cfsilent>

	<cfparam name="request.page.title" default="Official">
	<cfparam name="request.page.desc" default="Official OpenBD CFML Manual">

</cfsilent>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title><cfoutput>#request.page.title#</cfoutput> - OpenBlueDragon CFML Manual</title>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta name="description" content="<cfoutput>#request.page.desc#</cfoutput>" />
	<link rel ="stylesheet" type="text/css" href="style.css"/>
	<script type="text/javascript" src="jquery-1.4.2.min.js"></script>
	<script type="text/javascript" src="jquery.tree.js"></script>
	<cfstylesheet>
	.tree-default ins.doc {
		background-image: url("doc.png");
	}
	.tree-default ins.function {
		background-image: url("function.png");
	}
	.tree-default ins.tag {
		background-image: url("tag.png");
	}

	#content {
		margin: 15px;
	}

	#manual {
		padding-bottom: 20px;
	}

	#content h1 {
		font-size: 120%;
		border-left: 6px solid green;
		border-right: 50px solid green;
		padding: 3px;
		padding-left: 6px;
		text-transform: capitalize;
	}

	.functionTable {
		margin-left: 20px;
		width: 90%;
	}

	.functionTable .letter {
		border-bottom: 1px dotted gray;
		margin-top: 10px;
		margin-bottom: 4px;
		font-weight: bold;
		font-size: 110%;
	}

	pre.cfml {
		background-color: #f9f9f9;
		border: 1px solid silver;
		margin-top: 10px;
		margin-bottom: 10px;
		margin-right: 30px;
		padding: 5px;
		font-size: 0.82em;
	}

	#footer{
		background-color: #f9fcff;
		padding: 20px;
		font-size: 70%;
		min-height: 50px;
	}
	</cfstylesheet>
</head>
<body>

<table width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="2">

		<table width="98%" align="center">
		<tr>
			<td width="30%" valign="center"><a href="index.cfm" target="_parent" title="reload this documentation set"><img src="openBD-logo-small.png" style="margin: 7px;" /></a></td>
			<td width="30%" align="right">OpenBlueDragon
			&mdash; <a href="http://www.openbluedragon.org/" target="_parent" title="visit the main OpenBlueDragon website">www</a>
			&mdash; <a href="http://wiki.openbluedragon.org/" target="_parent" title="visit the main OpenBlueDragon WIKI">wiki</a>
			</td>
		</tr>
		</table>

	</td>
</tr>
<tr>
	<td valign="top" width="250" style="border-top:1px solid blue; border-right: 1px solid blue;">

	<div id="manual">

		<ul>
			<li id="phtml_1" class="open"><a href="#"><ins>&nbsp;</ins><strong>Core Language</strong></a>
				<ul>
					<li><a href="./?/introduction" <cfif pageName == "introduction">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Introduction to CFML</a></li>
					<li><a href="./?/scopes" <cfif pageName == "scopes">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Variable Scopes</a></li>
					<li><a href="./?/database" <cfif pageName == "database">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Database Access</a></li>
					<li><a href="./?/customtag" <cfif pageName == "customtag">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Custom Tags</a></li>
					<li><a href="./?/cfc" <cfif pageName == "cfc">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>CFC Components</a></li>
				</ul>
			</li>
			<li class="open"><a href="#"><ins>&nbsp;</ins><strong>Advanced Topics</strong></a>
				<ul>
					<li><a href="./?/Application_cfm" <cfif pageName == "application_cfm">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Application.cfm</a></li>
					<li><a href="./?/Application_cfc" <cfif pageName == "application_cfc">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Application.cfc</a></li>
					<li><a href="./?/queryofqueries" <cfif pageName == "queryofqueries">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Query of Queries</a></li>
					<li><a href="./?/cfscript" <cfif pageName == "cfscript">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Scripting with CFSCRIPT</a></li>
					<li><a href="./?/webservices" <cfif pageName == "webservices">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Web Services</a></li>
				</ul>
			</li>
			<li class="open"><a href="#"><ins>&nbsp;</ins><strong>Official Plugins</strong></a>
				<ul>
					<li><a href="./?/plugin_introduction" <cfif pageName == "plugin_introduction">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Plugin Overview</a></li>
					<li><a href="./?/plugin_spreadsheet" <cfif pageName == "plugin_spreadsheet">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>SpreadSheet</a></li>
					<li><a href="./?/plugin_cron" <cfif pageName == "plugin_cron">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>cfCronTab</a></li>
					<li><a href="./?/plugin_smtp" <cfif pageName == "plugin_smtp">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>CFSMTP</a></li>
					<li><a href="./?/plugin_lib" <cfif pageName == "plugin_lib">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>cfLib</a></li>
					<li><a href="./?/plugin_spellcheck" <cfif pageName == "plugin_spellcheck">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>SpellCheck</a></li>
					<li><a href="./?/plugin_wiki" <cfif pageName == "plugin_wiki">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Wiki</a></li>
				</ul>
			</li>

			<li <cfif pageName.indexOf("tag/") != -1>class="open"</cfif>><a href="#"><ins>&nbsp;</ins><strong>Tag Reference</strong></a>
				<ul>
					<li><a href="./?/tag/all" <cfif pageName == "tag/all">class="clicked"</cfif>><ins class="tag">&nbsp;</ins>All CFML Tags</a></li>
					<cfset tagArray = GetEngineTagCategories()>
					<cfoutput><cfloop array="#tagArray#" index="category">
					<li><a href="./?/tag/category/#category#"<cfif pageName == "tag/category/#category#"> class="clicked"</cfif>><ins class="tag">&nbsp;</ins>#category#</a></a></li></cfloop></cfoutput>
				</ul>
			</li>
			<li <cfif pageName.indexOf("function/") != -1>class="open"</cfif>><a href="#"><ins>&nbsp;</ins><strong>Function Reference</strong></a>
				<ul>
				<li><a href="./?/function/all" <cfif pageName == "function/all">class="clicked"</cfif>><ins class="function">&nbsp;</ins>All CFML Functions</a></li>
				<cfset categoryArray = GetEngineFunctionCategories()>
				<cfoutput><cfloop array="#categoryArray#" index="category"><cfif category == "unknown"><cfcontinue></cfif>
					<li><a href="./?/function/category/#category#"<cfif pageName == "function/category/#category#"> class="clicked"</cfif>><ins class="function">&nbsp;</ins>#category#</a></a></li></cfloop></cfoutput>
				</ul>
			</li>
			<li><a href="./?/acknowledgement" <cfif pageName == "acknowledgement">class="clicked"</cfif>><ins class="doc">&nbsp;</ins>Acknowledgements</a></li>
		</ul>

	</div>


	</td><td valign="top" style="border-top:1px solid blue;"><div id="content">
