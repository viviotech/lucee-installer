@echo off
rem iis6connect.bat
rem ----------------------------------------------------------------------------------------------------
rem This file was created by the Vivio Installer to make it easy to connect a CFML server
rem   in Tomcat to IIS6.
rem ----------------------------------------------------------------------------------------------------
cscript.exe @@installdir@@\connector\iis6isapifilter.js -site:W3SVC -name:CFML -action:add -dll:@@installdir@@\connector\isapi_redirect-1.2.30.dll
cscript.exe C:\WINDOWS\system32\iisext.vbs /AddFile @@installdir@@\connector\isapi_redirect-1.2.30.dll 1 CFML 1 CFML
cscript.exe C:\WINDOWS\system32\iisvdir.vbs /create "Default Web Site" jakarta @@installdir@@\connector\
cscript.exe C:\inetpub\adminscripts\adsutil.vbs set w3svc/1/root/jakarta/AccessExecute true
cscript.exe @@installdir@@\connector\chglist.vbs W3SVC/ScriptMaps "" ".cfm,@@installdir@@\connector\isapi_redirect-1.2.30.dll,5,GET,HEAD,POST,TRACE" /INSERT /COMMIT
cscript.exe @@installdir@@\connector\iis6defaultdoc.vbs -a "index.cfm" -n 0
cscript.exe @@installdir@@\connector\iis6defaultdoc.vbs -a "index.cfm" -n 1
iisreset
