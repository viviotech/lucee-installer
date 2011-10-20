//FlashHelp 1.0
var gnFlashVersion = -1;
var gaPaths = new Array();
var gaAvenues = new Array();
var gnTopicOnly = -1;

var gsPPath = "";
var gsStartPage = "";
var gsRelCurPagePath = "";
var gsTopicbarOrder="show";

var gstrBsAgent 	= navigator.userAgent.toLowerCase();
var gnBsVer	   		= parseInt(navigator.appVersion);
var gbBsIE  		= (gstrBsAgent.indexOf('msie') != -1);
var gbBsNS  		= (gstrBsAgent.indexOf('mozilla') != -1) && ((gstrBsAgent.indexOf('spoofer') == -1) && (gstrBsAgent.indexOf('compatible') == -1));
var gbBsOpera		= (gstrBsAgent.indexOf('opera') != -1);
var gbBsNS4			= ((gbBsNS) && (gnBsVer >= 4));
var gbBsNS6			= ((gbBsNS) && (gnBsVer >= 5));

var gbNav7		= false;
var gbBsOpera6		= false;
var gbBsOpera7		= false;
var gbKonqueror		=(gstrBsAgent.indexOf("konqueror")!= -1);
var gbMozilla		= ((gstrBsAgent.indexOf('gecko')!=-1) && (gstrBsAgent.indexOf('netscape')==-1));

var gbMac=	(gstrBsAgent.indexOf("mac")!=-1);
var gbWindows=	((gstrBsAgent.indexOf('win')!= -1)||(gstrBsAgent.indexOf('16bit')!= -1));

if(gbBsNS6)
{
	var nPos=gstrBsAgent.indexOf("gecko");
	if(nPos!=-1)
	{
		var nPos2=gstrBsAgent.indexOf("/", nPos);
		if(nPos2!=-1)
		{
			var nVersion=parseFloat(gstrBsAgent.substring(nPos2+1));
			if(nVersion>=20010726)
			{
				if (nVersion>=20020823)
					gbNav7=true;
			}
		}
	}
}

if (gbBsOpera)
{
	var nPos = gstrBsAgent.indexOf("opera");
	if(nPos!=-1)
	{
		var nVersion = parseFloat(gstrBsAgent.substring(nPos+6));
		if (nVersion >= 6)
		{
			gbBsOpera6=true;
			if (nVersion >=7)
				gbBsOpera7=true;	
		}
	}
}

if (gbWindows && gbBsIE && !parent.parent.parent.gbToolBarLoaded)
{
	var sVBScript = '';
	sVBScript += '<script language="VBScript"\> \n';
	sVBScript += 'Private i, x \n';
	sVBScript += 'On Error Resume Next \n';
	sVBScript += 'MM_FlashControlInstalled = False \n';
	sVBScript += 'For i = 6 To 1 Step -1 \n';
	sVBScript += '   Set x = CreateObject("ShockwaveFlash.ShockwaveFlash." & i) \n';
	sVBScript += '   MM_FlashControlInstalled = IsObject(x) \n';
	sVBScript += '   If MM_FlashControlInstalled Then \n';
	sVBScript += '       gnFlashVersion = i \n';
	sVBScript += '       Exit For \n';
	sVBScript += '   End If \n';
	sVBScript += 'Next \n';
	sVBScript += '</script> \n';
	document.write(sVBScript);
}

function IsFlashSupported()
{
	var bResult = false;

	if (gnFlashVersion == -1)
	{
		if (parent.parent.parent.gbToolBarLoaded)
		{
			gnFlashVersion = 6;
		}
		else
		{
			if (navigator.plugins && navigator.plugins.length > 0)
			{
				if (navigator.plugins["Shockwave Flash"])
				{
					var words = navigator.plugins["Shockwave Flash"].description.split(" ");
					for (var i = 0; i < words.length; ++i)
					{
						if (isNaN(parseInt(words[i])))
							continue;
						gnFlashVersion = words[i];
					}
				}
			}
		}
	}
	if (gnFlashVersion == -1)
	{
		gnFlashVersion = 0;
	}

	if (gnFlashVersion>=6)
	{
		bResult = true;
	}

	return bResult;
}

function SendCmdToMainHTML(cmd, param) {
	if( (parent != this) && (parent.DoCommand) )
	{
		parent.DoCommand(cmd, param);	
	}
}

function sendTopicLoaded()
{
	parent.gbTopicLoaded = true;
	SendCmdToMainHTML("CmdTopicIsLoaded",1);
}

