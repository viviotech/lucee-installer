''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' 
'  Macromedia Flash Dispatcher -- a scriptable detector for Flash Player
' 
' 
'  copyright (c) 2000 Macromedia, Inc.
' 
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


' Check for the Flash ActiveX control.
'
' This script will be ignored by browsers that do not support
' VBScript (although Microsoft Internet Explorer will warn the
' user that a script in an unsupported language has been
' encountered if the user has checked "Show unsupported scripting
' language errors" in Preferences->Web Browser->Web Content).
'
' This technique due to Jeff Brown and Rafael M. Muñoz of
' Microsoft Corporation.  Version testing adapted from Macromedia
' Flash Technical Note #12853.

Private i, x

On Error Resume Next

MM_FlashControlInstalled = False

For i = 6 To 1 Step -1
   Set x = CreateObject("ShockwaveFlash.ShockwaveFlash." & i)

   MM_FlashControlInstalled = IsObject(x)

   If MM_FlashControlInstalled Then
       MM_FlashControlVersion = CStr(i)
       Exit For
   End If
Next
