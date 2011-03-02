#!/bin/sh
# -------------------------------------------------------------------------------------------
# This script is an example of how to use the Crash Protection script functionality of
# FusionReactor to automatically restart a ColdFusion 8 server running on a remote Windows
# machine from Unix.
#
# To use this script you have to
#
#  - have enterprise licenses for the FusionReactor instances
#  - have an SSH server for Windows installed
#  - add the remote FusionReactor instance in 'Enterprise->Manage Servers'
#  - add the path to this script in the Script field of 'Modify Server'
#  - define appropriate values for the parameters (see below) used by the script.
#
# OpenSSH (http://sshwindows.sourceforge.net) is used as the Windows SSH server.
# -------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------
# Script arguments
# -------------------------------------------------------------------------------------------
# When a FusionReactor Crash Protection event triggers a call to the script the following
# command line arguments are passed to the script:

# Argument        Value
# -------------------------------------------------------------------------------------------
# status          Either 'DOWN' or 'UP'
# InstanceName    The name of the FusionReactor instance that caused the CP event
# InstanceIP      The IP address of the FusionReactor instance that caused the CP event
# PID             The process id
# LastSeen        The timestamp of event
# -------------------------------------------------------------------------------------------



# -------------------------------------------------------------------------------------------
# Please change the values below according to your environment
# -------------------------------------------------------------------------------------------

# Output of the script is written to the following file
# -------------------------------------------------------------------------------------------
LOGFILE=/opt/fusionreactor/etc/cp/restart-Coldfusion8-OnWindows.log
# -------------------------------------------------------------------------------------------

# The username for the SSH connection. This script assumes that SSH (i.e. ssh-agent) is
# configured appropriately so that no password prompt appears
# -------------------------------------------------------------------------------------------
USER=Administrator
# -------------------------------------------------------------------------------------------

# The hostname or IP address to connect
# -------------------------------------------------------------------------------------------
HOST=$3
# -------------------------------------------------------------------------------------------

# The command to execute on the #ote machine
# -------------------------------------------------------------------------------------------
COMMAND=net start "ColdFusion 8 Application Server"
# -------------------------------------------------------------------------------------------

# The number of seconds (grace period) before the command will be executed
# -------------------------------------------------------------------------------------------
GRACE_PERIOD=10
# -------------------------------------------------------------------------------------------



# -------------------------------------------------------------------------------------------
# Below is the actual script. No changes should be required. Note: The ping command below is
# -------------------------------------------------------------------------------------------
touch $LOGFILE
echo Status[$1] InstanceName[$2] InstanceIp[$3] PID[$4] LastSeen[$5] >> $LOGFILE
if [ "$1" = "DOWN" ]; then
  echo Killing server process $4... >> $LOGFILE
  ssh $USER@$HOST taskkill /PID $4 >> $LOGFILE 2>&1

  echo Waiting $GRACE_PERIOD seconds before trying to start the server... >> $LOGFILE 2>&1
  sleep $GRACE_PERIOD

  ssh $USER@$HOST $COMMAND >> $LOGFILE 2>&1
fi
