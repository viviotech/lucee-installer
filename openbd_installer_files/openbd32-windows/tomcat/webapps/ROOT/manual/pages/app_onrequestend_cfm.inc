<cfset request.page.section = "basic">
<cfset request.page.title = "OnRequestEnd.cfm">
<cfset request.page.desc	= "This is file is called at the end of every request">

<h1>OnRequestEnd.cfm</h1>

<ul class="breadcrumb">
	<li><a href="./?/basic_cfml">Basic CFML</a> <span class="divider">/</span></li>
	<li class="active">OnRequestEnd.cfm</li>
</ul>

<p>
Much like the <strong>Application.cfm</strong> gets called at the start of every request, the <strong>OnRequestEnd.cfm</strong> is called when a template is finished
executing.
</p>

<p>
This is a standard template that has no special formatting except it must be named observing the case.  For example onrequestend.cfm is not the same.
</p>

<p>
The only difference with this special file, is that the engine will not transverse up the directory tree looking for it.   It must reside in the same directory as the
template that was called for it to be triggered.
</p>

<p>
This template will produce output, so any processing you do, will send data to the client as part of the request.  The client will not see the difference and merely
treat it as part of the original request.   If you do not wish this, then simply wrap this template with a CFSILENT tag.
</p>