function DoCommand(cmd, param) {
	if (cmd == "CmdAskIsTopicOnly")	{
		if( (parent!=this) && (parent.DoCommand) )
		{
			parent.DoCommand(cmd, param);	
		}
	} else if (cmd == "CmdScrollbarDragStart") {
		if (gbBsNS6 || (gbBsOpera && !gbMac)) {
			document.getElementById("scrollbarDIV").style.visibility = "";
		} else if (gbBsNS4) {
			document.layers["scrollbarLayer"].visibility = "show";
		}
	} else if (cmd == "CmdScrollbarDragStop") {
		if (gbBsNS6 || (gbBsOpera && !gbMac)) {
			document.getElementById("scrollbarDIV").style.visibility = "hidden";
		} else if (gbBsNS4) {
			document.layers["scrollbarLayer"].visibility = "hidden";
		}
	} else if (cmd == "CmdScrollbarDragMove") {
		if (gbBsNS6) {
			document.getElementById("scrollbarDIV").style.left = param;
		} else if (gbBsNS4) {
			document.layers["scrollbarLayer"].pageX = param;
		} else if (gbBsOpera && !gbMac) {
			eval('document.all.scrollbarDIV').style.pixelLeft = param;
		}
	}
}

function getElement(elementID) {
	var element = null;
	// See if the browser supports the functions we need to get to the element
	if (document.getElementById) {
		element = document.getElementById(elementID);
	} else if (document.all) {
		element = document.all(elementID);
	}
	return element;
} 

// Unload processing
function TopicUnloaded() {
	parent.gbTopicLoaded = false;
	SendCmdToMainHTML("CmdTopicUnloaded");
}
window.onunload = TopicUnloaded;

// project info
function setRelStartPage(sPath)
{
	if (gsPPath.length == 0)
	{
		gsPPath = _getFullPath(_getPath(document.location.href),  _getPath(sPath));
		gsStartPage = _getFullPath(_getPath(document.location.href), sPath);
		gsRelCurPagePath = _getRelativeFileName(gsStartPage, document.location.href);
	}
}

function addTocInfo(sTocPath)
{
	gaPaths[gaPaths.length] = sTocPath;
}

function addAvenueInfo(sName, sPrev, sNext)
{
	gaAvenues[gaAvenues.length] = new avenueInfo(sName, sPrev, sNext);	
}

function avenueInfo(sName, sPrev, sNext)
{
	this.sName = sName;
	this.sPrev = sPrev;
	this.sNext = sNext;
}

function _getNumLines(sLines)
{
	var nLines=1;
	var nStart=0;
	while(sLines.indexOf('\n',nStart)!=-1)
	{
		nLines++;
		nStart = sLines.indexOf('\n',nStart)+1;
	}
	return nLines;
}

function stringToRGB(color_str) {
	
	// First create a lowercase version of the string
	var lowercase_str = color_str.toLowerCase();
	var value = 0xFFFFFF;
	
	if (lowercase_str.charAt(0) == "#") {
		// Convert HEX
		value = parseInt(lowercase_str.substring(1, lowercase_str.length), 16);	
	} else {
		switch (lowercase_str) {
			case "white": value = 0xFFFFFF; break;
			case "black": value = 0x000000; break;
			case "red": value = 0xFF0000; break;
			case "green": value = 0x008000; break;
			case "blue": value = 0x0000FF; break;
			case "silver": value = 0xC0C0C0; break;
			case "gray": value = 0x808080; break;
			case "maroon": value = 0x800000; break;
			case "purple": value = 0x800080; break;
			case "fuchsia": value = 0xFF00FF; break;
			case "magenta": value = 0xFF00FF; break;
			case "lime": value = 0x00FF00; break;
			case "olive": value = 0x808000; break;
			case "yellow": value = 0xFFFF00; break;
			case "navy": value = 0x000080; break;
			case "teal": value = 0x008080; break;
			case "aqua": value = 0x00FFFF; break;
			case "cyan": value = 0x00FFFF; break;
			case "brown": value = 0xA52A2A; break;
			case "darkgray": value = 0xA9A9A9; break;
			case "lightblue": value = 0xADD8E6; break;
			case "tan": value = 0xD2B48C; break;
			case "lightgray": value = 0xD3D3D3; break;
			case "beige": value = 0xF5F5DC; break;
			case "orange": value = 0xFFA500; break;
			case "gold": value = 0xFFD700; break;
		}
	}
	
	return value;
}


function sendBgColorInfo()
{
	var bgColor = 0xFFFFFF; // default to white
	if ((document.bgColor != null) && (document.bgColor != "")) {
		bgColor = stringToRGB(document.bgColor);
	}
	SendCmdToMainHTML("CmdTopicBGColor", bgColor);	
}

