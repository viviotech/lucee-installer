option Explicit

' chris crowe
' 23 September 2000
' www.iisfaq.com - lots more scripts there

Const COMMAND_VIEW    	= 0
Const COMMAND_ADD 	= 1
Const COMMAND_DELETE   	= 2
Const COMMAND_REPLACE 	= 3

Dim ArgDocuments, IISOBJ, ArgComputer, ArgSiteNumber, ObjectPath, ArgCommand, Docs

Sub DisplayUsage
	WScript.Echo "usage: cscript DefaultDocument.vbs"
	WScript.Echo "                [--computer|-c COMPUTER1[,COMPUTER2...]]"
	WScript.Echo "                [--SiteNumber|-n SITENUMBER]"
	WScript.Echo "                [--Add|-a Document1[,Document2...]]"
	WScript.Echo "                [--Delete|-d Document1[,Document2...]]"
	WScript.Echo "                [--Replace|-r Document1[,Document2...]]"
	WScript.Echo "                [--help|-?]"
	WScript.Echo ""
	WScript.Echo "Example 1: DefaultDocument.vbs -n 1 -d ""myDomain"""
	WScript.Echo ""
	WScript.Quit(1)
End Sub

Sub checkCmdLine()
Dim OArgs, ArgNum

Set oArgs = WScript.Arguments
ArgNum = 0

While ArgNum < oArgs.Count

	Select Case LCase(oArgs(ArgNum))
		Case "--computer","-c":
			ArgNum = ArgNum + 1
			if (ArgNum = oArgs.count) then
				Call DisplayUsage()
			end if
			ArgComputer = oArgs(ArgNum)
		Case "--sitenumber","-n":
			ArgNum = ArgNum + 1
			if (ArgNum = oArgs.count) then
				Call DisplayUsage()
			end if
			ArgSiteNumber = CLng(oArgs(ArgNum))
		Case "--Add","-a":
			ArgCommand = COMMAND_ADD
			ArgNum = ArgNum + 1
			if (ArgNum = oArgs.count) then
				Call DisplayUsage()
			end if
			ArgDocuments = oArgs(ArgNum)
		Case "--Delete","-d":
			ArgCommand = COMMAND_DELETE
			ArgNum = ArgNum + 1
			if (ArgNum = oArgs.count) then
				Call DisplayUsage()
			end if
			ArgDocuments = oArgs(ArgNum)
		Case "--Replace","-r":
			ArgCommand = COMMAND_REPLACE
			ArgNum = ArgNum + 1
			if (ArgNum = oArgs.count) then
				Call DisplayUsage()
			end if
			ArgDocuments = oArgs(ArgNum)
		Case "--help","-?":
			Call DisplayUsage
		Case Else:
			WScript.Echo "Unknown argument "& oArgs(ArgNum)
			Call DisplayUsage
	End Select	

	ArgNum = ArgNum + 1
Wend
if (ArgSiteNumber = "") then
	WScript.Echo "Site number not given defaulting to W3SVC/1 which may or may not exist!"
	WScript.Echo
end if
end sub

Sub SplitDefaultDocuments
end Sub

Function DoesDocumentExist(byval Document)
        Dim Pos

	Document = UCase(Document)
	for pos = lbound(Docs) to UBound(Docs)
          if (UCase(Docs(POS)) = Document) then
		DoesDocumentExist = true
		exit function
	  end if
	next
	DoesDocumentExist = false
end function

Sub DoView
	Dim Pos

	WScript.Echo "Default Documents on " & ObjectPath & vbcrlf
        Docs = Split(IISOBJ.DefaultDoc, ",")

	for pos = lbound(Docs) to UBOund(Docs)
          WScript.Echo Docs(POS)
	next
end Sub

