// Variables used in the file
var dateObj = new Date();
var UniqueIDString = "" + dateObj.getTime();
var gsDefaultFramesetCol = "230, *";
var gsDefaultFramesetRow = "200, *";
// Set the variable for test scenario
if (gsDefaultFramesetRow.substr(0, 2) == "%%") {
	gsDefaultFramesetRow = "300, *";
}
if (gsDefaultFramesetCol.substr(0, 2) == "%%") {
	gsDefaultFramesetCol = "200, *";
}

var gsLastFramesetCol = gsDefaultFramesetCol;
var gsCurFramesetCol = gsDefaultFramesetCol;
var gsLastFramesetRow = gsDefaultFramesetRow;
var gsCurFramesetRow = gsDefaultFramesetRow;
var gbVertical = false;
var gsBrowseSequenceInfo = "";
var gsTOCSyncInfo = "";
var gPoweredByWindow = null;
var gnTopicBGColor = 16777215;
var gbSkinLoaded = false;
var gnScrollbarTimerID = -1;
var gnLastScrollbarWidthRequest = 0;
var gnScrollbarDragOffset = 0;
var gnInitialFrameWidth = 0;
var gnInitialXPos = 0;
var IE_FRAMESET_RESIZE_INTERVAL = 300;
var DIV_MOVE_INTERVAL = 30;
var gsFlashVars="";
var gbCommLoaded=true;
var gbNavReloaded=false;
var gbTbReloaded=false;
var gbReloadNavigationOnly = false;
var gbNavPaneLoaded = false;
var gbToolBarLoaded = false;
var gnMouseOver = -1;
var gnMouseMove = -1;
var gnTimeOutXPos = -1;
var gbMouseTimeOut = false;
var gbHasTitle = false;
var gsNavPane = "wf_blank.htm";
var gsParamPasser = "wf_blank.htm";
var gFrameInterval = null;
//const
var CMD_SHOWTOC=1;
var CMD_SHOWINDEX=2;
var CMD_SHOWSEARCH=3;
var CMD_SHOWGLOSSARY=4;

function CheckFrameRendered()
{
	clearInterval(gFrameInterval);
	gFrameInterval = setTimeout("RerenderFrames()",2000);
}

function RerenderFrames()
{
	var bRerender = true;
	if (window.frames["Content"])
	{
		if (window.frames["Content"].frames)
		{
			if (window.frames["Content"].frames["master"])
			{
				if (window.frames["Content"].frames["master"].DoCommand)
				{
					if (window.frames["comm"])
					{
						bRerender = false;
					}
				}
			}
		}
	}
	if (!bRerender && !window.frames["Content"].frames["master"].gbSWFLoaded && (gbNavPaneLoaded || gbToolBarLoaded))
	{
		bRerender = true;
	}

	if (bRerender)
	{
		window.location.reload();
	}
}

// Funtion to send a command to the master HTML file
function SendCmdToMasterHTML(cmd, param1, param2) {
	if ((window.frames["Content"] != null) && 
	    (window.frames["Content"].frames["master"] != null) &&
	    (window.frames["Content"].frames["master"].DoCommand != null)) 
	{
		window.frames["Content"].frames["master"].DoCommand(cmd, param1, param2);
	}
}

function SendCmdToTopic(cmd, param) {
	if ((window.frames["Content"].frames["bottom"] != null) &&
		(window.frames["Content"].frames["bottom"].frames["Topic Pane"] != null) &&
		(window.frames["Content"].frames["bottom"].frames["Topic Pane"].DoCommand != null)) {
		window.frames["Content"].frames["bottom"].frames["Topic Pane"].DoCommand(cmd, param);
	}
}