function createSyncInfo()
{
	var sSyncInfo="";
	if (gaPaths.length <= 0)
		return "";
			
	if (gsPPath.length == 0)
		gsPPath = _getPath(document.location.href);
		
	sSyncInfo += gsPPath;
	sSyncInfo += "\n"+document.location.href;
	for(i=0;i<gaPaths.length;i++)
	{
		sSyncInfo += "\n"+ _getNumLines(gaPaths[i]) + "\n" +gaPaths[i];
	}
	return sSyncInfo;
}

function sendSyncInfo()
{	
	if (gaPaths.length <= 0)
		return;
	var sSyncInfo=createSyncInfo();	
	SendCmdToMainHTML("CmdSyncInfo",sSyncInfo);
}

function autoSync(nSync)
{
	if (nSync == 0) return;
	if (gaPaths.length <= 0)
		return;
	var sSyncInfo=createSyncInfo();	
	SendCmdToMainHTML("CmdSyncTOC",sSyncInfo);	
}


function sendAveInfo()
{	if (gaAvenues.length > 0)
		setTimeout("Do_sendAveInfo();", 100);
}

function Do_sendAveInfo()
{	
	var sAveInfo="";
	for(i=0;i<gaAvenues.length;i++)
	{
		sAveInfo+=gaAvenues[i].sName+"\n";
		sAveInfo+=gaAvenues[i].sPrev+"\n";
		sAveInfo+=gaAvenues[i].sNext;
		if(i != gaAvenues.length-1)
			sAveInfo+="\n";
	}
	SendCmdToMainHTML("CmdBrowseSequenceInfo",sAveInfo);
}

function addShowButton()
{
	if(parent.gbFHPureHtml)
		return;	
	if(isInPopup())
		return;
	if(gsTopicbarOrder.indexOf("show") <0 )
		return;
	if(!isTopicOnly())
		return;	
	var sHTML = "";
	sHTML += "<table width=100%><tr>"	
	sHTML += "<td width=33%>";
	sHTML += "<div align=left>";
	sHTML += "<table cellpadding=\"2\" cellspacing=\"0\" border=\"0\"><tr>";
	sHTML += "<td><a class=\"whtbtnshow\" href=\"javascript:void(0);\" onclick=\"show();return false;\">Show</a></td></tr></table> ";
	sHTML += "</tr></table>";
	sHTML += "</div>";
	sHTML += "</tr></table>";
	document.write(sHTML);
	var sStyle = "<style type='text/css'>";
	sStyle+= ".whtbtnshow{font-family:;font-size:10pt;font-style:;font-weight:;text-decoration:;color:;}";
	sStyle+= "</style>";
	document.write(sStyle);
}

function show()
{
	if (gsStartPage != "")
		window.location =  gsStartPage + "#" + gsRelCurPagePath;
}

function isTopicOnly()
{
	if (gnTopicOnly == 1)
		return true;
	if (gnTopicOnly == 0)
		return false;
	if (parent == this)
		return true;
	if (gnTopicOnly == -1)
	{
		var oParam = new Object();
		oParam.isTopicOnly = true;
		SendCmdToMainHTML("CmdAskIsTopicOnly",oParam);
		if (oParam.isTopicOnly)
		{		
			gnTopicOnly = 1;
			return true;
		}
		else
		{
			gnTopicOnly = 0;
			return false;
		}
	}
}

function isInPopup()
{
	return (window.name.indexOf("BSSCPopup") != -1);
}

