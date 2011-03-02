@echo off
rem iis6remove.bat
rem ----------------------------------------------------------------------------------------------------
rem This file was created by the Vivio Installer to make it easy to DISconnect a CFML server
rem   in Tomcat to IIS6.
rem ----------------------------------------------------------------------------------------------------
cscript.exe @@installdir@@\connector\iis6isapifilter.js -site:W3SVC -name:CFML -action:remove
cscript.exe C:\WINDOWS\system32\iisext.vbs /rmfile @@installdir@@\connector\isapi_redirect-1.2.30.dll
cscript.exe C:\WINDOWS\system32\iisvdir.vbs /delete "Default Web Site/jakarta" @@installdir@@\connector\
cscript.exe @@installdir@@\connector\chglist.vbs W3SVC/ScriptMaps ".cfm" "" /REMOVE /RECURSE /ALL /COMMIT
cscript.exe @@installdir@@\connector\iis6defaultdoc.vbs -d "index.cfm" -n 0
cscript.exe @@installdir@@\connector\iis6defaultdoc.vbs -d "index.cfm" -n 1
iisreset
