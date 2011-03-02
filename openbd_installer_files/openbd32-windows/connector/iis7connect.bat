@echo off
rem iis7connect.bat
rem ----------------------------------------------------------------------------------------------------
rem This file was created by the Vivio Installer to make it easy to connect a CFML server in Tomcat to IIS7.
rem ----------------------------------------------------------------------------------------------------
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/security/isapiCgiRestriction /+"[path='@@installdir@@\connector\isapi_redirect-1.2.30.dll',allowed='True',description='OpenBD-Tomcat Extension']" /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config -section:isapiFilters /+[name='OpenBD',path='@@installdir@@\connector\isapi_redirect-1.2.30.dll']
%windir%\system32\inetsrv\appcmd.exe add vdir /app.name:"Default Web Site/" /path:/jakarta /physicalPath:@@installdir@@\connector\
%windir%\system32\inetsrv\appcmd.exe set config -section:handlers -accessPolicy:Read,Script,Execute
%windir%\system32\inetsrv\appcmd.exe set config /section:handlers /+[name='CFML',path='*.cfm',verb='*',modules='IsapiModule',scriptProcessor='@@installdir@@\connector\isapi_redirect-1.2.30.dll',requireAccess='None']
%windir%\system32\inetsrv\appcmd.exe set config /section:defaultDocument /+files.[value='index.cfm']
iisreset