function PickupDialog_Invoke()
{
	if (typeof(wfRelatedTopic)=="function" && Number(gsSkinVersion) > 2 && IsFlashSupported())
			return wfRelatedTopic(PickupDialog_Invoke.arguments);
	if (!gbIE4 || gbMac || gbOpera)
	{
		if (typeof(wfRelatedTopic)=="function" && Number(gsSkinVersion) > 2 && IsFlashSupported())
			return wfRelatedTopic(PickupDialog_Invoke.arguments);
		else if (typeof(_PopupMenu_Invoke)=="function")
			return _PopupMenu_Invoke(PickupDialog_Invoke.arguments);
	}
	else
	{
		if (PickupDialog_Invoke.arguments.length > 2)
		{
			var sPickup = "wf_pickup.htm";
			if(sPickup.substr(0,2) == "%%")//WW: WWH_TODO delete it when release
			sPickup = "wf_pickup1.htm";
			var sPickupPath=gsPPath+sPickup; 
			if (gbIE4)
			{
				var sFrame = PickupDialog_Invoke.arguments[1];
				var aTopics = new Array();
				for (var i = 2; i< PickupDialog_Invoke.arguments.length; i+=2)
				{
					var j=aTopics.length;
					aTopics[j] = new Object();
					aTopics[j].m_sName=PickupDialog_Invoke.arguments[i];
					aTopics[j].m_sURL=PickupDialog_Invoke.arguments[i+1];
				}

				if (aTopics.length > 1)
				{
					var nWidth = 300;
					var nHeight =180;
					var	nScreenWidth=screen.width;
					var	nScreenHeight=screen.height;
					var nLeft=(nScreenWidth-nWidth)/2;
					var nTop=(nScreenHeight-nHeight)/2;
					if (gbIE4)
					{
						var vRet = window.showModalDialog(sPickupPath,aTopics,"dialogHeight:"+nHeight+"px;dialogWidth:"+nWidth+"px;resizable:yes;status:no;scroll:no;help:no;center:yes;");
						if (vRet)
						{
							var sURL = vRet.m_url;
							if (sFrame)
								window.open(sURL, sFrame);
							else
								window.open(sURL, "_self");
						}
					}
				}
				else if (aTopics.length == 1)
				{
					var sURL = 	aTopics[0].m_sURL
					if (sFrame)
						window.open(sURL, sFrame);
					else
						window.open(sURL, "_self");
				}
			}
		}
	}
}
// Add a hidden layer to simulate scrollbar dragging if this is not a browser that can handle dynamic frame resizing
if (gbBsNS6) {
	var sHTML = "<div id='scrollbarDIV' style='LEFT:10px; WIDTH:3px; POSITION:absolute; TOP:0px; HEIGHT:100%; BACKGROUND-COLOR:lightgrey; visibility:hidden; Z-INDEX:100; BORDER-WIDTH:1px; BORDER-COLOR:darkgray; BORDER-RIGHT-STYLE:solid; BORDER-LEFT-STYLE:solid;'></div>";
	document.write(sHTML);
} else if (gbBsOpera) {
	var sHTML = "<div id='scrollbarDIV' style='LEFT:10px; WIDTH:5px; POSITION:absolute; TOP:0px; HEIGHT:100%; BACKGROUND-COLOR:lightgrey; visibility:hidden; Z-INDEX:100; BORDER-WIDTH:1px; BORDER-COLOR:#A9A9A9; BORDER-RIGHT-STYLE:solid; BORDER-LEFT-STYLE:solid;'></div>";
	document.write(sHTML);
} else if (gbBsNS4) {
	var sHTML = "<layer pagex='-10' pagey='0' width='4' height='100%' name='scrollbarLayer' visibility='hidden' bgcolor='lightgrey' z-index='100'></layer>";
	document.write(sHTML);
}


// Add a hidden layer to load the related topics dialog in
if (gbBsNS4 && !gbBsNS6) 
{
	var sHTML = "<layer pagex='-10' pagey='-10' width='1' height='1' name='relatedTopicsLayer' visibility='hide' z-index='100'></layer>";
}
else 
{
	var sHTML = "<DIV ID='relatedTopicsDIV' STYLE='position:absolute; left:0px; top:0px; z-index:4; visibility:hidden;'></DIV>"
}

document.write(sHTML);

var gRtXPos = 0;
var gRtYPos = 0;
var gRtWidth = 0;
var gRtHeight = 0;
var gsHtml = "";

var CHECK_RELATED_TIMEOUT = 600;
var gsFlashVars = "";
var gbRtLoaded = false;
var gbRtSized = false;
var gbRtOrigMouseDown = null;
var gRtTargetDoc = null;
var gsTargetFrame="";
var gbDivClicked = false;
var gbRtOpened = false;
var gsSwfLoader = "wf_related.swf"
var gsSkinIndexSwf = "skin_index.swf"
var gsSkinIndexFont = "font-family:Arial font-size:10pt font-weight:Normal font-style:Normal text-decoration:none font-color:Black";
var gsSkinIndexHighlight = "font-family:Arial font-size:10pt font-weight:Normal font-style:Normal text-decoration:underline font-color:#004477";
var gsSkinVersion="2.2"

function escapeChar(in_str)
{
	var out_str = in_str;

	out_str = replaceChar(out_str,'%');
	out_str = replaceChar(out_str,'\'');
	out_str = replaceChar(out_str,'&');
	out_str = replaceChar(out_str,'+');
	out_str = replaceChar(out_str,' ');

	return out_str;
}

