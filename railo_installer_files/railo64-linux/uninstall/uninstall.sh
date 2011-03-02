#!/bin/bash
####################################################################################
# Script:     uninstall.sh
####################################################################################
# Written By: Jordan Michaels (jordan@viviotech.net)
####################################################################################
# Date:       July, 2008
# Version:    3.1 BETA 
####################################################################################
# Purpose:    This is an uninstallation script for Railo CFML Processing Engine
#             that removes the componants that were installed by the installation
#             script that accompanied this distribution of Railo.
#
####################################################################################
# LICENSE:    http://www.opensource.org/licenses/bsd-license.php
####################################################################################
# Copyright (c) 2008-2009, Jordan Michaels, Vivio Technologies
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright notice, this
#      list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice,
#      this list of conditions and the following disclaimer in the documentation
#      and/or other materials provided with the distribution.
#    * Neither the name of Jordan Michaels nor the names of its contributors may
#      be used to endorse or promote products derived from this software without
#      specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
####################################################################################
# BEGIN SCRIPT
####################################################################################

# Welcome the user
clear;
echo "#################################################################################";
echo "#                       Welcome to the Railo Uninstaller!                       #";
echo "#################################################################################";
echo "";

# default settings (you generally should NOT update these)
ISTHIRTYTWO=1;
DefaultTempDir="/tmp";
DefaultInstallDir="/opt/railo/";
DefaultApacheConfigFile="/etc/apache2/apache2.conf";
DefaultApacheModulesDir="/usr/lib/apache2/modules/";
DefaultApacheBinaryLocation="/usr/sbin/apache2";
DefaultApacheControlScript="/etc/init.d/apache2";
DefaultStartScriptDir="/etc/init.d/";
####################################################################################
# BEGIN FUNCTION LIBRARY
####################################################################################

function CheckRunningRoot {
        if [ ! $(id -u) = "0" ]; then
                echo "This installation script needs to be run as root.";
                echo "Exiting the installer...";
                exit;
        fi
}

function DisplayLicense {
        echo "This installer has been released under the BSD License:";
	echo "http://www.opensource.org/licenses/bsd-license.php";
        echo "";
        echo "--------------------------------------------------------------------------------";
        echo "Copyright (c) 2008-2009, Jordan Michaels, Vivio Technologies";
        echo "All rights reserved.";
        echo "";
        echo "Redistribution and use in source and binary forms, with or without modification,";
        echo "are permitted provided that the following conditions are met:";
        echo "";
        echo "   * Redistributions of source code must retain the above copyright notice, this";
        echo "     list of conditions and the following disclaimer.";
        echo "   * Redistributions in binary form must reproduce the above copyright notice,";
        echo "     this list of conditions and the following disclaimer in the documentation";
        echo "     and/or other materials provided with the distribution.";
        echo "   * Neither the name of Jordan Michaels nor the names of its contributors may";
        echo "     be used to endorse or promote products derived from this software without";
        echo "     specific prior written permission.";
        echo "";
        echo "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND";
        echo "ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED";
        echo "WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE";
        echo "DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR";
        echo "ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES";
        echo "(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS";
        echo "OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY";
        echo "THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING";
        echo "NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,";
        echo "EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.";
        echo "--------------------------------------------------------------------------------";
        echo "";
        echo "Have you READ and UNDERSTOOD the BSD License?";
        PS3='Enter a Number: '
        select answer in "No" "Yes" "Abort"
        do
                if [ ! $answer ] ; then
                        DisplayLicense;
                elif [ $answer = "No" ]; then
                        echo "Exiting the installer...";
                        exit;
                elif [ $answer = "Abort" ]; then
                        echo "Exiting the installer...";
                        exit;
                elif [ $answer = "Yes" ]; then
                        echo "Great! Let's continue...";
                        echo "";
                else
                        DisplayLicense;
                fi
                break
        done
}

function AutoDetectSystemType {
        # try to automatically detect if the system is 32 or 64-bit.
        # start by setting results to false
        ISSIXTYFOUR=0;
        ISTHIRTYTWO=0;
        echo "";
        echo -n "Attempting to autodetect system bit type...";
        if [ `uname -i | grep -c i386` -gt 0 ] ; then
                echo -n "found i386...";
                ISTHIRTYTWO=1;
        elif [ `uname -i | grep -c x86_64` -gt 0 ] ; then
                echo -n "found x86_64...";
                ISSIXTYFOUR=1;
        else
                echo -n "result unknown...";
        fi
        echo "[DONE]";
        echo "";
}

