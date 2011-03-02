@echo off
rem CD to our proper home directory
cd ..
set CATALINA_HOME=%cd%
rem update the tomcat service to start automatically
set EXECUTABLE=%CATALINA_HOME%\bin\tomcat6.exe
set SERVICE_NAME=Railo
"%EXECUTABLE%" //US//%SERVICE_NAME% --Startup=auto
echo %SERVICE_NAME% will now Auto Start
