<cfset request.page.title = "Installation Success">

<h1>Congratulations ...</h1>

<p>
	... since you are reading this, means the installation went well and you are now ready to start using OpenBD CFML.
</p>

<p>
	Some information about your current installation:
</p>

<table style="margin-left: 40px;">
<cfoutput>
<cfloop collection="#server.bluedragon#" item="k">
<tr>
	<td align="right"><strong>#k#:</strong></td>
	<td style="padding-left: 10px;">#server.bluedragon[k]#</td>
</tr>
</cfloop>
<tr>
	<td align="right"><strong>path_translated:</strong></td>
	<td style="padding-left: 10px;">#cgi.PATH_TRANSLATED#</td>
</tr>
<tr>
	<td align="right"><strong>server:</strong></td>
	<td style="padding-left: 10px;">#cgi.SERVER_NAME#:#cgi.server_port#</td>
</tr>
<tr>
	<td align="right"><strong>current time:</strong></td>
	<td style="padding-left: 10px;">#now()#</td>
</tr>
</cfoutput>
</table>

<p>
	<a href="./">Continue to the manual</a>
</p>