function NavigateToTopic(url, target) {
	target = target + "";
	if ((window.frames["Content"].frames["bottom"] != null) && (window.frames["Content"].frames["bottom"].frames["Topic Pane"] != null))
	{
		if (target == "" || target == null || target == "0")
		{
			if (gbNav4 && !gbNav6) 
			{
				// For NS 4, we need to use setTimeout. After changing to use fscommand to communicate with NS 4 from Flash,
				// NS 4 will not perform a change in the URL
				setTimeout("window.frames['Content'].frames['bottom'].frames['Topic Pane'].location='" + url + "'", 100);
				
			} 
			else 
			{
				window.frames["Content"].frames["bottom"].frames["Topic Pane"].location = url;
			}
		}
		else
		{
			if (gbNav4 && !gbNav6) 
			{
				setTimeout("window.open('" + url + "', '" + target + "','')",100);
			}
			else
			{
				window.open(url,target,"");
			}
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

function getBottomElement(elementID) {
	var element = null;
	// See if the browser supports the functions we need to get to the element
	if (window.frames["Content"].frames["bottom"].document.getElementById) {
		element = window.frames["Content"].frames["bottom"].document.getElementById(elementID);
	} else if (window.frames["Content"].frames["bottom"].document.all) {
		element = window.frames["Content"].frames["bottom"].document.all(elementID);
	}
	return element;
}

function ShowNavigationPane(bShow) {

	// Get to the frameset element
	var frameset = getBottomElement("Bottom Frame");

	// Show or hide as appropriate
	if (bShow) {
		if (gbVertical) {
			if (gbNav4 || gbOpera || gbKonqueror || gbSafari) {
				gsCurFramesetRow = gsLastFramesetRow;
				RedoBottomFrame(bShow);
			} else if (gbIE) {
				frameset.rows = gsLastFramesetRow;
			}
		} else {
			if (gbNav4 || gbOpera || gbKonqueror || gbSafari) {
				gsCurFramesetCol = gsLastFramesetCol;
				RedoBottomFrame(bShow);
			} else if (gbIE) {
				frameset.cols = gsLastFramesetCol;
			}
		}
	} else {
		// "frameset.cols" contains a string of the frameset columns
		// You can get and set this value for Netscape but it doesn't re-render
		// the pages so it looks like it has no effect.
		if (gbVertical) {
			if (gbNav4 || gbOpera || gbKonqueror || gbSafari) {
				// For some reason, frameset.rows doesn't work list frameset.cols. So, let's use innerHeight instead.
				gsLastFramesetRow = "" + window.frames["Content"].frames["bottom"].frames["Navigation Pane"].innerHeight + ", *";
				gsCurFramesetRow = "0, *";
				RedoBottomFrame(bShow);
			} else if (gbIE) {
				window.frames["Content"].frames["bottom"].frames["Navigation Pane"].gbNavClosed = true;
				if (gbIE6)
				{
					gsLastFramesetRow = frameset.rows;
				}
				else
				{
					gsLastFramesetRow = "" + window.frames["Content"].frames["bottom"].frames["Navigation Pane"].document.body.clientHeight + ", *";
				}
				frameset.rows = "0, *";
			}
		} else {
		
			if (gbNav4 || gbOpera || gbKonqueror || gbSafari) {
				gsLastFramesetCol = gsCurFramesetCol;
				gsCurFramesetCol = "0, *";
				RedoBottomFrame(bShow);
			} else if (gbIE) {
				gsLastFramesetCol = frameset.cols;
				frameset.cols = "0, *";
			}
		}
	}
	
	return;
}


function PrintCurrent() {
	// Give the topic pane the focus and print
	if (gbNav) {
		window.frames["Content"].frames["bottom"].frames["Topic Pane"].print();
	} else {
		window.frames["Content"].frames["bottom"].frames["Topic Pane"].focus();
		window.print();
	}
}

function SaveState()
{
	gsTopic = window.frames["Content"].frames["bottom"].frames["Topic Pane"].document.location.href; 
}

function RedoBottomFrame(bShow)
{
	// Save the current topic
	SaveState();
	if (gbNavPaneLoaded)
	{
		SendCmdToMasterHTML("CmdNavigationCleanup");
	}
	else
	{
		SendCmdToMasterHTML("CmdNavigationCleanupComplete");
	}
}

function ReloadNavigation() {
	gbReloadNavigationOnly = true;
	RedoBottomFrame(false);
}

function SetVertical(bVertical) {
	gbVertical = bVertical;
}

//////////////////////////////////////////////////////////////////////////////
//
// Frame resizing code
//
// We only want to try to resize the framesets every so often or the browsers
// will fall behind. A timer is set up to achieve this purpose and only the
// last requested size is used when resizing.
//
//////////////////////////////////////////////////////////////////////////////
function BeginMouseCapture()
{
	var topicPane = window.frames["Content"].frames["bottom"].frames["Topic Pane"];

	topicPane.document.onmouseover = MouseOver;
}

function MouseOver(e)
{
	var topicPane = window.frames["Content"].frames["bottom"].frames["Topic Pane"];
	var xMousePos = 0;

	if (!e) 
	{
		e = topicPane.window.event;
	}
	
	if (e.x)
	{
		xMousePos = e.x
	}
	else
	{
		xMousePos = e.pageX;
	}

	gnMouseOver = xMousePos;
	if (gbOpera && gbMac)
	{
		ScrollbarDragStop(gnMouseOver + gnInitialFrameWidth,0);
	}
	topicPane.document.onmouseover = null;
}

function ScrollbarDragStart(x, y) {
	if (gbSafari || (gbMac && gbOpera))
	{
		BeginMouseCapture();
	}

	// Calculate how far the mouse is from the edge of the frameset at the beginning
	if (gbNav4) {
		gnInitialFrameWidth = window.frames["Content"].frames["bottom"].frames["Navigation Pane"].window.innerWidth;
	} else {
		gnInitialFrameWidth = window.frames["Content"].frames["bottom"].frames["Navigation Pane"].document.body.clientWidth;
	}
	gnInitialXPos = x;
	gnScrollbarDragOffset = gnInitialFrameWidth - x;
	
	// Record the position
	gnLastScrollbarWidthRequest = x;

	// Let the topic know about the start drag if necessary. Calculate the coordinates in the topic coordinate space
	var interval = IE_FRAMESET_RESIZE_INTERVAL;
	if (gbNav4 || gbOpera || gbKonqueror || gbSafari) {
		var newX = x - gnInitialFrameWidth;
		SendCmdToTopic("CmdScrollbarDragStart", newX);
		interval = DIV_MOVE_INTERVAL;
	}
	
	// Make an initial call to "resize" the frameset
	ResizeFrameset();

	// Start a timer that will regulate how often the frameset is "resized"
	gnScrollbarTimerID = setInterval("ResizeFrameset()", interval);
}

function MousePos_nsm(e)
{
	var topicPane = window.frames["Content"].frames["bottom"].frames["Topic Pane"];
	var xMousePos = 0;

	if (!e) 
	{
		e = topicPane.window.event;
	}
	
	if (e.x)
	{
		xMousePos = e.x
	}
	else
	{
		xMousePos = e.pageX;
	}

	gnMouseMove = xMousePos;
	topicPane.document.onmousemove = null;	
}



function ScrollbarDragStop(x, y) {
	clearInterval(gnScrollbarTimerID);

	// Resize for Netscape 7 on a MAC
	if (gbNav7 && gbMac && !gbMouseTimeOut)
	{
		var topicPane = window.frames["Content"].frames["bottom"].frames["Topic Pane"];
		gnMouseMove = -1;
		topicPane.document.onmousemove = MousePos_nsm;
		gbMouseTimeOut = true;
		gnTimeOutXPos = x;
		setTimeout("ScrollbarDragStop()",1000)
		return;
	}
	else if (gbNav7 && gbMac && gbMouseTimeOut && (gnMouseMove > -1))
	{
		x = gnMouseMove + gnInitialFrameWidth;
		gnLastScrollbarWidthRequest = gnMouseMove + gnInitialFrameWidth;
		gnMouseMove = -1;
		gbMouseTimeOut = false;		
	}
	else if (gbNav7 && gbMac && gbMouseTimeOut)
	{
		x = gnTimeOutXPos;
		gbMouseTimeOut = false;	
	}

	// Limit the resize down to zero
	if (x < 0) {
		x = 0;
	}
	
	if (gbSafari && gnMouseOver == -1 && !gbMouseTimeOut)
	{
		gnTimeOutXPos = x;
		gbMouseTimeOut = true;
		setTimeout("ScrollbarDragStop()",50);
		return;
	}
	else if (gbSafari && gbMouseTimeOut)
	{
		x = gnTimeOutXPos;
		gbMouseTimeOut = false;		
	}

	gnLastScrollbarWidthRequest = x;
	
	if (gbSafari && gnMouseOver > -1)
	{
		x = gnMouseOver + gnInitialFrameWidth;
		gnLastScrollbarWidthRequest = gnMouseOver + gnInitialFrameWidth;
		gnMouseOver = -1;
	}	

	ResizeFrameset();
	
	// Let the topic know about the stop drag if necessary. Calculate the coordinates in the topic coordinate space
	if (gbNav4 || gbOpera || gbKonqueror || gbSafari) {
		var newX = x - gnInitialFrameWidth;
		SendCmdToTopic("CmdScrollbarDragStop", newX);
	}
	
	// Resize the framesets where necessary
	if (gbNav4 || gbOpera || gbKonqueror || gbSafari) {
		if (gnInitialXPos != x){
			gsCurFramesetCol = (x+gnScrollbarDragOffset) + ", *";
		}
		RedoBottomFrame(false);
	}
}

function ResizeFrameset() {
	if ((gbIE) && (!gbOpera)) {
		// Resize the frames
		var frameWidth = gnLastScrollbarWidthRequest + gnScrollbarDragOffset;
		var frameset = getBottomElement("Bottom Frame");
		frameset.cols = "" + frameWidth + ", *";
	} else if (gbNav4 || gbOpera || gbKonqueror || gbSafari) {
		// Let the topic know where to draw its resize bar
		var newX = gnLastScrollbarWidthRequest - gnInitialFrameWidth;
		SendCmdToTopic("CmdScrollbarDragMove", newX);
	}
}

function ScrollbarDrag(x, y) {
	gnLastScrollbarWidthRequest = x;
}


function IsHideNavEnabledForRemoteURL() {
	if (gbIE) {
		return true;
	} else {
		return false;
	}
}

function IsHideNavEnabled() {
	// We should always be able to resize and thus hide the navpane
	return true;
}


function DoCommand(cmd, param1, param2) {
	switch (cmd) {
		case "CmdCurrentNav":
			gsDefaultTab = param1;
			break;
			
		case "CmdSkinSwfLoaded":
			gbSkinLoaded = true;
			break;

		case "CmdTopicIsLoaded":
		case "CmdTopicDisplayed":
		case "CmdTopicUnloaded":
			SendCmdToMasterHTML(cmd, param1, param2);
			break;
			
		case "CmdSyncTOC":
			// Store the information in case it is requested later
			gsTOCSyncInfo = param1;

			// Send it off
			SendCmdToMasterHTML(cmd, param1, param2);
			break;
			
		case "CmdSyncInfo":
			// Store the information in case it is requested later
			gsTOCSyncInfo = param1;
			break;

		case "CmdBrowseSequenceInfo":
			// Store the information in case it is requested later
			gsBrowseSequenceInfo = param1;
			
			// Send it off
			SendCmdToMasterHTML(cmd, param1, param2);
			break;
			
		case "CmdGetBrowseSequenceInfo":
			// Send it off
			SendCmdToMasterHTML("CmdBrowseSequenceInfo", gsBrowseSequenceInfo);
			break;

		case "CmdTopicBGColor":
			// Store the information in case it is requested later and send it off
			gnTopicBGColor = param1;
			SendCmdToMasterHTML(cmd, param1, param2);
			break;

		case "CmdGetTopicBGColor":
			SendCmdToMasterHTML("CmdTopicBGColor", gnTopicBGColor);
			break;
								
		case "CmdGetSkinFilename":
			SendCmdToMasterHTML("CmdSkinFilename", gsActiveSkinFileName);
			break;

		case "CmdDisplayTopic":
			// Navigate to the proper HTML file
			NavigateToTopic(param1, param2);
			break;

		case "CmdHideNavigation":
			ShowNavigationPane(false);
			break;
	
		case "CmdGetToolbarOrder":
			gbToolBarLoaded = true;
			CheckForPrint();
			SendCmdToMasterHTML("CmdToolbarOrder", gsToolbarOrder);
			break;

		case "CmdGetNavbarOrder":
			SendCmdToMasterHTML("CmdNavbarOrder", gsNavigationElement);
			break;

		case "CmdShowNavigation":
			ShowNavigationPane(true);
			break;
		
		case "CmdGetSyncTOC":
			SendCmdToMasterHTML("CmdSyncTOC", gsTOCSyncInfo, 0);
			break;
		
		case "CmdIsAutoSyncTOCEnabled":
			SendCmdToMasterHTML("CmdAutoSyncTOCEnabled", gbAutoSync);
			break;
			
		case "CmdGetDefaultNav":
			SendCmdToMasterHTML("CmdSelectItem", gsDefaultTab, param1);
			break;
		
		case "CmdSetFocus":
		
			if (param1 == "Navigation") {
				if (window.frames["Content"].frames["bottom"].frames["Navigation Pane"])
				{
					if (window.frames["Content"].frames["bottom"].frames["Navigation Pane"].navpaneSWF) {
						if (window.frames["Content"].frames["bottom"].frames["Navigation Pane"].navpaneSWF.focus)
						{
							window.frames["Content"].frames["bottom"].frames["Navigation Pane"].navpaneSWF.focus();
						}
					}
				}
			} else if (param1 == "Topic") {
				window.frames["Content"].frames["bottom"].frames["Topic Pane"].focus();
			}
			break;
		
		case "CmdPrint":
			PrintCurrent();
			break;
									
		case "CmdInvokePoweredBy":

			// Create a centered window
			var left = (screen.width / 2) - 200;
			var top = (screen.height / 2) - 200;
			var width = 300;
			var height = 200;
			if ((gbNav) && (gbNav4) && (!gbNav6)) {
				width += 10;
				height += 10;
			}

			// Open the window if it is not already open
			if ((gPoweredByWindow == null) || (gPoweredByWindow.closed == true)) {
			
				// Create the parameter list
				var param_str = "uniqueHelpID=" + UniqueID();
				param_str += "&pbpoweredby=" + gsFlashHelpVersion;
				param_str += "&pbgeneratedby=" + gsGeneratorVersion;
				param_str += "&pbaboutlabel="+param1;
				
				// Take different action depending on the browser
				if ((gbIE5 && gbWindows) && (!gbOpera)) {
					height += 30;
					var strWindow = 'dialogWidth:' + width + 'px;dialogHeight:' + height + 'px;resizable:no;status:no;scroll:no;help:no;center:yes;';
					gPoweredByWindow = window.showModelessDialog("wf_poweredby.htm", param_str, strWindow);

				} else if (gbNav4 && !gbNav6) {
				
					// For NS 4, we need to use setTimeout. After changing to use fscommand to communicate with NS 4 from Flash,
					// NS 4 will not perform a window.open of an HTML file during the processing of an fscommand.
					var strURL = "wf_poweredby.htm?" + param_str;
					var strWindow = 'width=' + width + ',height=' + height + ',left=' + left + ',top=' + top;
					setTimeout("window.open('" + strURL + "', 'PoweredByWindow', '" + strWindow + "')", 100);
					
				} else if (gbIE4 && !gbIE5) {

					// Create the window string and add the parameters to the filename
					var strURL = "wf_poweredby.htm#" + param_str;
					var strWindow = 'width=' + width + ',height=' + height + ',left=' + left + ',top=' + top;
					gPoweredByWindow = window.open(strURL, 'PoweredByWindow', strWindow);
				} else {
					// Create the window string and add the parameters to the filename
					var strURL = "wf_poweredby.htm?" + param_str;
					var strWindow = 'width=' + width + ',height=' + height + ',left=' + left + ',top=' + top;
					gPoweredByWindow = window.open(strURL, 'PoweredByWindow', strWindow);
				}
			} else if (gPoweredByWindow != null) {
				gPoweredByWindow.focus();
			}
			break;
			
		case "CmdAskIsTopicOnly":
			param1.isTopicOnly=false;
			break;
			
		case "CmdScrollbarDragStart":
			ScrollbarDragStart(Number(param1), Number(param2));
			break;
			
		case "CmdScrollbarDragStop":
			ScrollbarDragStop(Number(param1), Number(param2));
			break;
			
		case "CmdScrollbarDragMove":
			ScrollbarDrag(Number(param1), Number(param2));
			break;
		
		case "CmdIsNavResizeVisible":
			SendCmdToMasterHTML("CmdNavResizeVisible", 	(gbNav4 || gbOpera) ? 1 : 0);
			break;

		case "CmdNavigationCleanupComplete":
			// Cleanup finished - we can now reload
			gbNavPaneLoaded = false;
			if (gbReloadNavigationOnly) {
				window.frames["Content"].frames["bottom"].frames["Navigation Pane"].window.location.reload();
				gbReloadNavigationOnly = false;
			} else {
				window.frames["Content"].frames["bottom"].window.location.reload();
			}
			break;
		case "CmdNavigationPaneLoaded":
			gbNavPaneLoaded = true;
			break;			
		case "CmdUILoadFailure":
			// Inform the user and load the plain HTML version of the help system
			alert(param1 + " failed to load the following components:\n" + param2 + "\nThe non-Flash version of the help system will be displayed.");
			window.location.replace("wf_njs.htm");
			break;
		
		case "CmdReloadNavigation":
			ReloadNavigation();
			break;

		case "CmdCanFocusBeSet":
			SendCmdToMasterHTML("CmdFocusCanBeSet", ((gbIE && !gbMac) ? true : false));
			break;
		
		case "CmdIsHideNavEnabled":
			SendCmdToMasterHTML("CmdHideNavEnabled", IsHideNavEnabled());
			break;
		
		case "CmdIsHideNavEnabledForRemoteURL":
			SendCmdToMasterHTML("CmdHideNavEnabledForRemoteURL", IsHideNavEnabledForRemoteURL());
			break;
		
		default:
			// See if this is a debug command and send it along to the master
			if (cmd.substr(0, 6) == "debug:") {
				SendCmdToMasterHTML(cmd, param1, param2);
			}
			break;
	}
}

// Create a unique string to ID this instance of the help system
function UniqueID() {
	return UniqueIDString;
}

function TestLoaded(bVert) {
	gbAutoSync = 1;
	gsNavigationElement="Previous|Next|Sync TOC|Hide";
	gsToolbarOrder="Contents|Index|Search|Glossary|Print|SearchInput|Logo/Author";
	gsDefaultTab="Index";
	gsActiveSkinFileName = "skin.xml";
	gsFlashHelpVersion="FlashHelp 1.5";
	gsGeneratorVersion="RoboHelp XX";
	DoCommand("CmdSetFocus","Navigation");
}

// Send the first command - setting the skin filename to the master
function Loaded() {
//	SendCmdToMasterHTML("CmdSkinFilename", gsActiveSkinFileName);
	// Reset the CurFrameset Col & Row because opera will not do this on reload
	gsCurFramesetCol = gsDefaultFramesetCol;
	gsCurFramesetRow = gsDefaultFramesetRow

	DoCommand("CmdSetFocus","Navigation");
}



var gnPans=2;
var gsTopic="welcome_to_fusionreactor.htm";

var gsAutoSync="1";
var gbAutoSync = (gsAutoSync == "1") ? 1 : 0;

var gsNavigationElement="|Hide";
var gsToolbarOrder="Contents|Search|SearchInput|Logo/Author";
var gsDefaultTab="Contents";
var gsActiveSkinFileName="slate.fhs";
var gsLowCaseFileName="1";
var gsFlashHelpVersion="FlashHelp%201.5";
var gsGeneratorVersion="RoboHelp%20X5.0";
var gsResFileName="wfres.xml";
var gsToolbarPaneHeight="50";

// Set a default topic for testing
if (gsTopic.substr(0, 2) == "%%") {
	gsTopic = "wf_topic.htm";
}

if (gsToolbarPaneHeight.substr(0, 2) == "%%") {
	gsToolbarPaneHeight = "50";
}

// Don't show the navigation pane if there is nothing to show
if ((gsToolbarOrder.substr(0, 2) != "%%") &&
	(gsToolbarOrder.indexOf('Contents') == -1) &&
	(gsToolbarOrder.indexOf('Index') == -1) &&
	(gsToolbarOrder.indexOf('Search') == -1) &&
	(gsToolbarOrder.indexOf('Glossary') == -1)) {
	
	if (gbVertical) {
		gsCurFramesetRow = "0, *";
	} else {
		gsCurFramesetCol = "0, *";
	}
}


// Remove the "print" button as a possibility if the print function is not supported
function CheckForPrint() {
	if (!window.print || (gbMac && (gbNav6 && !gbNav7)) || gbOpera) {
		var iPrint = gsToolbarOrder.indexOf("Print");
		if (iPrint != -1) {
			var sNewOrder = gsToolbarOrder.substr(0, iPrint);
			if (gsToolbarOrder.length > iPrint + 5) {
				sNewOrder += gsToolbarOrder.substr(iPrint + 6, gsToolbarOrder.length);
			}
			gsToolbarOrder = sNewOrder;
		}
	}
}

	
if (location.hash.length > 1)
{
	if (location.hash.indexOf("#<") == 0)
	{
		document.location = "whcsh_home.htm#" + location.hash.substring(2);
	}
	else if (location.hash.indexOf("#>>") == 0)
	{
		parseParam(location.hash.substring(3));
	}
	else
	{
		var nPos = location.hash.indexOf(">>");
		if (nPos>1)
		{
			gsTopic = location.hash.substring(1, nPos);
			parseParam(location.hash.substring(nPos+2));
		}
		else
			gsTopic = location.hash.substring(1);

	}
	if (gnPans == 1 && gsTopic)
	{
		var strURL=location.href;
		if (location.hash)
		{
			var nPos=location.href.indexOf(location.hash);
			strURL=strURL.substring(0, nPos);
		}
		if (gbHasTitle)
			document.location=_getPath(strURL)+ "whskin_tw.htm" + location.hash;
		else
			document.location=_getPath(strURL)+ gsTopic;
	}
}

function parseParam(sParam)
{
	if (sParam)
	{
		var nBPos=0;
		do 
		{
			var nPos=sParam.indexOf(">>", nBPos);
			if (nPos!=-1)
			{
				if (nPos>0)
				{
					var sPart=sParam.substring(nBPos, nPos);
					parsePart(sPart);
				}
				nBPos = nPos + 2;
			}
			else
			{
				var sPart=sParam.substring(nBPos);
				parsePart(sPart);
				break;
			}
		} while(nBPos < sParam.length);
	}	
}

function parsePart(sPart)
{
	if(sPart.toLowerCase().indexOf("cmd=")==0)
	{
		gnCmd=parseInt(sPart.substring(4));
		if(gnCmd == CMD_SHOWTOC)
			gsDefaultTab="Contents";
		else if(gnCmd == CMD_SHOWINDEX)
			gsDefaultTab="Index";
		else if(gnCmd == CMD_SHOWSEARCH)
			gsDefaultTab="Search";
		else if(gnCmd == CMD_SHOWGLOSSARY)
			gsDefaultTab="Glossary";
	}
	else if(sPart.toLowerCase().indexOf("cap=")==0)
	{
		document.title=_browserStringToText(sPart.substring(4));
		gbHasTitle=true;
	}
	else if(sPart.toLowerCase().indexOf("pan=")==0)
	{
		gnPans=parseInt(sPart.substring(4));
	}
	else if(sPart.toLowerCase().indexOf("pot=")==0)
	{
		gnOpts=parseInt(sPart.substring(4));
	}
	else if(sPart.toLowerCase().indexOf("pbs=")==0)
	{
		var sRawBtns = sPart.substring(4);
		var aBtns = sRawBtns.split("|");
		for (var i=0;i<aBtns.length;i++)
		{
			aBtns[i] = transferAgentNameToPaneName(aBtns[i]);
		}
		gsRawBtns = aBtns.join("|");
	}
	else if(sPart.toLowerCase().indexOf("pdb=")==0)
	{
		gsDefaultBtn=transferAgentNameToPaneName(sPart.substring(4));
	}
}

function transferAgentNameToPaneName(sAgentName)
{
	if (sAgentName =="toc")
		return "toc";
	else if	(sAgentName =="ndx")
		return "idx";
	else if	(sAgentName =="nls")
		return "fts";
	else if	(sAgentName =="gls")
		return "glo";
	return "";
}
