<cfset request.page.section = "basic">
<cfset request.page.title = "Application.cfc">
<cfset request.page.desc	= "Application.cfc is a richer alternative to Application.cfm">

<h1>Application.cfc</h1>

<ul class="breadcrumb">
	<li><a href="./?/basic_cfml">Basic CFML</a> <span class="divider">/</span></li>
	<li class="active">Application.cfc</li>
</ul>

<p>
Application.cfc is a richer alternative to Application.cfm, giving you hooks into various states and life cycle points of an application and request.
Packaged as a standard CFC, you override the methods you wish to provide processing for and the engine will take care of the rest.
</p>

<p>
As with any other CFC, this component can be overridden, subclassed and reused.  There is very little restrictions as to what you can do with this particular
component.   The location of this file is the same as the Application.cfm, in that, OpenBD will look for it in the same directory as the requesting template
and continue up the parent directory stack until it finds one.  Please note the case of this file is very important - the capital "A" is required.
</p>

<p>
Application.cfc reduces the complexity of managing cfApplication's as you do not have to worry about complicated locking techniques to avoid initialization
duplicates at startup if multiple requests hit it at once.   By utilising the Application.cfc method, you do not require any CFAPPLICATION tag.
</p>

<h2>Method Hooks</h2>

<p>The following methods can be defined:</p>

<ul>
	<li><code>onApplicationStart()</code>
	<br/>Called when the application is first initialized.  This method will only be called once.
	</li>

	<li class="padtop"><code>onApplicationEnd()</code>
	<br/>Called when the application is being unloaded due to inactivity.  This method will only be called once.
	</li>

	<li class="padtop"><code>onClientStart()</code>
	<br/>Called when the client request is found not to previously exist and has just been freshly created.  This method is only valid if the client management has been enabled
	for this application.
	</li>

	<li class="padtop"><code>onSessionStart()</code>
	<br/>Called when the session request is found not to previously exist and has just been freshly created. This method is only valid if the session management has been enabled
	for this application.
	</li>

	<li class="padtop"><code>onSessionEnd( session, appdata )</code>
	<br/>Called when the session has ended, passing in the current session and application data that was part of this session
	</li>

	<li class="padtop"><code>onError( catchdata, eventname )</code>
	<br/>If an error occurs within the application, then this method is called passing in the catchdata and the eventname of the error.
	</li>

	<li class="padtop"><code>onRequest( pageuri )</code>
	<br/>Used when you want to replace the processing for a given template.  If this method is found then the calling template will not be called.
	</li>

	<li class="padtop"><code>onCFCRequest( cfcname, cfcmethod, args )</code>
	<br/>Used when you want to replace the processing for remote CFC methods.  If this method is found then the CFC will not be called but instead this method.
	</li>

	<li class="padtop"><code>onRequestStart( pageuri )</code>
	<br/>Called when a request has just come in and is ready for processing.  Called before the template.
	</li>

	<li class="padtop"><code>onRequestEnd( pageuri )</code>
	<br/>Called when a request has completed and is called after the requesting template has fininshed.
	</li>

	<li class="padtop"><code>onMissingTemplate( pageuri )</code>
	<br/>Called when a request for a missing template is made.
	</li>

	<li class="padtop"><code>onMissingMethod( methodName, methodArguments )</code>
	<br/>If a call is made to a method that is not found, then this method is then triggered passing in the relevant method arguments and name.
</ul>

<h2>Defining cfApplication Properties</h2>

<p>
The standard cfApplication has properties that are associated with it and these are historically defined using the attributes of the CFAPPLICATION tag.  This tag is not
required when using the Application.cfc method.   Instead, you define the properties of the cfApplication as top level object variables, using CFSCRIPT or CFSET.
</p>

<ul>
	<li><code>this.name</code>
	<br/>Defines the name of the cfApplication; this is just a plain string value
	</li>
	<li class="padtop"><code>this.scriptprotect</code>
	<br/>This boolean determines if the script protection layer is enabled
	</li>
	<li class="padtop"><code>this.mappings</code>
	<br/>This structure contains the mappings for this application
	</li>
	<li class="padtop"><code>this.customTagPaths</code>
	<br/>This is a string denoting the list of paths that will be searched before the standard custompath
	</li>
	<li class="padtop"><code>this.applicationtimeout</code>
	<br/>This is the length of time, defined as a factor of a date (use CreateTimeSpan()) that this application will be available in memory after no requests are made to it.
	</li>
	<li class="padtop"><code>this.sessiontimeout</code>
	<br/>This is the length of time, defined as a factor of a date (use CreateTimeSpan()) that this session will be available in memory after no requests are made to it.
	</li>
	<li class="padtop"><code>this.setclientcookies</code>
	<br/>This boolean controls whether or not client cookies will be used.
	</li>
	<li class="padtop"><code>this.sessionmanagement</code>
	<br/>This boolean controls whether or not session management is enabled.
	</li>
	<li class="padtop"><code>this.setdomaincookies</code>
	<br/>This boolean controls whether domain cookies will be used instead of full server name cookies.
	</li>
	<li class="padtop"><code>this.clientmanagement</code>
	<br/>This boolean controls whether or not client management is used.
	</li>
	<li class="padtop"><code>this.clientstorage</code>
	<br/>This string controls the client storage method.  Valid values are: COOKIE, REGISTRY or DATASOURCE
	</li>
	<li class="padtop"><code>this.loginstorage</code>
	<br/>This string controls the login storage method.  For use with CFLOGIN
	</li>
	<li class="padtop"><code>this.securejson</code>
	<br/>This boolean controls whether or not SecureJSON feature is used in WebServices communications.
	</li>
	<li class="padtop"><code>this.securejsonprefix</code>
	<br/>If the secure JSON flag is set, this variable lets you define the prefix that will be used for the JSON prefix.
	</li>
	<li class="padtop"><code>this.datasource</code>
	<br/>The default datasource for this application that CFQUERY/CFSTOREDPROC/QueryRun() will use if one is not explicitly defined.
	</li>
</ul>

<h2>Sample Application.cfc</h2>

<p>
The following is a short sample of a Application.cfc that may be used.
</p>

<pre class="cfml">
&lt;cfcomponent>

  &lt;cfset this.name = "myApplication">

  // alternatively you can do this inside a cfscript block
  &lt;cfscript>
    this.sessionmanagement = false;
    this.clientmanagement = false;
  &lt;/cfscript>

  &lt;cffunction name="onApplicationStart">
    // your code to initialise the variables that will go in "application" scope
    &lt;cfset application.datasource = "myDatasource">
  &lt;/cffunction>

  &lt;cffunction name="onRequestStart">
    &lt;cfargument name="requesturi" required="true"/>
  &lt;/cffunction>

&lt;/cfcomponent>
</pre>
