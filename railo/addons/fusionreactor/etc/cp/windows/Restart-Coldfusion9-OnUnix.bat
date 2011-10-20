@ECHO OFF
REM -------------------------------------------------------------------------------------------
REM This script is an example of how to use the Crash Protection script functionality of
REM FusionReactor to automatically restart a ColdFusion 9 server running on a remote Unix
REM machine from Windows.
REM
REM To use this script you have to
REM
REM  - have enterprise licenses for the FusionReactor instances
REM  - have an SSH client for Windows installed
REM  - add the remote FusionReactor instance in 'Enterprise->Manage Servers'
REM  - add the path to this script in the Script field of 'Modify Server'
REM  - define appropriate values for the parameters (see below) used by the script.
REM
REM Putty (http://en.wikipedia.org/wiki/PuTTY) is used as the Windows SSH client. Putty's
REM plink.exe application is used to start the CF server remotely.
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
set LOGFILE=C:\FusionReactor\etc\cp\Restart-Coldfusion9-OnUnix.log
REM -------------------------------------------------------------------------------------------

REM The hostname or IP address to connect
REM -------------------------------------------------------------------------------------------
set HOST=%3
REM -------------------------------------------------------------------------------------------

REM username and password for the SSH connection - you have to change these values accordingly
REM -------------------------------------------------------------------------------------------
set USER=root
set PWD=password
REM -------------------------------------------------------------------------------------------

REM The command to execute on the remote machine
REM -------------------------------------------------------------------------------------------
set COMMAND=/opt/coldfusion9/bin/coldfusion start
REM -------------------------------------------------------------------------------------------

REM The number of seconds (grace period) before the command will be executed
REM -------------------------------------------------------------------------------------------
set GRACE_PERIOD=10
REM -------------------------------------------------------------------------------------------



REM -------------------------------------------------------------------------------------------
REM Below is the actual script. No changes should be required. Note: The ping command below is
REM used to simulate the sleep command, which is unfortunately not available per default on all
REM Windows versions.
REM -------------------------------------------------------------------------------------------
echo Status[%1] InstanceName[%2] InstanceIp[%3] PID[%4] LastSeen[%5] >> %LOGFILE%
if NOT "%1" == "DOWN" goto end

:start
if "%4" == "-1" goto run
if "%4" == "0" goto run
if "%4" == "" goto run

:kill
echo Killing server process %4... >> %LOGFILE%
plink -pw %PWD% %USER%@%HOST% kill -9 %4 >> %LOGFILE% 2>&1

:wait
echo Waiting %GRACE_PERIOD% seconds before trying to start the server... >> %LOGFILE%
plink -pw %PWD% %USER%@%HOST% sleep %GRACE_PERIOD%

:run
plink -pw %PWD% %USER%@%HOST% %COMMAND% >> %LOGFILE% 2>&1

:end