function replaceChar(in_str, sChar)
{
	var out_str = in_str;
	var temp_str = "";
	var nOldIndex=0;
	var nIndex = out_str.indexOf(sChar);
	while (nIndex >= 0)
	{
		temp_str = out_str.substring(0,nIndex);
		temp_str +="%" + dec2hex(sChar.charCodeAt(0)) ;
		temp_str +=out_str.substring(nIndex+1);
		out_str = temp_str;
		nOldIndex = nIndex;
		nIndex = out_str.indexOf(sChar, nOldIndex+1);
	}
	return out_str;
}

function dec2hex(dec_num)
{
	// This function will convert a dec number <= 255 to a hex string
	var hex_str = "";
	var hexArray = new Array("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F");
	hex_str += hexArray[Math.floor(dec_num/16)];
	hex_str += hexArray[dec_num%16];
	return hex_str;	
}

function wfRelatedTopic(fn_arguments)
{
	var strPath = gsPPath;
	if (gbBsNS4 && !gbBsNS6)
	{
		strPath = escapeChar(gsPPath);
	}
	var argLen = fn_arguments.length;
	var e = fn_arguments[0];

	// Check to Make sure we have a valid number of parameters
	if (argLen < 3) 
	{
		return false;
	}
	
	var targetDoc = null;
	
	if (isInPopup())
	{
		targetDoc = parent;
	}
	else
	{
		targetDoc = this;
	}
	gRtTargetDoc = targetDoc;
	gsTargetFrame = fn_arguments[1];

	// If there is only one topic simply display this topic
	if (argLen <= 4) 
	{
		if (targetDoc != null) 
		{
			targetDoc.location.href = fn_arguments[3];
		}
		else 
		{
			if (fn_arguments[1] != null && typeof(fn_arguments[1]) != "undefined")
			{
				window.open(fn_arguments[3], fn_arguments[1]);
			}
			else
			{
				window.open(fn_arguments[3]);
			}
		}
		return false;
	}
	// Display the popup window
	else
	{
		// If the browser does not support DOM or ILayer open a new window
		if ((gbBsOpera6 && !gbBsOpera7) || gbKonqueror)
		{
			RtWindowCtrl(fn_arguments)
			return;
		}

		// Build the Flash Var List
		var strFlashVars = "";
		strFlashVars += "nItemCount="+argLen;
		strFlashVars += "&gsSkinSwf="+gsSkinIndexSwf;
		strFlashVars += "&gsFont="+gsSkinIndexFont;
		strFlashVars += "&gsFontHighlight="+gsSkinIndexHighlight;

		if (gbBsNS6 || gbBsNS4 || gbSafari)
		{
			strFlashVars += "&nTopicHeight="+(window.innerHeight-16);
		}
		else
		{
			strFlashVars += "&nTopicHeight="+(document.body.offsetHeight-20);
		}
		
		for (var i = 2; i < argLen; i++)
		{
			strFlashVars += "&arrVal"+i+"="+escapeChar(fn_arguments[i]);
		}
		gsFlashVars = strFlashVars;

		// Build the SWF Object
		var sHtml = "";
		if (gbMac && gbBsIE)
		{
			sHtml += "<TABLE STYLE='border:2px outset white;' BGCOLOR=#c0c0c0 id='relatedTopicsTB' width='1px' height='1px' CELLSPACING=0> <TR><TD>";
		}
		var rtWidth = "100%";
		var rtHeight = "100%";
		if ((gbBsNS6 && !gbNav7) || gbMozilla)
		{
			rtWidth = "1";
			rtHeight = "1";
		}

		sHtml += "<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0'";
		sHtml += "id='rlctrlSWF' ALIGN='' WIDTH='"+rtWidth+"' HEIGHT='"+rtHeight+"' VIEWASTEXT>";
		sHtml += "<PARAM NAME='base' value='"+strPath+"'>";
		sHtml += "<PARAM NAME='movie' VALUE='"+strPath+gsSwfLoader+"'>";
		sHtml += "<PARAM NAME=quality VALUE=high>";
		sHtml += "<PARAM NAME=FlashVars VALUE='" + strFlashVars + "'>";
		sHtml += "<EMBED src='"+strPath+gsSwfLoader+"' quality=high  NAME='rlctrlSWF' BASE="+strPath+" swLiveConnect='true' WIDTH='"+rtWidth+"' HEIGHT='"+rtHeight+"' ALIGN='' ";
		sHtml += "FlashVars='" + strFlashVars + "' ";
		sHtml += "TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'>";
		sHtml += "</EMBED>";
		sHtml += "</OBJECT>";
		if (gbMac && gbBsIE)
		{
			sHtml += "</TD></TR></TABLE>\n";
		}

		// Insert the SWF Object
		if (gbBsNS4 && !gbBsNS6) 
		{
			if (gbRtOpened)
			{
				closeRtCtrl();
				if (!gbMac && !gbWindows)
				{
					return;
				}
			}
			gbRtOpened = true;
			// Add an image otherwise NS4 will not render the swf
			sHtml += "<img src='"+strPath+"wf_loadswf.jpg'></img>";	
			gsHtml = sHtml;

			var rtLayer = document.layers["relatedTopicsLayer"];
			rtLayer.document.open();
			rtLayer.document.write(sHtml);
			rtLayer.document.close();
			gRtXPos = e.pageX;
			gRtYPos = e.pageY;
			gbRtSized = false;
			setTimeout("IsRtSized()",CHECK_RELATED_TIMEOUT);
		}
		else
		{
			var rtDiv = null;
			rtDiv = getElement("relatedTopicsDIV");
			rtDiv.style.visibility = "visible";
			rtDiv.innerHTML = sHtml;
			gRtXPos = e.clientX;
			gRtYPos = e.clientY;
			rtDiv.style.top  = 0;
			rtDiv.style.left = 0;
			rtDiv.style.width = 1;
			rtDiv.style.height= 1;
		
		}
		document.onmousedown = RtParentClicked;
		rtDiv.onmousedown = RtDivClicked;
	}
}

