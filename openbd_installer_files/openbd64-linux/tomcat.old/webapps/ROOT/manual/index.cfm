<cfsilent>

<cfscript>
pageName = cgi.QUERY_STRING;
if ( pageName.startsWith("/") ){
	pageName = LCase( pageName.substring(1) );
}

request.params	= ListToArray( pageName, "/" );

if ( ArrayLen(request.params) == 0 ){
	request.template = "pages/index.inc";
} else if ( request.params[1] == "function" ){
	request.template	= "autopages/function-index.inc";

	if ( ArrayLen(request.params) >= 2 ){
		if ( request.params[2] == "category" )
			request.template	= "autopages/function-index.inc";
		else{
			request.template	= "autopages/function-individual.inc";
		}
	}

} else if ( request.params[1] == "tag" ){
	request.template	= "autopages/tag-index.inc";

	if ( ArrayLen(request.params) >= 2 ){
		if ( request.params[2] == "category" )
			request.template	= "autopages/tag-index.inc";
		else{
			request.template	= "autopages/tag-individual.inc";
		}
	}


} else {
	request.template	= "pages/#request.params[1]#.inc";
}


// Render the body content
request.content	= RenderInclude( request.template );

if ( request.template != "pages/index.inc" )
	request.content = "<div style='float:right;'><span style='padding-right: 15px;'><a href='https://twitter.com/share' class='twitter-share-button' data-count='none' data-via='openbluedragon'>Tweet</a></span><div class='g-plusone' data-annotation='none'></div></div>" & request.content;

</cfscript>


</cfsilent><cfinclude template="_header.inc">
<cfoutput>#request.content#</cfoutput>
<cfinclude template="_footer.inc">