Sub DoAdd
	Dim Pos, LocalDocs, currentDocs, DocumentAdded

	CurrentDocs = IISOBJ.DefaultDOC
	LocalDocs = Split(ArgDocuments, ",")

	DocumentAdded = false
	for pos = lbound(LocalDocs) to UBOund(LocalDocs)
        if (DoesDocumentExist(LocalDocs(pos)) = false) then
		if (CurrentDocs > "") then
			CurrentDocs = CurrentDOCS + "," & LocalDocs(POS)
		else
			currentDOCS = LocalDOCS(POS)
		end if
		DocumentAdded = true
              	WScript.Echo "Adding " & LocalDocs(POS)
	else
		WScript.Echo "Skipping " & LocalDocs(POS) & " - Already Exists!"
	end if
	next
	if (DocumentAdded = true) then
		IISOBJ.DefaultDOC = CurrentDOCS
		IISOBJ.SetInfo
		if (ERR <> 0) then
			WScript.Echo "TERMINATING -- Error setting data - " & Err.Description & " (" & Err & ")"
			WScript.Quit(1)
		end if
                IISOBJ.GetInfo
	end if
        WScript.Echo
        DoView()
end Sub

Function DoDeleteItem(Item)
  Dim Pos, NewDocs, Found

  Found = False
  DoDeleteItem = false
  item = ucase(item)
  for pos = lbound(Docs) to ubound(Docs)
    if (ucase(Docs(pos)) = Item) then
       Found = true
       DoDeleteItem= true
    else
       if (NewDocs > "") then
         newDocs = newDocs & "," & Docs(POS)
       else
         newDocs = Docs(Pos)
       end if
    end if
  next
  if (Found = false) then
    WScript.Echo "Not Found - " & Item
  else
    WScript.Echo "Removed " & Item
    Docs = Split(NewDocs, ",")
  end if
end Function

Sub doDelete
	Dim xpos, Pos, Found, LocalDocs, newDocs, DocumentRemoved

	LocalDocs = Split(ArgDocuments, ",")

        DocumentRemoved = false
	for pos = lbound(LocalDocs) to UBOund(LocalDocs)
            if (DoDeleteItem(Localdocs(POS)) = true) then
               DocumentRemoved = true
            end if
   	next
	if (DocumentRemoved = true) then
                NewDocs = ""
                for pos = lbound(Docs) to UBOund(Docs)
                    if (Pos < Ubound(Docs)) then
                      NewDocs = NewDocs & Docs(Pos) & ","
                    else
                      NewDocs = newDocs & Docs(Pos)
                    end if
                next
                WScript.Echo "NewDocs = " & NewDocs

		IISOBJ.DefaultDOC = newDocs
		IISOBJ.SetInfo
		if (ERR <> 0) then
			WScript.Echo "TERMINATING -- Error setting data - " & Err.Description & " (" & Err & ")"
			WScript.Quit(1)
		end if
                ' Refresh the data
                IISOBJ.GetInfo
	end if
        WScript.Echo
        DoView()
end Sub

Sub DoReplace
  Dim Pos

  For pos = lbound(docs) to ubound(docs)
    WScript.Echo "Adding " & Docs(pos)
  next
  IISOBJ.DefaultDOC = ArgDocuments
  IISOBJ.SetInfo
  if (ERR <> 0) then
    WScript.Echo "TERMINATING -- Error setting data - " & Err.Description & " (" & Err & ")"
    WScript.Quit(1)
  end if
  ' Refresh the data
  IISOBJ.GetInfo
  WScript.Echo
  DoView()
end sub


ArgComputer   = "localHost"
ArgSiteNumber = "0"
ArgCommand    = COMMAND_VIEW

CheckCmdLine()

'on error resume next

' EDIT BY Jordan Michaels (jordan@viviotech.net)
' if site number is 0 make config global
if (ArgSiteNumber = "0") then
  ObjectPath = "IIS://" & ArgComputer & "/W3SVC"
else
  ObjectPath = "IIS://" & ArgComputer & "/W3SVC/" & ArgSiteNumber
end if
' END EDIT

SET IISOBJ = getObject(ObjectPath)
If (Err <> 0) Then
	WScript.Echo "TERMINATING --- Error accessing " & ObjectPath & " " & Err.Description & " (" & Err & ")"
	wscript.quit(2)
End If

Docs = Split(IISOBJ.DefaultDoc, ",")
Select case argCommand
   case COMMAND_VIEW    : doView
   case COMMAND_ADD     : doAdd
   case COMMAND_DELETE  : doDelete
   case COMMAND_REPLACE : doReplace
end select