function RtDivClicked()
{
	gbDivClicked = true;
}

function sizeRtCtrl(rtWidth, rtHeight)
{
	var strPath = gsPPath;
	if (gbBsNS4 && !gbBsNS6)
	{
		strPath = escapeChar(gsPPath);
	}
	gbRtSized = true;
	rtWidth = Number(rtWidth);
	rtHeight = Number(rtHeight);

	// Get Window Height
	var nHeight = 0;

	if (gbBsNS6 || gbBsNS4 || gbSafari)
	{
		nHeight = window.innerHeight - 16;
	}
	else
	{
		nHeight = document.body.offsetHeight - 20;
	}

	// Set Y Position
	var scrollYOffset = 0;
	if (gbBsNS4 && !gbBsNS7)
	{
		scrollYOffset = window.pageYOffset;
	}
	else
	{
		scrollYOffset = document.body.scrollTop;
	}

	if (!gbBsNS4 || gbBsNS6)
	{
		if ((gRtYPos + rtHeight - scrollYOffset) > nHeight)
		{
			gRtYPos = scrollYOffset + nHeight - rtHeight;
		}
		else
		{
			gRtYPos += scrollYOffset;
			if (gRtYPos+rtHeight > scrollYOffset + nHeight)
			{
				gRtYPos = scrollYOffset + nHeight - rtHeight;
			}
		}
	}
	else
	{
		if (gRtYPos+rtHeight > scrollYOffset + nHeight)
		{
			gRtYPos = scrollYOffset + nHeight - rtHeight;
		}
	}

	// Get Window Width
	var nWidth = 0;

	if (gbBsNS6 || gbBsNS4 || gbSafari)
	{
		nWidth = window.innerWidth - 16;
	}
	else
	{
		nWidth = document.body.offsetWidth - 20;
	}

	// Set X Position
	var scrollXOffset = 0;
	if (gbBsNS4 && !gbBsNS7)
	{
		scrollYOffset = window.pageYOffset;
	}
	else
	{
		scrollXOffset = document.body.scrollLeft;
	}

	if (!gbBsNS4 || gbBsNS6)
	{
		if ((gRtXPos + rtWidth - scrollXOffset) > nWidth)
		{
			gRtXPos = scrollXOffset + nWidth - rtWidth;
		} 
		else 
		{
			gRtXPos += scrollXOffset;
			if (gRtXPos +rtWidth > scrollXOffset + nWidth)
			{
				gRtXPos = scrollXOffset + nWidth - rtWidth;
			}
		}
	}
	else
	{
		if (gRtXPos +rtWidth > scrollXOffset + nWidth)
		{
			gRtXPos = scrollXOffset + nWidth - rtWidth;
		}
	}


	if (gbBsNS4 && !gbBsNS6)
	{
		var rtLayer = document.layers["relatedTopicsLayer"];
		var strFlashVars = gsFlashVars + "&gnNoResize=1";
		gRtWidth = rtWidth;
		gRtHeight = rtHeight;
		// Rebuild flash object with correct width and height
		var sHtml = "";
		sHtml += "<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0'";
		sHtml += "id='rlctrlSWF' ALIGN='' WIDTH='"+rtWidth+"' HEIGHT='"+rtHeight+"' VIEWASTEXT>";
		sHtml += "<PARAM NAME='base' value='"+strPath+"'>";
		sHtml += "<PARAM NAME='movie' VALUE='"+strPath+gsSwfLoader+"'>";
		sHtml += "<PARAM NAME=quality VALUE=high>";
		sHtml += "<PARAM NAME=FlashVars VALUE='" + strFlashVars + "'>";
		sHtml += "<EMBED src='"+strPath+gsSwfLoader+"' quality=high BASE="+strPath+" NAME='rlctrlSWF' swLiveConnect='true' WIDTH='"+rtWidth+"' HEIGHT='"+rtHeight+"' ALIGN='' ";
		sHtml += "FlashVars='" + strFlashVars + "' ";
		sHtml += "TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'>";
		sHtml += "</EMBED>";
		sHtml += "</OBJECT>";

		rtLayer.moveTo( gRtXPos, gRtYPos);
		rtLayer.resizeTo(rtWidth,rtHeight);
		rtLayer.document.open();
		rtLayer.document.write(sHtml);
		rtLayer.document.close();
		gbRtLoaded = false;
		setTimeout("IsRtLoaded()",CHECK_RELATED_TIMEOUT);
	}
	else if ((gbBsNS6 && !gbNav7) || gbMozilla)
	{
		var strFlashVars = gsFlashVars + "&gnNoResize=1";
		gRtWidth = rtWidth;
		gRtHeight = rtHeight;
		// Rebuild flash object with correct width and height
		var sHtml = "";
		sHtml += "<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0'";
		sHtml += "id='rlctrlSWF' ALIGN='' WIDTH='"+rtWidth+"' HEIGHT='"+rtHeight+"' VIEWASTEXT>";
		sHtml += "<PARAM NAME='base' value='"+strPath+"'>";
		sHtml += "<PARAM NAME='movie' VALUE='"+strPath+gsSwfLoader+"'>";
		sHtml += "<PARAM NAME=quality VALUE=high>";
		sHtml += "<PARAM NAME=FlashVars VALUE='" + strFlashVars + "'>";
		sHtml += "<EMBED src='"+strPath+gsSwfLoader+"' quality=high BASE="+strPath+" NAME='rlctrlSWF' swLiveConnect='true' WIDTH='"+rtWidth+"' HEIGHT='"+rtHeight+"' ALIGN='' ";
		sHtml += "FlashVars='" + strFlashVars + "' ";
		sHtml += "TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'>";
		sHtml += "</EMBED>";
		sHtml += "</OBJECT>";

		var rtDiv = null;
		rtDiv = getElement("relatedTopicsDIV");
		// moveTo
		rtDiv.style.top   = gRtYPos;
		rtDiv.style.left  = gRtXPos;
		// resizeTo
		rtDiv.style.width = rtWidth;
		rtDiv.style.height= rtHeight;

		rtDiv.innerHTML = sHtml;
	}
	else 
	{
		if (gbMac && gbBsIE)
		{
			var rtTable = getElement("relatedTopicsTB");
			rtTable.style.height = rtHeight;
			rtTable.style.width = rtWidth;		
		}

		rtDiv = getElement("relatedTopicsDIV");
		rtDiv.style.top   = gRtYPos;
		rtDiv.style.left  = gRtXPos;
		rtDiv.style.width = rtWidth;
		rtDiv.style.height= rtHeight;

		if (!isInPopup())
		{
			if (window.rlctrlSWF)
			{
				if (window.rlctrlSWF.focus)
				{
					window.rlctrlSWF.focus();
				}
			}
		}
	}
}