function SetDirectoryDefaults {
        echo "Please select your OS from the list below:";
        if [ $ISTHIRTYTWO -eq 1 ] ; then
                echo "(I detected 32-bit, but I could be wrong.)";
        elif [ $ISSIXTYFOUR -eq 1 ] ; then
                echo "(I detected 64-bit, but I could be wrong.)";
        else
                echo "(I cannot tell what kind of system this is.)";
        fi
        echo "";
        OSSelect="\"CentOS/RHEL 4/5 (32-bit)\"
                  \"CentOS/RHEL 4/5 (64-bit)\"
                  \"Ubuntu 8.04 Server LTS (32-bit)\"
                  \"Ubuntu 8.04 Server LTS (64-bit)\"
                  \"Other 32-bit OS\"
                  \"Other 64-bit OS\"
                  \"Abort\"";
#       echo OSSelect $OSSelect
        eval set $OSSelect
        PS3='Enter a Number: '
        select answer in "$@"
        do
        if [ ! "$answer" ] ; then
                        SetDirectoryDefaults;
                elif [ "$answer" = "CentOS/RHEL 4/5 (32-bit)" ]; then
                        echo "Setting system path defaults to CentOS/RHEL 4/5 (32-bit)";
                        ISTHIRTYTWO=1;
                        DefaultTempDir="/tmp";
                        DefaultInstallDir="/opt/railo/";
                        DefaultApacheConfigFile="/etc/httpd/conf/httpd.conf";
                        DefaultApacheModulesDir="/usr/lib/httpd/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/httpd";
                        DefaultApacheControlScript="/etc/rc.d/init.d/httpd";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="/sbin/chkconfig railo_ctl --del";
                        DefaultJKLogLoc="/var/log/httpd/mod_jk.log";
                elif [ "$answer" = "CentOS/RHEL 4/5 (64-bit)" ]; then
                        echo "Setting system path defaults to CentOS/RHEL 4/5 (64-bit)";
                        ISSIXTYFOUR=1;
                        DefaultTempDir="/tmp";
                        DefaultInstallDir="/opt/railo/";
                        DefaultApacheConfigFile="/etc/httpd/conf/httpd.conf";
                        DefaultApacheModulesDir="/usr/lib64/httpd/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/httpd";
                        DefaultApacheControlScript="/etc/rc.d/init.d/httpd";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="/sbin/chkconfig railo_ctl --del";
                        DefaultJKLogLoc="/var/log/httpd/mod_jk.log";
                elif [ "$answer" = "Ubuntu 8.04 Server LTS (32-bit)" ]; then
                        echo "Setting system path defaults to Ubuntu 8.04 Server LTS (32-bit)";
                        ISTHIRTYTWO=1;
                        DefaultTempDir="/tmp";
                        DefaultInstallDir="/opt/railo/";
                        DefaultApacheConfigFile="/etc/apache2/apache2.conf";
                        DefaultApacheModulesDir="/usr/lib/apache2/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/apache2";
                        DefaultApacheControlScript="/etc/init.d/apache2";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="update-rc.d -f railo_ctl remove";
                        DefaultJKLogLoc="/var/log/apache2/mod_jk.log";
                elif [ "$answer" = "Ubuntu 8.04 Server LTS (64-bit)" ]; then
                        echo "Setting system path defaults to Ubuntu 8.04 Server LTS (64-bit)";
                        ISSIXTYFOUR=1;
                        DefaultTempDir="/tmp";
                        DefaultInstallDir="/opt/railo/";
                        DefaultApacheConfigFile="/etc/apache2/apache2.conf";
                        DefaultApacheModulesDir="/usr/lib/apache2/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/apache2";
                        DefaultApacheControlScript="/etc/init.d/apache2";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="update-rc.d -f railo_ctl remove";
                        DefaultJKLogLoc="/var/log/apache2/mod_jk.log";
                elif [ "$answer" = "Other 32-bit OS" ]; then
                        echo "Cannot set default paths. Please adjust for your system when prompted.";
                        ISTHIRTYTWO=1;
                        DefaultTempDir="/tmp";
                        DefaultInstallDir="/opt/railo/";
                        DefaultApacheConfigFile="/etc/httpd/conf/httpd.conf";
                        DefaultApacheModulesDir="/usr/lib/httpd/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/httpd";
                        DefaultApacheControlScript="/etc/rc.d/init.d/httpd";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="/sbin/chkconfig railo_ctl --del";
                        DefaultJKLogLoc="/var/log/httpd/mod_jk.log";
                elif [ "$answer" = "Other 64-bit OS" ]; then
                        echo "Cannot set default paths. Please adjust for your system when prompted.";
                        ISSIXTYFOUR=1;
                        DefaultTempDir="/tmp";
                        DefaultInstallDir="/opt/railo/";
                        DefaultApacheConfigFile="/etc/httpd/conf/httpd.conf";
                        DefaultApacheModulesDir="/usr/lib64/httpd/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/httpd";
                        DefaultApacheControlScript="/etc/rc.d/init.d/httpd";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="/sbin/chkconfig railo_ctl --del";
                        DefaultJKLogLoc="/var/log/httpd/mod_jk.log";
                elif [ "$answer" = "Abort" ]; then
                        echo "Exiting the installer...";
                        exit;
                else
                        SetDirectoryDefaults;
                fi
                break
        done
}

