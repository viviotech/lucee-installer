@ECHO OFF
REM -------------------------------------------------------------------------------------------
REM This script is an example of how to use the Crash Protection script functionality of
REM FusionReactor to automatically restart a monitored ColdFusion MX 7 server running on a
REM Windows machine.
REM
REM To use this script you have to
REM
REM  - have enterprise licenses for the FusionReactor instances
REM  - have the Windows SC utility installed on both machines
REM  - have the monitored FusionReactor instance configured in 'Enterprise->Manage Servers'
REM  - add the path to this script in the Script field of 'Modify Server'
REM  - define appropriate values for the parameters (see below) used by the script.
REM
REM For additional information about the SC command see
REM http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/sc.mspx?mfr=true
REM
REM If you need Windows authentication to be passed you can use the free tool PsService provided
REM by Microsoft (formerly SysInternals) instead of the SC utility. See
REM http://technet.microsoft.com/en-us/sysinternals/bb897542.aspx
REM -------------------------------------------------------------------------------------------


REM -------------------------------------------------------------------------------------------
REM Script arguments
REM -------------------------------------------------------------------------------------------
REM When a FusionReactor Crash Protection event triggers a call to the script the following
REM command line arguments are passed to the script:

REM Argument        Value
REM -------------------------------------------------------------------------------------------
REM status          Either 'DOWN' or 'UP'
REM InstanceName    The name of the FusionReactor instance that caused the CP event
REM InstanceIP      The IP address of the FusionReactor instance that caused the CP event
REM PID             The process id
REM LastSeen        The timestamp of event
REM -------------------------------------------------------------------------------------------



REM -------------------------------------------------------------------------------------------
REM Please change the values below according to your environment
REM -------------------------------------------------------------------------------------------

REM Output of the script is written to the following file
REM -------------------------------------------------------------------------------------------
set LOGFILE=C:\FusionReactor\etc\cp\Restart-Coldfusion7-OnWindows.log
REM -------------------------------------------------------------------------------------------

REM The hostname or IP address to connect
REM -------------------------------------------------------------------------------------------
set HOST=%3
REM -------------------------------------------------------------------------------------------

REM The domain, username and password - you have to change these values accordingly
REM -------------------------------------------------------------------------------------------
set USER=domain\user
set PWD=password
REM -------------------------------------------------------------------------------------------

REM The command to execute
REM -------------------------------------------------------------------------------------------
REM set COMMAND=sc \\%HOST% start "Macromedia JRun CFusion Server"
set COMMAND=sc \\%HOST% start "ColdFusion MX 7 Application Server"
REM -------------------------------------------------------------------------------------------

REM The number of seconds (grace period) before the command will be executed
REM -------------------------------------------------------------------------------------------
set GRACE_PERIOD=10
REM -------------------------------------------------------------------------------------------


REM -------------------------------------------------------------------------------------------
REM Below is the actual script. No changes should be required. Note: The ping command is used
REM to simulate the sleep command, which is unfortunately not available per default on all
REM Windows versions.
REM -------------------------------------------------------------------------------------------
echo Status[%1] InstanceName[%2] InstanceIp[%3] PID[%4] LastSeen[%5] >> %LOGFILE%
if NOT "%1"=="DOWN" goto end

:start
if "%4" == "-1" goto run
if "%4" == "0" goto run
if "%4" == "" goto run

:kill
echo Terminating process %4... >> %LOGFILE%
taskkill /S %HOST% /U %USER% /P %PWD% /F /PID %4 >> %LOGFILE% 2>&1

echo Waiting %GRACE_PERIOD% seconds before trying to start the server... >> %LOGFILE%
@ping 127.0.0.1 -n 2 -w 1000 > nul
@ping 127.0.0.1 -n %GRACE_PERIOD% -w 1000 > nul

:run
echo Restarting server... >> %LOGFILE%
%COMMAND% >> %LOGFILE% 2>&1

:end