function IsRtSized()
{
	if (!gbRtSized)
	{
		var rtLayer = document.layers["relatedTopicsLayer"];
		rtLayer.document.open();
		rtLayer.document.write(gsHtml);
		rtLayer.document.close();
		setTimeout("IsRtSized()",CHECK_RELATED_TIMEOUT);
	}
}

function closeRtCtrl()
{
	gbRtOpened = false;
	if (gbBsNS4 && !gbBsNS6)
	{
		if (!gbMac && !gbWindows)
		{
			document.location.reload();
			return;
		}
		var rtLayer = document.layers["relatedTopicsLayer"];
		rtLayer.visibility="hide";
		rtLayer.resizeTo(1,1);
		rtLayer.moveTo( -10, -10);
		rtLayer.document.open();
		rtLayer.document.write("<TABLE>&nbsp;</TABLE>");
		rtLayer.document.close();
	}
	else
	{
		rtDiv = getElement("relatedTopicsDIV");
		rtDiv.innerHTML = "<TABLE>&nbsp;</TABLE>\n";
		rtDiv.style.visibility = "hidden";
	}
}


function RtClicked(strTopicURL)
{
	closeRtCtrl();
	if (gRtTargetDoc != null) 
	{
		if (gsTargetFrame != "")
		{
			gRtTargetDoc.window.open(strTopicURL,gsTargetFrame,"");
		}
		else
		{
			gRtTargetDoc.location.href = strTopicURL;
		}
	}
	else if (gsTargetFrame != "")
	{
		window.open(strTopicURL,gsTargetFrame,"");
	}
	else
	{
		window.location.href = strTopicURL;
	}
}


