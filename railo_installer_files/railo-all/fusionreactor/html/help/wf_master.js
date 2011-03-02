
function Command(cmd, param1, param2) {
	this.cmd = cmd;
	this.param1 = param1;
	this.param2 = param2;
}

var arrayQueuedCommandsForSWF = new Array();
var gbSWFLoaded = false;
var QUEUE_CHECK_TIMEOUT = 300;
var PARAM_PASSER_TIMEOUT = 2000;
var gFailedParamResponse = 0;
var CHECK_LOAD_FAILURE_TIMEOUT = 10000;
var gLoadFailure = null;
var gnFailureCount = 0;
var gnLastIndex = -1;
var gbSync = true;
var gParamInterval = null;
var gbParamLoaded = false;
var gnParamFailedCount = 0;

// decrease load failure timeout for NS4
if (gbNav4 && !gbNav6)
{
	CHECK_LOAD_FAILURE_TIMEOUT = 2000;
	if (!gbWindows && !gbMac)
	{
		gParamInterval = setInterval("CheckParamPasser()",1000);
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Mozilla IE emulator script to allow Mozilla to handle the "insertAdjacentHTML"
// function call.
//
// for Netscape 6/Mozilla by Thor Larholm thor@jscript.dk
//
///////////////////////////////////////////////////////////////////////////////////////
if ((typeof HTMLElement != "undefined") && (!HTMLElement.prototype.insertAdjacentElement)) {
	HTMLElement.prototype.insertAdjacentElement = function(where,parsedNode) {
		switch (where){
		case 'beforeBegin':
			this.parentNode.insertBefore(parsedNode,this)
			break;
		case 'afterBegin':
			this.insertBefore(parsedNode,this.firstChild);
			break;
		case 'beforeEnd':
			this.appendChild(parsedNode);
			break;
		case 'afterEnd':
			if (this.nextSibling) this.parentNode.insertBefore(parsedNode,this.nextSibling);
			else this.parentNode.appendChild(parsedNode);
			break;
		}
	}

	HTMLElement.prototype.insertAdjacentHTML = function(where,htmlStr) {
		var r = this.ownerDocument.createRange();
		r.setStartBefore(this);
		var parsedHTML = r.createContextualFragment(htmlStr);
		this.insertAdjacentElement(where,parsedHTML);
	}
}

function ResetFrames()
{
	if (gbIE && gbMac)
	{
		if (parent.parent.getBottomElement)
		{
			var frameset = parent.parent.getBottomElement("Bottom Frame");
			if (parent.parent.gbVertical)
			{
				frameset.rows = parent.parent.gsDefaultFramesetRow;
			}
			else
			{
				frameset.cols = parent.parent.gsDefaultFramesetCol;
			}
		}
	}
	parent.parent.gsLastFramesetCol = parent.parent.gsDefaultFramesetCol;
	parent.parent.gsCurFramesetCol = parent.parent.gsDefaultFramesetCol;
	parent.parent.gsLastFramesetRow = parent.parent.gsDefaultFramesetRow;
	parent.parent.gsCurFramesetRow = parent.parent.gsDefaultFramesetRow;
	parent.parent.gbNavPaneLoaded = false;
	gbParamLoaded = false;
	gbSWFLoaded = false;
	parent.parent.gsFlashVars = "";
	parent.parent.gsNavPane = "wf_blank.htm";
	if (window.location.href)
		window.location.href = "wf_blank.htm";
}

if (!(gbNav4 && !gbNav6 && gbWindows))
{
	if (!gbKonqueror)
	{
		window.onunload = ResetFrames;
	}
}

function Loaded()
{
}

// Command to handle the calls from VB script
function masterSWF_DoFSCommand(command, args) {
	var param1 = "";
	var param2 = "";
	var msgIndex = "";
	var params = "" + args; // on Netscape 'args' is an object so convert it to a string
	if (params.indexOf("\n") > 0) {
		msgIndex = params.substring(0, params.indexOf("\n"));
		params = params.substring(params.indexOf("\n")+1);
		param1 = params.substring(0, params.indexOf("\n"));
		param2 = params.substring(params.indexOf("\n") + 1, params.length);
	}
	var cmd = "" + command; // on Netscape 'command' is an object so convert it to a string
	DoSwfCommand(cmd, msgIndex, param1, param2);
}

function CheckNavLoaded()
{
	gnFailureCount++;
	if (gnFailureCount >= 10)
	{
		// add 2 seconds if we fail 10 times incase this is a slow connection
		gnFailureCount = 0;
		CHECK_LOAD_FAILURE_TIMEOUT+=2000; 	
	}
	if (gbNav4 && !gbNav6 && gbWindows)
	{
		parent.parent.window.frames["Content"].window.frames["bottom"].window.frames["Navigation Pane"].window.location.href = "wf_navpane.htm";
	}
	else
	{
		parent.parent.window.frames["Content"].window.frames["bottom"].window.frames["Navigation Pane"].window.location.replace("wf_navpane.htm");
	}
	if (gbOpera)
	{
		parent.parent.window.frames["Content"].window.frames["bottom"].window.location.reload();
	}
	gLoadFailure = setTimeout("CheckNavLoaded()",CHECK_LOAD_FAILURE_TIMEOUT);
}


function DoSwfCommand(cmd, msgIndex, param1, param2)
{
	msgIndex = Number(msgIndex);

	if (msgIndex != (gnLastIndex + 1) && gbSWFLoaded)
	{
		// make sure we still execute the cmd CmdParamPasserLoaded so we do not get into a deadlock
		if (cmd == "CmdParamPasserLoaded")
		{
			DoCommand(cmd, param1, param2);
		}
		if (gbSync)
		{
			gbSync = false;
			var msgCount = arrayQueuedCommandsForSWF.length;

			if (msgCount == 0)
			{
				SendCmdToMasterSWF("CmdResendMessages",gnLastIndex + 1);
			}
			else
			{
				var tempArray = new Array();
				tempArray[0] = new Command("CmdResendMessages",gnLastIndex + 1, "");
				var j = 1;
				for (var i = 0; i < msgCount; i++)
				{
					tempArray[j] = arrayQueuedCommandsForSWF[i];
					j++;
				}
				arrayQueuedCommandsForSWF = tempArray;				
			}
		}
	}
	else if (!gbSWFLoaded && cmd == "CmdMasterLoaded")
	{
		gbSync = true;
		gnLastIndex = msgIndex;
		DoCommand(cmd, param1, param2);		
	}
	else if (gbSWFLoaded)
	{
		gbSync = true;
		gnLastIndex = msgIndex;
		DoCommand(cmd, param1, param2);
	}
}

function DoCommand(cmd, param1, param2) {
	switch (cmd) {
		case "CmdError":
			alert(param1);
			break;
		case "CmdTopicIsLoaded":
		case "CmdSkinFilename":
		case "CmdToolbarOrder":
		case "CmdTopicBGColor":
		case "CmdSyncTOC":
		case "CmdBrowseSequenceInfo":
		case "CmdTopicDisplayed":
		case "CmdTopicUnloaded":
		case "CmdSelectItem":
		case "CmdNavigationCleanup":	
		case "CmdNavbarOrder":
		case "CmdNavResizeVisible":
		case "CmdAutoSyncTOCEnabled":
		case "CmdFocusCanBeSet":
		case "CmdHideNavEnabled":
		case "CmdHideNavEnabledForRemoteURL":
			SendCmdToMasterSWF(cmd, param1, param2);
			break;
			
		case "CmdDisplayTopic":
		case "CmdNavigationCleanupComplete":
		case "CmdGetSyncTOC":
		case "CmdInvokePoweredBy":
		case "CmdHideNavigation":
		case "CmdShowNavigation":
		case "CmdGetToolbarOrder":
		case "CmdGetNavbarOrder":
		case "CmdGetDefaultNav":
		case "CmdGetBrowseSequenceInfo":
		case "CmdSetFocus":
		case "CmdPrint":
		case "CmdGetTopicBGColor":
		case "CmdScrollbarDragStart":
		case "CmdScrollbarDragMove":
		case "CmdScrollbarDragStop":
		case "CmdCurrentNav":
		case "CmdIsNavResizeVisible":
		case "CmdUILoadFailure":
		case "CmdIsAutoSyncTOCEnabled":
		case "CmdCanFocusBeSet":
		case "CmdIsHideNavEnabled":
		case "CmdIsHideNavEnabledForRemoteURL":
			// Pass the command along to the parent
			SendCmdToParentHTML(cmd, param1, param2);
			break;
		
		case "CmdNavigationPaneLoaded":
			clearInterval(gLoadFailure);
			SendCmdToParentHTML(cmd, param1, param2);
			gnFailureCount = 0;
			break;
		case "CmdGetSkinFilename":
			SendCmdToParentHTML(cmd, param1, param2);
			break;
			
		case "CmdMasterLoaded":
			if (!gbSWFLoaded) {
				gbSWFLoaded = true;
				SendCmdToMasterSWF("CmdGotMasterLoaded");
			}
			break;
			
		case "CmdSkinSwfLoaded":
			parent.parent.gsNavPane = "wf_navpane.htm";
			if (gbNav4 && !gbNav6)
			{
				setTimeout("parent.parent.window.frames['Content'].window.frames['bottom'].window.frames['Navigation Pane'].window.location.replace('wf_navpane.htm')", 100);
			}
			else
			{
				parent.parent.window.frames["Content"].window.frames["bottom"].window.frames["Navigation Pane"].window.location.replace("wf_navpane.htm");
			}
			gLoadFailure = setTimeout("CheckNavLoaded()",CHECK_LOAD_FAILURE_TIMEOUT);
			break;
			
		case "CmdParamPasserLoaded":
			gbParamLoaded = true;
			clearInterval(gParamInterval);
			parent.parent.gbCommLoaded = true;
			CheckCommandQueues();
			break;
		
		default:
			// See if this is a debug command and send it along to the master SWF
			if (cmd.substr(0, 6) == "debug:") {
				SendCmdToMasterSWF(cmd, param1, param2);
			}
			break;
	}
	
	return;
}



function SendCmdToParentHTML(cmd, param1, param2) {
	parent.parent.DoCommand(cmd, param1, param2);
}

function CheckParamPasser()
{
	parent.parent.window.frames["comm"].window.location.reload();
	if (!gbParamLoaded && gnParamFailedCount > 5)
	{
		parent.parent.window.location.reload();
	}
	gnParamFailedCount++;
}

function CheckCommandQueues() {
	// See if the SWF file is ready to receive commands
	if (gbSWFLoaded) {
		clearInterval(cmdTimerID);

		// If we are not using the ParamPasser Swf send all the messages at once
		if (gbWindows && !gbOpera && !gbMozilla && (gbIE || (gbNav4 && !gbNav6) || gbNav7))
		{
			var msgCount = arrayQueuedCommandsForSWF.length;
			for (var iCmd = 0; iCmd < msgCount; iCmd++) {
				var queuedCmd = arrayQueuedCommandsForSWF[iCmd];
				SendCmdToMasterSWF(queuedCmd.cmd, queuedCmd.param1, queuedCmd.param2, true);
				delete queuedCmd;
			}
			arrayQueuedCommandsForSWF.length = 0;
		}
		else if (parent.parent.gbCommLoaded) 
		{
			var msgCount = arrayQueuedCommandsForSWF.length;

			if (msgCount >= 1)
			{
				var queuedCmd = arrayQueuedCommandsForSWF[0];
				SendCmdToMasterSWF(queuedCmd.cmd, queuedCmd.param1, queuedCmd.param2, true);
				delete queuedCmd;
			}

			if ( msgCount > 1 )
			{
				var tempArray = new Array();
				var j = 0;
				for (var i = 1; i < msgCount; i++)
				{
					tempArray[j] = arrayQueuedCommandsForSWF[i];
					j++;
				}
				arrayQueuedCommandsForSWF = tempArray;
			}
			else
			{
				arrayQueuedCommandsForSWF.length = 0;
			}
		}
	}	

	return;
}


// Start the timer for dequeing commands
// var cmdTimerID = window.setInterval("CheckCommandQueues()", QUEUE_CHECK_TIMEOUT);

////////////////////////
// FLASH TO JS COMMUNICATION
function SendCmdToMasterSWF(cmd, param1, param2, bFromQueue) {
	if (arguments.length < 4) 
	{
		bFromQueue = false;
	}

	if (!bFromQueue)
	{
		// See if the SWF is ready for commands and it has been enough time since the last one
		if (!gbSWFLoaded || !parent.parent.gbCommLoaded || arrayQueuedCommandsForSWF.length > 0) {
			// SWF is not ready - add it to the queue
			var newCmd = new Command(cmd, param1, param2);
			arrayQueuedCommandsForSWF[arrayQueuedCommandsForSWF.length] = newCmd;
			return;
		}
	}

	// First, let's handle the simple cases when the Flash/browser combination can handle SetVariable
	if (gbWindows && !gbOpera && !gbMozilla && (gbIE || (gbNav4 && !gbNav6) || gbNav7)) {
		window.document.masterSWF.SetVariable("Param1NewCommand", param1);
		window.document.masterSWF.SetVariable("Param2NewCommand", param2);
		window.document.masterSWF.SetVariable("paramListener.NewCommand", cmd);

	} else {	
		// Make sure the parameters don't contain single quotes that would mess up the string construction below
		if (typeof(param1) == "string") {
			var searchExp = /\x27/;
			param1 = param1.replace(searchExp, "\\x27");
			searchExp = /\x22/;
			param1 = param1.replace('"', "\\x22");
		}
		if (typeof(param2) == "string") {
			var searchExp = /\x27/;
			param2 = param2.replace(searchExp, "\\x27");
			searchExp = /\x22/;
			param2 = param2.replace('"', "\\x22");
		}
		
		// OK, so SetVariable is not supported so we need to create a temporary Flash OBJECT
		// used to pass variables.
		var strPitcher;
		var strFlashVars;

		// Build up the variable string we will be sending
		strFlashVars = "Param1NewCommand=" + param1 + "&Param2NewCommand=" + param2 + "&NewCommand=" + cmd;
		strFlashVars += "&uniqueHelpID=" + parent.UniqueID();
		
		// Build tag to document.write
		strPitcher = "<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0'";
		strPitcher += "WIDTH='1' HEIGHT='1' id='WFParamPasser' ALIGN=''>";
		strPitcher += "<PARAM NAME=movie VALUE='wf_param_passer.swf'> <PARAM NAME=quality VALUE=high> <PARAM NAME=bgcolor VALUE=#FFFFFF>";
		
		// FlashVars for Object tag:
		strPitcher += "<PARAM NAME=FlashVars VALUE='" + strFlashVars + "'>";
		strPitcher += "<EMBED src='wf_param_passer.swf' quality=high bgcolor=#FFFFFF  WIDTH='1' HEIGHT='1' NAME='WFParamPasser' ALIGN='' ";
		
		// FlashVars for Embed tag:
		strPitcher += "FlashVars='" + strFlashVars + "' ";
		strPitcher += "TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'></EMBED></OBJECT>";

/*	Comment out all other methods, the frame method should work in all browsers without bloating the size of the page
		// Now output the temporary object
		if ((gbIE && gbMac) || gbNav6) {
			document.body.insertAdjacentHTML("beforeEnd", strPitcher);

		} else if (gbSafari) {

			divSender.innerHTML = strPitcher;
		
		} else if (gbMac && gbOpera) {

			
			// THIS WAS AN ATTEMPT TO MAKE IT WORK ON OPERA MAC - DID NOT WORK FOR THAT BROWSER
			var strEmbed = "<EMBED src='ErikPitcher.swf' quality=high bgcolor=#FFFFFF  WIDTH='2' HEIGHT='2' NAME='ErikPitcher' ALIGN='' FlashVars='" + strFlashVars + "'TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'>";
			var d = document.getElementById("divSender");
			var oEmbed = document.createElement(strEmbed);
			d.firstChild.removeNode(true);
			d.appendChild(oEmbed);
			
			
			
			//IFRAME FOR OPERA MAC - THIS WORKS BUT THERE MAY BE A BETTER WAY...
			var strFullPage = "<html><body bgcolor=red margin=0>" + strPitcher;
			strFullPage += "</body></html>";
			ifSender.document.open();
			ifSender.document.write(strFullPage);
			ifSender.document.close();
		}
		else */
		{
			clearInterval(gParamInterval);
			gParamInterval = setInterval("CheckParamPasser()",PARAM_PASSER_TIMEOUT);
			gFailedParamResponse = 0;
			parent.parent.gsFlashVars = strFlashVars;
			parent.parent.gbCommLoaded = false;
			parent.parent.window.frames["comm"].window.location.reload();
		}

	}
	
	return;
}

function CancelParamPasser()
{
	if (!(gbIE && !gbMac)) {

	// Kill the pitcher movie. This is called after the LocalConnection message has been sent.
	// May not need to do this...
	}
	
}


///////////////////////////////////////////////////////////////////////////////////////
//
//  DEBUG FUNCTIONS
//
//
///////////////////////////////////////////////////////////////////////////////////////
/*
function OutputTrace(msg) {
	debugdiv = document.all["DebugDiv"];
	if (debugdiv != null) {
		debugdiv.innerHTML += msg;
		debugdiv.innerHTML += "<br>";
	}
}
*/