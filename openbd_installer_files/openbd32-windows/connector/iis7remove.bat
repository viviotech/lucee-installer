@echo off
rem iis7remove.bat
rem ----------------------------------------------------------------------------------------------------
rem This file was created by the Vivio Installer to make it easy to DISconnect a CFML server in Tomcat to IIS7.
rem ----------------------------------------------------------------------------------------------------
%windir%\system32\inetsrv\appcmd.exe delete vdir "Default Web Site/jakarta"
%windir%\system32\inetsrv\appcmd.exe set config -section:isapiFilters /-[name='OpenBD',path='@@installdir@@\connector\isapi_redirect-1.2.30.dll']
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/security/isapiCgiRestriction /-"[path='@@installdir@@\connector\isapi_redirect-1.2.30.dll',allowed='True',description='OpenBD-Tomcat Extension']" /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config /section:handlers -accessPolicy:Read,Script
%windir%\system32\inetsrv\appcmd.exe set config /section:handlers /-[name='CFML',path='*.cfm',verb='*',modules='IsapiModule',scriptProcessor='@@installdir@@\connector\isapi_redirect-1.2.30.dll',requireAccess='None']
%windir%\system32\inetsrv\appcmd.exe set config /section:defaultDocument /-files.[value='index.cfm']
iisreset
