<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta name="description" content="This is the start page of Railo express running on Resins. Railo 3.1 OS is a fast and reliable open source CFML engine."/>
	<meta name="keywords" content="CFML,Cold Fusion,Scripting Language,Performance,Tuning,Open Source,JBoss,Reactor,ModelGlue,ColdBox,Transfer"/>
    <title>Welcome to Railo 3.2</title><link rel="stylesheet" href="css/style.css" type="text/css" media="all"/>
</head>
   <body id="documentation" class="twoCol">
   	<div id="container" class="sysDocumentation">
   		<div id="masthead">
   			<div id="header" class="clearfix">
   				<div class="wrap"><h1><a href="http://www.getrailo.org/go.cfm/community_website">Default</a></h1>
   					<h2 id="navPrimary">Welcome to the Railo world.</h2>
   				</div>
   			</div>
   		</div>
   		<div id="content">
			<cfoutput>
   			<div class="wrap clearfix">
				<div class="sidebar" id="left">
					<ul class="navSecondary">
						<li><a href="http://www.getrailo.org/go.cfm/quick-start-guide" target="_blank">Getting Started</a>
						<li><a href="http://www.getrailo.org/go.cfm/community_website" target="_blank">Comunity Website</a></li>
						<li><a href="http://www.getrailo.org/go.cfm/wiki" target="_blank">Wiki - Documentation</a></li>
						<li><a href="http://www.getrailo.org/go.cfm/mailing-list" target="_blank">Railo mailing list</a></li>
						<li><a href="http://www.getrailo.org/go.cfm/getrailo_com" target="_blank">Support & consultung</a></li>
					</ul>
				</div>			
   				<div id="deck">
   					<div class="bg">
   					</div>
   					<div class="wrap">
   						<div class="lead">
							<h3>Railo #left(server.railo.version,3)#</h3>
							<p>You are now successfully running Railo #left(server.railo.version,3)# (#server.railo.version#). Please check the Railo Server Administrator for current updates and patches for your Version.</p>
						</div>
   					</div>
   				</div>
   				<div id="main">
   					<div id="primary" class="content">
	   					<div id="explanation">
	   					<h2>Important notes</h2>
						<p>Thank you for choosing Railo Server as your CFML engine. If you have installed Railo on your production server, please make sure
						that your Server Administrator is protected and that you have set a default password for the Web Administrator.<br><br>
						Please check the <a href="http://www.getrailo.org/go.cfm/quick-start-guide" target="_blank">quick 
						start guide</a> on our page on how to begin. In our Wiki you will find a lot of useful information and documentation.<br>
						If you have installed Railo Express, please check out our 
						<a href="http://www.getrailo.org/go.cfm/Railo_Installation" target="_blank">installation guides</a> for other platforms and 
						application servers which are available in the wiki.
						<br><br>
						At the moment this page runs on the virtual host <b>#cgi.server_name#</b>. If you like to know how to add additional 
						virtual hosts which result in Railo contexts please check the wiki on how to do this. 
						<a href="http://www.getrailo.org/go.cfm/Installation:CreateRailoContext" target="_blank">Creating new virtual hosts</a><br />
						
						</p>
	   					<h2>Railo Administration</h2>
						<p>
							If you want to call the Railo Administrator, just follow this link:
							<ul>
								<li><a href="#cgi.context_path#/railo-context/admin/server.cfm">Railo Server Administrator</a></li>
								<li><a href="#cgi.context_path#/railo-context/admin/web.cfm">Railo Web Administrator</a></li>
                                                                <li><a href="#cgi.context_path#/index.jsp">Tomcat Administrator</a></li>
							</ul>
						</p>
						</div>
						<div id="sample">
						<h2>Sample Data</h2>
						<p>Below you'll find a dump of some sample data:<br>
							<cfset railo_team = query("name":["Michael","Gert","Peter","Sean","Mark","Tanja","Roland"],"lastname":["Offner-Streit","Franz","Bell","Corfield","Drew","Stadelmann","Ringgenberg"],"Title":["CTO & Founder","CEO & Founder","Marketing & Sales - US","CEO - US","CEO - UK","Project Manager, Designer & Founder","Core Developer - BlazeDS"])>
							<!--- --->
							<cfdump var="#railo_team#"><br />
							<cfdump eval=cgi>
							
						</p>
	   					</div>
   					</div>
   				</div>
   			</div>
			</cfoutput>
   		</div>
   	</div>
   	<div id="footer" class="clearfix">
   		<div class="wrap"><p>&copy;2009 Railo Technologies GmbH, Switzerland.</p></div>
   	</div>
   </body>
</html>