function InstallDirPrompt {
        echo "Please enter the system path where Railo is currently installed:";
        echo "";
        echo -n "Enter System Path [$DefaultInstallDir]: ";
        read TheInstallDir;

        if [ -z $TheInstallDir ]; then
                echo "No directory entered. Checking default ($DefaultInstallDir)";
                myTheInstallDir=$DefaultInstallDir;
        else
                myTheInstallDir=$TheInstallDir;
        fi

        # check to make sure the directory exists
        if [ ! -d $myTheInstallDir ] ; then
                # that directory doesn't exist
                echo "That directory doesn't exist. Please try again.";
                echo "(CTRL+C to abort)";
		echo "";
                InstallDirPrompt;
        else 
                # the directory exists, check for tomcat directory
		if [ ! -d $myTheInstallDir/tomcat ] ; then
                # that directory doesn't exist
                	echo "The installation directory appears to have been modified.";
			echo "If you installed customizations to this directory, this";
			echo "uninstaller will remove those changes, PERMANATLY.";
	                echo "";
		        echo "Are you sure you want to continue?";
		        PS3='Enter a Number: '
		        select answer in "No" "Yes" "Abort"
		        do
		                if [ ! $answer ] ; then
                		        InstallDirPrompt;
		                elif [ $answer = "No" ]; then
		                        echo "Exiting the uninstaller...";
		                        exit;
		                elif [ $answer = "Abort" ]; then
                		        echo "Exiting the uninstaller...";
		                        exit;
		                elif [ $answer = "Yes" ]; then
		                        echo "Okay, continuing the uninstall...";
		                        echo "";
		                else
                		        InstallDirPrompt;
		                fi
		                break
		        done
		fi
		# Check for start script
		echo -n "Installation directory found, checking for control script...";
		if [ -f $myTheInstallDir/railo_ctl ] ; then
			# if the start script exists, try to stop a running server
			echo "[FOUND]";
			echo -n "Running stop command...";
			nohup $myTheInstallDir/railo_ctl stop > /dev/null;
			echo "[DONE]";
		else
			echo "[NOT FOUND]";
			echo "Skipping stop sequence. Please make sure Tomcat/Railo is no longer running.";
		fi
		echo "Proceeding with removal...";
	fi
}

function RemoveInstallDir {
	echo "";
	echo "IMPORTANT: Everything in $myTheInstallDir will be deleted...";
        echo "";
        echo "Should I continue to uninstall?";
        echo "1) Yes, remove Railo from $myTheInstallDir";
        echo "2) Abort Uninstallation";                                    
        echo -n "Enter a number: ";
        read case;
        if [ $case ] ; then
        	if [ $case -lt 3 ] ; then
                	case $case in
                                1) echo "Continuing to uninstall from $myTheInstallDir";;
                                2) echo "Exiting the uninstaller...";exit;;
                        esac
                else
                        echo "Invalid option entered - reverting to default.";
			RemoveInstallDir;
                fi
	fi
	
	echo -n "Removing $myTheInstallDir ...";
	rm -rf $myTheInstallDir;
	echo "[DONE]";
}

function CheckStartScript {
	echo -n "Checking for system boot script at ${DefaultStartScriptDir}railo_ctl...";
	if [ ! -f ${DefaultStartScriptDir}railo_ctl ] ; then
                # init script doesn't exist
                echo "[NOT FOUND]";
	else
                echo "[FOUND]";
		RemoveStartScript;
        fi
	
}

function RemoveStartScript {
	echo -n "Removing start script from system boot process...";
	#/sbin/chkconfig railo_ctl --del;
	${DefaultChkConfigCMD};
	echo "[DONE]";

	echo -n "Removing start script from file system...";
	rm ${DefaultStartScriptDir}railo_ctl
	echo "[DONE]";
}