function IsRtLoaded()
{
	var rtLayer = document.layers["relatedTopicsLayer"];
	if (!gbRtLoaded && rtLayer.visibility !="show")
	{
		sizeRtCtrl(gRtWidth, gRtHeight);
	}
}

function RtLoaded()
{
	gbRtLoaded = true;
	var rtLayer = document.layers["relatedTopicsLayer"];
	rtLayer.visibility = "show";
}

function RtParentClicked()
{
	if (!gbDivClicked)
	{
		document.onmousedown = gbRtOrigMouseDown;
		closeRtCtrl();
	}
	else
	{
		gbDivClicked = false;
	}

	return true;
}

var gPopWnd = null;
var gfn_arguments = null;

function RtWindowCtrl(fn_arguments)
{
	var strPath = gsPPath;
	if (gbBsNS4 && !gbBsNS6)
	{
		strPath = escapeChar(gsPPath);
	}
	gfn_arguments = fn_arguments;
	if (gbBsOpera6 && gbMac && gPopWnd == null)
	{
		var wndOldPopupLinks= window.open(strPath+"wf_blank.htm", "popuptemp");
		wndOldPopupLinks.close();
		setTimeout("RtWindowCtrl2();",100);
	}
	else
	{
		RtWindowCtrl2();
	}
}

function RtWindowCtrl2()
{
	var strPath = gsPPath;
	if (gbBsNS4 && !gbBsNS6)
	{
		strPath = escapeChar(gsPPath);
	}
	var fn_arguments = gfn_arguments;

	if (gPopWnd != null)
	{
		if (gPopWnd.close)
			gPopWnd.close();
		gPopWnd = null;
		setTimeout("RtWindowCtrl2()",100);
		return false;
	}

	var argLen 	= fn_arguments.length;
	var e = fn_arguments[0];

	// Create the window
	var nHeight = 200;
	var nWidth = 200;
	gRtXPos = e.clientX;
	gRtYPos = e.clientY+30;

	var strParam = "titlebar=no,toolbar=no,status=no,location=no,menubar=no,resizable=no,scrollbars=auto";
	strParam += ",height=" + nHeight + ",width="+nWidth;
	strParam += ",left="+ gRtXPos + ",top="+gRtYPos;

	// Build the Flash Var List
	var strFlashVars = "";
	strFlashVars += "nItemCount="+argLen;
	strFlashVars += "&gsSkinSwf="+gsSkinIndexSwf;
	strFlashVars += "&gsFont="+gsSkinIndexFont;
	strFlashVars += "&gsFontHighlight="+gsSkinIndexHighlight;
	strFlashVars += "&nTopicHeight="+nHeight;

	for (var i = 2; i < argLen; i++)
	{
		strFlashVars += "&arrVal"+i+"="+fn_arguments[i];
	}
	gsFlashVars = strFlashVars;
	gbRtSized = false;

	// Create the popup window
	var wndPopupLinks=null;
	wndPopupLinks= window.open(strPath+"wf_related.htm", "popuplinks", strParam);
	gPopWnd = wndPopupLinks;
	return false;
}

var gsWndParams = "";
function ResizeRtWindow(nWidth, nHeight)
{
	var xPos = 100;
	var yPos = 100;
	gPopWnd.close();
	gbRtSized = true;
	var strParam = "titlebar=no,toolbar=no,status=no,location=no,menubar=no,resizable=no,scrollbars=auto";
	strParam += ",height=" + nHeight + ",width="+nWidth;
	strParam += ",left="+ gRtXPos + ",top="+gRtYPos;
	gsWndParams = strParam;

	// Create the popup window
	setTimeout("OpenWindow()",100);


	return false;
}

function OpenWindow()
{
	var strPath = gsPPath;
	if (gbBsNS4 && !gbBsNS6)
	{
		strPath = escapeChar(gsPPath);
	}
	var wndPopupLinks=null;
	wndPopupLinks= window.open(strPath+"wf_related.htm", "popuplinks", gsWndParams);
	gPopWnd = wndPopupLinks;
}
