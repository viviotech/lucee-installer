<cfscript>
        refURL="http://docs.lucee.org/reference.html";
        githubURL="https://github.com/lucee/Lucee";
        adminURL="#CGI.CONTEXT_PATH#/lucee/admin.cfm";
        webAdminURL="#CGI.CONTEXT_PATH#/lucee/admin/web.cfm";
        serverAdminURL="#CGI.CONTEXT_PATH#/lucee/admin/server.cfm";
        mailinglistURL="https://groups.google.com/forum/##!forum/lucee";
        profURL="http://lucee.org/support.html";
        issueURL="https://bitbucket.org/lucee/lucee/issues";
        newURL="http://docs.lucee.org/guides/lucee-5.html";
        firststepsURL="http://docs.lucee.org/guides/getting-started/first-steps.html";
</cfscript><!DOCTYPE html>
<html>
        <head>
                <title>Rapid web development with Lucee!</title>
                <link rel="stylesheet" type="text/css" href="/assets/css/lib/bootstrap.min.css">
                <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700,800">
                <!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="/assets/css/lib/ie8.css"><![endif]-->
                <link rel="stylesheet" type="text/css" href="/assets/css/core/_ed07b761.core.min.css">
                <!--[if lt IE 9]>
                        <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
                <![endif]-->
        </head>
        <body class="sub-page">
                <div class="main-wrapper">

        <section id="page-banner" class="page-banner">
                <div class="container">
                        <div class="banner-content">
                                <cfoutput>
                                <img src="/assets/img/lucee-logo.png" alt="Lucee">
                                <h1>Welcome to your Lucee #ListFirst(server.lucee.version,'.')# Installation!</h1>
                                <p class="lead-text">You are now successfully running Lucee #server.lucee.version# on your system!</p>
                                </cfoutput>
                        </div>
                </div>
        </section>



        <section id="contents">

                <div class="container full-width">
                        <div class="row">

                                <div class="col-md-8 main-content">

                                        <div class="content-wrap">

                                                <ul class="listing border-light">

                                                        <cfoutput>

                                                        <li class="listing-item thumb-large">
                                                                <div class="listing-thumb">
                                                                        <a href="#newURL#">
                                                                                <img src="/assets/img/img-new.png" alt="">
                                                                        </a>
                                                                </div>


                                                                <div class="listing-content">
                                                                        <h2 class="title">
                                                                                <a href="#newURL#">New in Lucee 5</a>
                                                                        </h2>

                                                                        <p>
                                                                                Lucee 5 is the first major release of Lucee after forking from the Railo project. Lucee 5 is not about dazzling new features but about improving the core language and providing a complete architectural overhaul of the engine which brings Lucee and CFML as a language to a whole new level of awesome! <a href="#newURL#">Read More</a>
                                                                        </p>

                                                                </div>

                                                                <div class="clearfix"></div>
                                                        </li>

                                                        <li class="listing-item thumb-large">
                                                                <div class="listing-thumb">
                                                                        <a href="#firststepsURL#">
                                                                                <img src="/assets/img/img-first-steps.png" alt="">
                                                                        </a>
                                                                </div>


                                                                <div class="listing-content">
                                                                        <h2 class="title">
                                                                                <a href="#firststepsURL#">First steps</a>
                                                                        </h2>

                                                                        <p>
                                                                                If you are new to Lucee or the CFML language in general,  check our <a href="#firststepsURL#">First Steps</a> page in our docs. There you'll find a quick primer of the amazing and easy-to-learn CFML language. If you come from a deisgn-based background, CFML's tag-based language should make it easy to learn and use right away. If you're coming from another development language, the CFML script-based syntax may be more to your liking. Either way, it's a great place to get started on your journey with Lucee and CFML!</p>


                                                                </div>

                                                                <div class="clearfix"></div>
                                                        </li>



                                                        <li class="listing-item thumb-large">
                                                                <div class="listing-thumb">
                                                                        <a href="#refURL#">
                                                                                <img src="/assets/img/img-code.png" alt="">
                                                                        </a>
                                                                </div>


                                                                <div class="listing-content">
                                                                        <h2 class="title">
                                                                                <a href="#refURL#">Documentation</a>
                                                                        </h2>

                                                                        <p>
                                                                                Already a CFML coding master? Check out the Lucee Code Reference for quick access to all the tags and functions available in Lucee as well as how it differs from Adobe's ColdFusion Server. <a href="#refURL#">Read More</a>
                                                                        </p>

                                                                </div>

                                                                <div class="clearfix"></div>
                                                        </li>

							<li class="listing-item thumb-large">
								<div class="listing-thumb">
									<a href="#adminURL#">
										<img src="/assets/img/img-exclamation-mark.png" alt="">
									</a>
								</div>
								

								<div class="listing-content">
									<h2 class="title">
										<a href="#adminURL#	">Secure Administrators</a>
									</h2>

									<p>Important! If you have installed Lucee on a public server you need make sure you secure the <a href="#serverAdminURL#">Server</a> and <a href="#webAdminURL#">Web</a> admins OF EVERY CONTEXT with passwords or other access restrictions. It is also recommended that you set a default password in the Server admin so that all web admins are protected by default.</p>


								</div>
								
								<div class="clearfix"></div>

							</li>

						</cfoutput>
						</ul>
					</div>
					

				</div>
				

				<div class="col-md-4 sidebar">

					<div class="sidebar-wrap">
						<cfoutput>
						<div class="widget widget-text">

							<h3 class="widget-title">Related Websites</h3>

							<!--- lucee.org --->
							<p class="file-link"><a href="http://www.lucee.org">Lucee Association Switzerland</a></p>
							<p>Non-profit custodians and maintainers of the Lucee Project</p>
							
							<!--- Bitbucket 
							<p class="file-link">Lucee Bitbucket</a></p>
							<p>Access the source code and builds</p> --->
							
							<!--- Mailinglist --->
							<p class="file-link"><a href="##">Get Involved</a></p>
							<p>
								Get involved in the Lucee Project!<br />
							- Engage with other Lucee community members via our <a href="#mailinglistURL#">mailing list</a><br />
							- <a href="#issueURL#">Submitting</a> bugs and feature requests<br />
							- <a href="#githubURL#">Contribute</a> to the code<br />
							- Become a <a href="http://lucee.org/supporters/become-a-supporter.html">Lucee Supporter</a><br />
							</p>
							

	

							<!--- Prof Services --->
							<p class="file-link"><a href="#profURL#">Professional Services</a></p>
							<p>Whether you need installation support or are looking for other professional services. Access our directory of providers <a href="#profURL#">HERE</a>.</p>

						</div>
						</cfoutput>
					</div>
					
				</div>
				

			</div>
			

		</div>
		

	</section>
	



		    <footer id="subhead">


		        <div class="footer-bot">
		            <div class="container">
		                <div class="row">
		                    <div class="col-md-2 col-sm-4">
		                        <a href="/" class="footer-logo">
		                            <img src="/assets/img/lucee-logo.png" alt="Lucee">
		                        </a>
		                        

		                    </div>
		                    

		                    <div class="col-md-5 col-sm-4">
		                        <p class="copyright-text">Copyright &copy; 2015 by the Lucee Association Switzerland</p>
		                    </div>
		                    



		                </div>
		                

		            </div>
		            

		        </div>
		        

		    </footer><!-- End of footer -->

        </div> <!-- End of .main-wrapper -->


		
	

	
		

<script src="/assets/js/lib/jquery-1.10.1.min.js"></script>
<script src="/assets/js/lib/bootstrap.min.js"></script>
<script src="/assets/js/core/_38444bee.core.min.js"></script>
<script src="/assets/js/lib/SmoothScroll.js"></script>

	</body>
	
</html>
