@echo off
rem Will install tomcat service
setlocal
set JRE_HOME=c:\verian\java10
set CATALINA_HOME=c:\verian\tomcat11

service.bat install

endlocal
