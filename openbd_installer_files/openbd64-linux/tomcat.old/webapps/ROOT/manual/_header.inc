<cfsilent>

	<cfparam name="request.page.title" 		default="Official">
	<cfparam name="request.page.section" 	default="">
	<cfparam name="request.page.desc" 		default="Official OpenBD CFML Manual">

</cfsilent><!DOCTYPE html>
<html lang="en" itemscope itemtype="http://schema.org/Product">
  <head>
		<title><cfoutput>#request.page.title#</cfoutput> / OpenBD CFML Manual</title>
    <meta charset="utf-8">
		<meta name="description" content="<cfoutput>#request.page.desc#</cfoutput>" />
		<meta name="keywords" content="cfml, bluedragon, openbd, open bluedragon, j2ee, open source, web, application, cfsmtp, cfimap, amazon simpledb, amazon s3, free server, cfml engine, cfvideoplayer, google app engine, gae, coldfusion" />
    <meta name="author" content="OpenBD" />

		<meta itemprop="name" content="<cfoutput>#request.page.title#</cfoutput> / OpenBD">
		<meta itemprop="description" content="<cfoutput>#request.page.desc#</cfoutput>">
		<link rel="publisher" href="https://plus.google.com/115990347459711259462" />

    <!-- Le HTML5 shim, for IE6-8 support of HTML elements -->
    <!--[if lt IE 9]>
      <script src="./js/html5shim.js"></script>
    <![endif]-->

    <link href="./css/bootstrap.css" rel="stylesheet" />
    <style type="text/css">
     body {padding-top: 60px; }
		.ac_results {padding: 0px;padding-top: 6px;border: 1px solid WindowFrame;background-color: Window;overflow: hidden;	}
		.ac_results ul {width: 100%;list-style-position: outside;list-style: none;padding: 0;margin: 0;}
		.ac_results iframe {display:none;/*sorry for IE5*/display/**/:block;/*sorry for IE5*/position:absolute;top:0;left:0;z-index:-1;filter:mask();width:3000px;height:3000px;}
		.ac_results li {margin: 0px;padding: 2px 5px;cursor: pointer;display: block;width: 100%;font: menu;font-size: 12px;overflow: hidden;}
		.ac_loading {	}
		.ac_over {background-color: Highlight;color: HighlightText;}
    </style>

		<script src="./js/jquery-1.6.4.min.js"></script>
		<script src="./js/jquery.autocomplete.js"></script>
		<script src="./js/bootstrap-dropdown.js"></script>

    <!-- Le fav and touch icons -->
    <link rel="shortcut icon" href="./favicon.ico" />
  </head>

  <body>

    <div class="topbar">
      <div class="fill">
        <div class="container">
          <a class="brand" href="./" style="padding:0"><img src="./sd_openBD_32.png" style="border:0px; margin-top:5px; margin-left: 20px; padding: 0" /></a>
          <ul class="nav">
						<li><a href="./">OpenBD</a></li>
            <li <cfif request.page.section == "basic">class="active"</cfif> class="dropdown" data-dropdown="dropdown" >
							<a href="#" class="dropdown-toggle">Basic CFML</a>
							<ul class="dropdown-menu">
								<li><a href="./?/language_tagsfunctions">Getting Started</a></li>
								<li><a href="./?/language_creation">Using Variables</a></li>
								<li><a href="./?/language_scopes">Variable Scopes</a></li>
								<li><a href="./?/language_operators">Data Operators</a></li>
								<li><a href="./?/cfscript">Using cfscript</a></li>
								<li class="divider"></li>
								<li><a href="./?/cfc_introduction">CFC CFML Objects</a></li>
								<li class="divider"></li>
								<li><a href="./?/app_application">CFML Application</a></li>
								<li><a href="./?/app_application_cfm">Application.cfm</a></li>
								<li><a href="./?/app_application_cfc">Application.cfc</a></li>
								<li><a href="./?/app_onrequestend_cfm">OnRequestEnd.cfm</a></li>
								<li><a href="./?/app_server_cfc">Server.cfc</a></li>
							</ul>
						</li>

						<li <cfif request.page.section == "adv">class="active"</cfif> class="dropdown" data-dropdown="dropdown" >
							<a href="#" class="dropdown-toggle">Advanced</a>
							<ul class="dropdown-menu">
								<li><a href="./?/database_offrequest">Background Queries</a></li>
								<li><a href="./?/database_mongodb">CFML and MongoDB</a></li>
								<li><a href="./?/cookies">Cookies</a></li>
								<li><a href="./?/cfmlmanipulation">CFML Manipulation</a></li>
								<li><a href="./?/search">Search Engine</a></li>
								<li class="divider"></li>
								<li><a href="./?/cfscript_java">Embedded Java</a></li>
								<li><a href="./?/cfscript_javascript">Embedded JavaScript</a></li>
								<li class="divider"></li>
								<li><a href="./?/webservices">Web Services</a></li>
								<li><a href="./?/webservices_restlet">RESTlet</a></li>
								<li><a href="./?/webservices_json">JSONP</a></li>
								<li><a href="./?/webservices_soap_producing">SOAP - Producing</a></li>
								<li><a href="./?/webservices_soap_consuming">SOAP - Consuming</a></li>
								<li><a href="./?/webservices_salesforce">SOAP - SalesForce</a></li>
								<li class="divider"></li>
								<li><a href="./?/amazon_s3">Amazon S3</a></li>
								<li><a href="./?/amazon_simpledb">Amazon SimpleDB</a></li>
								<li><a href="./?/amazon_sqs">Amazon SQS</a></li>
							</ul>
						</li>

            <li <cfif request.page.section == "tags">class="active"</cfif>><a href="./?/tag/">Tags</a></li>
            <li <cfif request.page.section == "functions">class="active"</cfif>><a href="./?/function/">Functions</a></li>

						<li <cfif request.page.section == "plugins">class="active"</cfif> class="dropdown" data-dropdown="dropdown" >
							<a href="#" class="dropdown-toggle">PlugIns</a>
							<ul class="dropdown-menu">
								<li><a href="./?/plugin">Overview</a></li>
								<li class="divider"></li>
								<li><a href="./?/plugin_cfsmtp">Smtp - Incoming Mail</a></li>
								<li><a href="./?/plugin_cron">CronTab - Scheduler</a></li>
								<li><a href="./?/plugin_login">Login - Security</a></li>
								<li class="divider"></li>
								<li><a href="./?/plugin_debugger">Debugger</a></li>
								<li><a href="./?/plugin_salesforce">SalesForce</a></li>
								<li class="divider"></li>
								<li><a href="./?/plugin_message">JMS Messaging</a></li>
								<li><a href="./?/plugin_exchange">Microsoft Exchange</a></li>
							</ul>
						</li>

            <li <cfif request.page.section == "engine">class="active"</cfif> class="dropdown" data-dropdown="dropdown" >
							<a href="#" class="dropdown-toggle">Server</a>
							<ul class="dropdown-menu">
								<li><a href="./?/engine">Overview</a></li>
								<li class="divider"></li>
								<li><a href="./?/engine_bluedragonxml">bluedragon.xml</a></li>
								<li><a href="./?/engine_logfiles">Log files</a></li>
								<li><a href="./?/engine_cfmail">Outgoing Email</a></li>
								<li class="divider"></li>
								<li><a href="./?/windows_server">Microsoft Windows</a></li>
								<li><a href="./?/local_nsis">NSIS + OpenBD Local</a></li>
							</ul>
						</li>

            <li <cfif request.page.section == "support">class="active"</cfif> class="dropdown" data-dropdown="dropdown" >
							<a href="#" class="dropdown-toggle">Support</a>
							<ul class="dropdown-menu">
								<li><a href="./?/support">Getting Help</a></li>
								<li><a href="./?/support_professional">Professional Help</a></li>
								<li class="divider"></li>
								<li><a href="./?/bootstrap">Bootstrap Application</a></li>
								<li class="divider"></li>
								<li><a href="./?/releases">Release Notes</a></li>
								<li><a href="./?/upgrade">Upgrade Details</a></li>
								<li class="divider"></li>
								<li><a href="http://openbd.org/download/">Download Site</a></li>
								<li><a href="./?/svn">SVN Repository</a></li>
								<li class="divider"></li>
								<li><a href="./?/acknowledgement">Acknowledgements</a></li>
							</ul>
						</li>

          </ul>
					<form action="" class="pull-right">
            <input id="searchbox" class="input-medium" type="text" placeholder="tag/function search">
          </form>
        </div>
      </div>
    </div>

    <div class="container">