function CheckApacheConnector {
        echo "";
        echo "Would you like me to check to see if I can remove the mod_jk";
        echo "Apache connector from to your system?"; 
        echo "";
        echo "IMPORTANT: This action will update your apache config file";
	echo "           and attempt to restart apache.";
        echo "";
        PS3='Enter a Number: ' 
        select answer in "No" "Yes" 
        do
                if [ ! $answer ] ; then
                        CheckApacheConnector;
                elif [ $answer = "No" ]; then
                        echo "Okay, I will NOT mess with Apache at this time.";
                elif [ $answer = "Yes" ]; then
                        echo "Okay, Attempting to remove the Apache connector now...";
                        echo "";
			GetApacheConfigFile;
                else
                        echo "";
                        CheckApacheConnector;
                fi
                break
        done
}

function GetApacheConfigFile {
        # Get the apache conf file location
        echo "";
        echo "Please enter the system path of your apache config file (including file name):";
        echo "";
        echo -n "Enter System Path [${DefaultApacheConfigFile}]: ";
        read ApacheConfigFile;

        if [ -z $ApacheConfigFile ]; then
                echo "No directory entered. Using default (${DefaultApacheConfigFile})";
                myApacheConfigFile=${DefaultApacheConfigFile};
        else
                myApacheConfigFile=$ApacheConfigFile;
        fi

        # Make sure the file exists
        if [ ! -e $myApacheConfigFile ] ; then
                echo "The file you spefied doesn't exist.";
                echo "";
                GetApacheConfigFile;
        fi

        CheckConnectorExists;
}

function CheckConnectorExists {
        echo "";
        # grep the conf file to see if mod_jk is present already
        JKLineCount=`cat $myApacheConfigFile | grep -c mod_jk.so`;
        if [ $JKLineCount -gt 0 ] ; then
        	GetModulesDirectory;
	else
                echo "It doesn't look like mod_jk is installed... skipping mod_jk removal.";
        fi
}

function GetModulesDirectory {
        # Get the location of the modules directory
        echo "";
        echo "Please enter the path where you install apache modules:";
        echo "";
        echo -n "Enter Module Path [${DefaultApacheModulesDir}]: ";
        read ApacheModulesDir;

        if [ -z $ApacheModulesDir ]; then
                echo "No directory entered. Using default (${DefaultApacheModulesDir})";
                myApacheModulesDir=${DefaultApacheModulesDir};
        else
                myApacheModulesDir=$ApacheModulesDir;
        fi

        # Make sure the file exists
        if [ ! -d $myApacheModulesDir ] ; then
                echo "The diectory you spefied doesn't exist.";
                echo "";
                GetModulesDirectory;
        fi

        GetApacheControlScript
}

function GetApacheControlScript {
        # Get the location of the Apache control script
        echo "";
        echo "Please enter the full system path to your Apache control script:";
        echo "(including file name)";
        echo "";
        echo -n "Enter Control Script Path [${DefaultApacheControlScript}]: ";
        read ApacheControlScript;

        if [ -z $ApacheControlScript ]; then
                echo "No directory entered. Using default (${DefaultApacheControlScript})";
                myApacheControlScript=${DefaultApacheControlScript};
        else
                myApacheControlScript=$ApacheControlScript;
        fi

        # Make sure the file exists
        if [ ! -e $myApacheControlScript ] ; then
                echo "The file you spefied doesn't exist.";
                echo "";
                GetApacheControlScript;
        fi

        # remove the apache entries
        RemoveApacheEntries;
}

function RemoveApacheEntries {
	# remove the <IfModule !mod_jk.c> segment...
	sed -i '/<IfModule !mod_jk.c>/,/<\/IfModule>/d' $myApacheConfigFile
	
        # remove the <IfModule !mod_jk.c> segment...
        sed -i '/<IfModule mod_jk.c>/,/<\/IfModule>/d' $myApacheConfigFile
	
	echo "";
	echo "Apache config updated sucessfully.";
	echo "";
	cd ~
        echo "Attempting to restart Apache to apply configuration changes...";
        TEMP=`$myApacheControlScript restart`;
        echo "[DONE]";
}

####################################################################################
# BEGIN FUNCTION SEQUENCE
####################################################################################

CheckRunningRoot;
DisplayLicense;
AutoDetectSystemType;
SetDirectoryDefaults;
InstallDirPrompt;
RemoveInstallDir;
CheckStartScript;
CheckApacheConnector;

# Tell the user goodbye...
cd ~
echo "#################################################################################";
echo "#                         Railo was successfully removed.                       #";
echo "#################################################################################";
echo "";
