#!/bin/bash
#
################################################################################
# Script:     Railo Installer (Linux 32-bit Edition)
#
# Purpose:    This script is meant to automate the installation of a
#	      pre-configured version of the Railo CFML processing
#             engine running on top of Tomcat.
################################################################################
# Written By: Jordan Michaels (jordan@viviotech.net)
################################################################################
# Date:       June, 2009
# Version:    3.1 Beta patch level 0
################################################################################
# Support:    Complete documentation will be available soon...
#	      
################################################################################
# LICENSE:    http://www.opensource.org/licenses/bsd-license.php
################################################################################
# Copyright (c) 2008-2009, Jordan Michaels, Vivio Technologies
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of Jordan Michaels nor the names of its contributors
#      may be used to endorse or promote products derived from this software
#      without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
################################################################################
# BEGIN SCRIPT
################################################################################

# Welcome the user
clear;
echo "################################################################################";
echo "#                        Welcome to the Railo Installer!                       #";
echo "################################################################################";
echo "";

# default settings
ISTHIRTYTWO=0;
ISSIXTYFOUR=0;
ISUPGRADE=0;
DefaultTempDir="/tmp";
DefaultInstallDir="/opt/railo/";
DefaultApacheConfigFile="/etc/apache2/apache2.conf";
DefaultApacheModulesDir="/usr/lib/apache2/modules/";
DefaultApacheBinaryLocation="/usr/sbin/apache2";
DefaultApacheControlScript="/etc/init.d/apache2";
DefaultStartScriptDir="/etc/init.d/";
DefaultChkConfigCMD="update-rc.d railo_ctl defaults";
DefaultJKLogLoc="/var/log/apache2/mod_jk.log";
################################################################################
# BEGIN FUNCTION LIBRARY
################################################################################

function CheckRunningRoot {
	if [ ! $(id -u) = "0" ] ; then
		echo "This installation script needs to be run as root.";
		echo "Exiting the installer...";
		exit;
	fi
}

function GetTheBaseDir {
        # This function sees where the script is being called from
        # and adds it to a variable, TheProcessorDir
        # make sure temp directory exists
        if [ ! -d $DefaultTempDir ] ; then
                echo "$DefaultTempDir does not exist! Cannot continue!";
                exit;
        fi
        # make sure the temp directory is writable
        if [ ! -w $DefaultTempDir ] ; then
                echo "$DefaultTempDir is not writable! Cannot continue!";
                exit;
        fi
        # create our work file
        echo $0 >> ${DefaultTempDir}/temp.installer;
        TEMP=`cat ${DefaultTempDir}/temp.installer`;
        # remove "install.sh" if it exists
        if [ "$TEMP" = "install.sh" ] ; then
                # if the user is just calling the install file directly,
                # make the path relative
                sed -i 's/install.sh/.\//' ${DefaultTempDir}/temp.installer;
        else
                sed -i 's/install.sh//' ${DefaultTempDir}/temp.installer;
        fi
        # for debugging
        #TEMP=`cat ${DefaultTempDir}/temp.installer`;
        #echo $TEMP;
        #rm  ${DefaultTempDir}/temp.installer
        #exit;
        # change the working directory to the same directory that the
        # install script is in 
        TheProcessorDir=`cat ${DefaultTempDir}/temp.installer`;
        # remove the temp file
        rm  ${DefaultTempDir}/temp.installer 
        # change working directory
        #cd $TheProcessorDir; # this may not be needed
        # for debugging (make sure subshell is in right directory)
        # pwd;
}

function DisplayLicense {
	echo "This installer has been released under the BSD License:";
	echo "http://www.opensource.org/licenses/bsd-license.php";
        echo "";
	echo "--------------------------------------------------------------------------------";
	echo " Copyright (c) 2008-2009, Jordan Michaels, Vivio Technologies";
	echo " All rights reserved.";
	echo "";
	echo " Redistribution and use in source and binary forms, with or without";
	echo " modification, are permitted provided that the following conditions are met:";
	echo "";
	echo "    * Redistributions of source code must retain the above copyright notice,";
	echo "      this list of conditions and the following disclaimer.";
	echo "    * Redistributions in binary form must reproduce the above copyright";
	echo "      notice, this list of conditions and the following disclaimer in the";
	echo "      documentation and/or other materials provided with the distribution.";
	echo "    * Neither the name of Jordan Michaels, Vivio Technologies, nor the names";
	echo "      of its contributors may be used to endorse or promote products derived";
        echo "      from this software without specific prior written permission.";
	echo "";
	echo " THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"";
	echo " AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE";
	echo " IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE";
	echo " ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE";
	echo " LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR";
	echo " CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF";
	echo " SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS";
	echo " INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN";
	echo " CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)";
	echo " ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE";
	echo " POSSIBILITY OF SUCH DAMAGE.";
	echo "--------------------------------------------------------------------------------";
	echo "";
	echo "Have you READ and UNDERSTOOD the BSD License?";
	PS3='Enter a Number: '
	select answer in "No" "Yes" "Abort"
	do
		if [ ! $answer ] ; then
			DisplayLicense;
		elif [ $answer = "No" ]; then
			echo "Understanding the BSD License is required. Exiting the installer...";
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
        echo "";
        echo -n "Attempting to autodetect system bit type...";
        if [ `uname -i | grep -c i386` -gt 0 ] ; then
                echo -n "found i386...";
		FoundSixFour=0;
        elif [ `uname -i | grep -c x86_64` -gt 0 ] ; then
                echo -n "found x86_64...";
		FoundSixFour=1;
        else
                echo -n "result unknown...";
		FoundSixFour=0;
        fi
        echo "[DONE]";
        echo "";
	
	if [ $FoundSixFour = 1 ] ; then
		echo "WARNING!";
		echo "You are attempting to install the 32-bit version of";
		echo "the installer onto what appears to be a 64-bit machine.";
		echo "The installer will attempt to proceed normally, but if";
		echo "you encounter difficulties, please use the 64-bit";
		echo "version of the installer.";
		echo "";
	fi
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
#	echo OSSelect $OSSelect
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
			DefaultChkConfigCMD="/sbin/chkconfig railo_ctl --add";
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
			DefaultChkConfigCMD="/sbin/chkconfig railo_ctl --add";
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
			DefaultChkConfigCMD="update-rc.d railo_ctl defaults";
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
			DefaultChkConfigCMD="update-rc.d railo_ctl defaults";
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
			DefaultChkConfigCMD="/sbin/chkconfig railo_ctl --add";
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
			DefaultChkConfigCMD="/sbin/chkconfig railo_ctl --add";
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
	echo "Please enter the system path to where you would like to have";
        echo "Railo installed:";
        echo "";
	echo -n "Enter System Path [$DefaultInstallDir]: ";
	read TheInstallDir;
	
	if [ -z $TheInstallDir ]; then
                echo "No directory entered. Using default ($DefaultInstallDir)";
                myInstallDir=$DefaultInstallDir;
        else
                myInstallDir=$TheInstallDir;
        fi
	
	# check to make sure the directory exists
	if [ ! -d $myInstallDir ] ; then
		# that directory doesn't exist
		ANSWERFOUND="No";
		while [ $ANSWERFOUND = "No" ] ; do
			echo "";
		        echo "The $myInstallDir directory doesn't exist yet.";
			echo "Do you want me to create it?";
		        PS3='Enter a Number: '
		        select answer in "Yes" "No" "Abort"
	                do
				if [ ! $answer ] ; then
					InstallDirPrompt;
				elif [ $answer = "No" ] ; then
	                		echo "Alright, well, I need a place to install to.";
					echo "";
					InstallDirPrompt;
		                elif [ $answer = "Yes" ] ; then
		                        echo -n "Creating install directory at $myInstallDir ";
		                        TEMP=`mkdir -p $myInstallDir`;
					echo "[DONE]";
					echo "";
					ANSWERFOUND="Yes";
					break;
				elif [ $answer = "Abort" ] ; then
					echo "Exiting the installer...";
					exit;
				else
					InstallDirPrompt;
		                fi
			done
			if [ $ANSWERFOUND = "Yes" ] ; then
				break;
			fi
		done
	else
		# the directory already exists, warn the user about overwriting files
		echo "";
		echo "INSTALLATION DIRECTORY ALREADY EXISTS!";
		echo "Please note that if there are files present in the installation directory";
		echo "that match the names of files being installed, they will be OVERWRITEN!";
		echo "PLEASE MAKE SURE YOU HAVE PROPER BACKUPS!";
		echo "";
		echo "Should I continue installing to this directory?";
		echo "1) Yes, install Railo to $myInstallDir";
		echo "2) Nevermind, use a different directory";
		echo "3) Abort Installation";
		echo -n "Enter a number: ";
		read case;
		if [ $case ] ; then
			if [ $case -lt 4 ] ; then
				case $case in
					1) echo "Continuing to install to $myInstallDir";;
					2) InstallDirPrompt;;
					3) echo "Exiting the installer...";exit;;
				esac
			else
				echo "Invalid option entered - reverting to default.";
				InstallDirPrompt;
			fi
		fi
	fi
}

function CheckForJDK {
	if [ ! -d ${TheProcessorDir}/jdk ] ; then
		# the JDK directory doesn't exist - running installer from wrong directory?
		echo "The folder: ${TheProcessorDir}jdk/ doesn't exist!";
		echo "";
		echo "The folder containing the Java Runtime Environment that I need";
		echo "doesn't appear to exist with this installer! I cannot continue.";
		echo "Perhaps you are running this installer from the wrong directory?";
		echo "";
		echo "Exiting the installer...";
		exit;
	fi
}

function InstallJDK {
	echo "";
	echo -n "Installing the JDK...";
	cp -R ${TheProcessorDir}/jdk $myInstallDir;
	echo "[DONE]";
}

function CheckForTomcat {
	# make sure our tomcat directory exists
	if [ ! -e ${TheProcessorDir}/tomcat ] ; then
                echo "";
                echo "The 'tomcat' folder appears to be missing from the installer files.";
                echo "Please check the folder that you're running the install script from";
		echo "and try again.";
                echo "";
                echo "Exiting the installer...";
                exit;
        fi
}

function TomcatUNPrompt {
	echo "";
	echo "Please enter the user name that you would like to access the Tomcat";
        echo "Web-Based Administrator with. The default is 'admin', but we recommend";
	echo "you change this to something less guessable.";
        echo "";
        echo -n "Enter Tomcat Web-Admin Username [admin]: ";
        read TomcatAdminUsername;

        if [ -z $TomcatAdminUsername ]; then
                echo "No username entered. Using default admin username.";
                myTomcatAdminUsername="admin";
        else
                myTomcatAdminUsername=$TomcatAdminUsername;
        fi
}

function TomcatPWPrompt {
        echo "";
	echo "Please enter a password for the Tomcat Web-Based Administrator:";
        echo "";
        echo -n "Enter Tomcat Web-Admin Password: ";
        read TomcatAdminPassword;

        if [ -z $TomcatAdminPassword ] || [ ! $TomcatAdminPassword ] ; then
                echo "No password entered. I need a password in order to continue.";
                TomcatPWPrompt;
        else
                myTomcatAdminPassword=$TomcatAdminPassword;
        fi
}

function TomcatInstall {
	TomCatUsersFile="${myInstallDir}tomcat/conf/tomcat-users.xml";
	
	TomcatUNPrompt;
	TomcatPWPrompt;
	
	echo "";
	echo -n "Installing Tomcat...";
	cp -R ${TheProcessorDir}/tomcat $myInstallDir;
        echo "[DONE]";
	echo -n "Creating Administrative User...";
	# remove the basic file that's there
	TEMP=`rm $TomCatUsersFile`;
	# create an empty file
	TEMP=`touch $TomCatUsersFile`;
	# create true users file by appending lines of code
	TEMP=`echo "<?xml version='1.0' encoding='utf-8'?>" >> $TomCatUsersFile`;
	TEMP=`echo "<tomcat-users>" >> $TomCatUsersFile`;
	TEMP=`echo "<role rolename='manager'/>" >> $TomCatUsersFile`;
	TEMP=`echo "<user username='${myTomcatAdminUsername}' password='${myTomcatAdminPassword}' roles='manager'/>" >> $TomCatUsersFile`;
	TEMP=`echo "</tomcat-users>" >> $TomCatUsersFile`;
	echo "[DONE]";
	echo "";
	
	TomcatControlScript="${myInstallDir}railo_ctl";
	
        # check to see if the file exists already
        if [ ! -e $TomcatControlScript ] ; then
                # the control script doesn't exist, let's create it
                TEMP=`touch $TomcatControlScript`;
	else
		# out with the old, in with the new
		rm $TomcatControlScript
		TEMP=`touch $TomcatControlScript`;
	fi
	
	echo -n "Creating Railo Control Script...";
        TEMP=`touch $TomcatControlScript`;
        TEMP=`echo "#!/bin/bash" >> $TomcatControlScript`;
        TEMP=`echo "# chkconfig: 345 22 78" >> $TomcatControlScript`;
        TEMP=`echo "# description: Tomcat/Railo Control Script" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;
        TEMP=`echo "# switch the subshell to the tomcat directory so that any relative" >> $TomcatControlScript`;
        TEMP=`echo "# paths specified in any configs are interpreted from this directory." >> $TomcatControlScript`;
        TEMP=`echo "cd ${myInstallDir}tomcat/" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;
        TEMP=`echo "# set base params for subshell" >> $TomcatControlScript`;
        TEMP=`echo "CATALINA_BASE=${myInstallDir}tomcat; export CATALINA_BASE" >> $TomcatControlScript`;
        TEMP=`echo "CATALINA_HOME=${myInstallDir}tomcat; export CATALINA_HOME" >> $TomcatControlScript`;
        TEMP=`echo "CATALINA_TMPDIR=${myInstallDir}tomcat/temp; export CATALINA_TMPDIR" >> $TomcatControlScript`;
        TEMP=`echo "JRE_HOME=${myInstallDir}jdk/jre; export JRE_HOME" >> $TomcatControlScript`;
        TEMP=`echo "JAVA_HOME=${myInstallDir}jdk; export JAVA_HOME" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;
        TEMP=`echo "start() {" >> $TomcatControlScript`;
        TEMP=`echo "        echo -n \\"Starting Railo: \\"" >> $TomcatControlScript`;
        TEMP=`echo "        \\$CATALINA_HOME/bin/startup.sh" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"[DONE]\\"" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"--------------------------------------------------------\\"" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"It may take a few moments for Railo to start processing\\"" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"CFML templates. This is normal.\\"" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"--------------------------------------------------------\\"" >> $TomcatControlScript`;
        TEMP=`echo "}" >> $TomcatControlScript`;
        TEMP=`echo "stop() {" >> $TomcatControlScript`;
        TEMP=`echo "        echo -n \\"Shutting down Railo: \\"" >> $TomcatControlScript`;
        TEMP=`echo "        \\$CATALINA_HOME/bin/shutdown.sh" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"[DONE]\\"" >> $TomcatControlScript`;
        TEMP=`echo "}" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;
        TEMP=`echo "case \\"\\$1\\" in" >> $TomcatControlScript`;
        TEMP=`echo "  start)" >> $TomcatControlScript`;
        TEMP=`echo "        start" >> $TomcatControlScript`;
        TEMP=`echo "        ;;" >> $TomcatControlScript`;
        TEMP=`echo "  stop)" >> $TomcatControlScript`;
        TEMP=`echo "        stop" >> $TomcatControlScript`;
        TEMP=`echo "        ;;" >> $TomcatControlScript`;
        TEMP=`echo "  restart)" >> $TomcatControlScript`;
        TEMP=`echo "        stop" >> $TomcatControlScript`;
        TEMP=`echo "        sleep 5" >> $TomcatControlScript`;
        TEMP=`echo "        start" >> $TomcatControlScript`;
        TEMP=`echo "        ;;" >> $TomcatControlScript`;
        TEMP=`echo "  *)" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"Usage: \\$0 {start|stop|restart}\\"" >> $TomcatControlScript`;
        TEMP=`echo "        exit 1" >> $TomcatControlScript`;
        TEMP=`echo "        ;;" >> $TomcatControlScript`;
        TEMP=`echo "esac" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;
        TEMP=`echo "exit 0" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;

        # give it execute permissions
        TEMP=`chmod 700 $TomcatControlScript`;
        echo "[DONE]";
}

function InstallRailo {
	# copy the directories belonging to Railo into the install directory
	echo -n "Installing Railo...";
	cp -R ${TheProcessorDir}/lib $myInstallDir;
        echo -n ".";
	cp -R ${TheProcessorDir}/uninstall $myInstallDir;
        echo -n ".";
        echo "[DONE]";
}

# see if the user wants to add tomcat to the system start up scripts
function CheckTomcatStartup {
	echo "";
        echo "Do you want to start Railo at system boot?";
        PS3='Enter a Number: '
        select answer in "No" "Yes"
        do
                if [ ! $answer ] ; then
                        CheckTomcatStartup;
                elif [ $answer = "No" ]; then
                        echo "Okay, Railo will NOT be started at system boot.";
                elif [ $answer = "Yes" ]; then
                        echo "Okay, Configuring Railo to start at system boot...";
                        echo "";
			AddTomcatStartup;
                else
                        echo "";
			CheckTomcatStartup;
                fi
                break
        done
}

function AddTomcatStartup {
	# check for the existance of the start script directory
	if [ ! -d $DefaultStartScriptDir ] ; then
		echo "Cannot find $DefaultStartScriptDir!";
		echo "";
		echo "System appears incompatible with this installer. Please configure";
		echo "the boot script manually.";
	else
		echo -n "Configuring Railo to start at system boot...";
		cp ${myInstallDir}railo_ctl ${DefaultStartScriptDir}railo_ctl;
		chmod 755 ${DefaultStartScriptDir}railo_ctl;
		${DefaultChkConfigCMD};
		# /sbin/chkconfig railo_ctl --add;
		echo "[DONE]";
	fi
}

function CheckApacheConnector {
	echo "";
	echo "Would you like me to check to see if I can install the mod_jk";
	echo "Apache connector on to your system?";
	echo "";
        PS3='Enter a Number: '
        select answer in "No" "Yes"
        do
                if [ ! $answer ] ; then
                        CheckApacheConnector;
                elif [ $answer = "No" ]; then
                        echo "Okay, I will NOT install the Apache connector at this time.";
                elif [ $answer = "Yes" ]; then
                        echo "Okay, Attempting to install the Apache connector now...";
                        echo "";
                        InstallApacheConnector;
                else
                        echo "";
                        CheckApacheConnector;
                fi
                break
        done
}

function InstallApacheConnector {
	# Get the apache conf file location
	echo "";
	echo "Please enter the system path of your apache config file (including file name):";
        echo "";
        echo -n "Enter System Path [$DefaultApacheConfigFile]: ";
        read ApacheConfigFile;

        if [ -z $ApacheConfigFile ]; then
                echo "No directory entered. Using default ($DefaultApacheConfigFile)";
                myApacheConfigFile=$DefaultApacheConfigFile;
        else
                myApacheConfigFile=$ApacheConfigFile;
        fi
	
        # Make sure the file exists
        if [ ! -e $myApacheConfigFile ] ; then
                echo "The file you spefied doesn't exist.";
                echo "";
                InstallApacheConnector;
        fi

	GetModulesDirectory;
}

function GetModulesDirectory {
	# Get the location of the modules directory
        echo "";
        echo "Please enter the path where you install apache modules:";
        echo "";
        echo -n "Enter Module Path [$DefaultApacheModulesDir]: ";
        read ApacheModulesDir;

        if [ -z $ApacheModulesDir ]; then
                echo "No directory entered. Using default ($DefaultApacheModulesDir)";
                myApacheModulesDir=$DefaultApacheModulesDir;
        else
                myApacheModulesDir=$ApacheModulesDir;
        fi

        # Make sure the file exists
        if [ ! -d $myApacheModulesDir ] ; then
                echo "The diectory you spefied doesn't exist.";
                echo "";
                GetModulesDirectory;
        fi
	
	GetApacheBinaryLocation;
}

function GetApacheBinaryLocation {
	# Get the location of the Apache binary
        echo "";
        echo "Please enter the system path to your apache binary (include file name):";
        echo "";
        echo -n "Enter System Path [$DefaultApacheBinaryLocation]: ";
        read ApacheBinaryLocation;

        if [ -z $ApacheBinaryLocation ]; then
                echo "No directory entered. Using default ($DefaultApacheBinaryLocation)";
                myApacheBinaryLocation=$DefaultApacheBinaryLocation;
        else
                myApacheBinaryLocation=$ApacheBinaryLocation;
        fi

        # Make sure the file exists
        if [ ! -e $myApacheBinaryLocation ] ; then
                echo "The file you spefied doesn't exist.";
                echo "";
                GetApacheBinaryLocation;
        fi

	GetApacheControlScript;
}

function GetApacheControlScript {
	# Get the location of the Apache control script
        echo "";
        echo "Please enter the full system path to your Apache control script:";
	echo "(including file name)";
        echo "";
        echo -n "Enter Control Script Path [$DefaultApacheControlScript]: ";
        read ApacheControlScript;

        if [ -z $ApacheControlScript ]; then
                echo "No directory entered. Using default ($DefaultApacheControlScript)";
                myApacheControlScript=$DefaultApacheControlScript;
        else
                myApacheControlScript=$ApacheControlScript;
        fi

        # Make sure the file exists
        if [ ! -e $myApacheControlScript ] ; then
                echo "The file you spefied doesn't exist.";
                echo "";
                GetApacheControlScript;
        fi
	
	# Check to see if the connector is already installed
        CheckConnectorExists;
}

function CheckConnectorExists {
        # only run this function if we're not doing an upgrade
	if [ $ISUPGRADE -eq 0 ] ; then
		echo "";
		# grep the conf file to see if mod_jk is present already
		JKLineCount=`cat $myApacheConfigFile | grep -c mod_jk.so`;
		if [ $JKLineCount -gt 0 ] ; then
			echo "A preliminary review of your config file looks like you already have";
			echo "mod_jk installed. If it's just commented, please remove the commented";
			echo "lines and try again. If you already have mod_jk installed, then it";
			echo "does not need to be installed by this installer.";
			echo "";
		else
			echo -n "No previous installation of mod_jk not found, this is good.";
			AutoDetectApacheVersion;
		fi
	else
		# jump directly to next function
		AutoDetectApacheVersion;
	fi # close check upgrade
}

function AutoDetectApacheVersion {
	if [ ! $myApacheBinaryLocation ] ; then
		# if the binary has not been specified... kick back...
		GetApacheBinaryLocation;
	fi
	echo "";
	APACHEVERSION=0;
        echo -n "Attempting to autodetect Apache version...";
        if [ `${myApacheBinaryLocation} -version | grep -c 'Apache/2.2'` -gt 0 ] ; then
                echo -n "found Apache 2.2...";
                APACHEVERSION=22;
        elif [ `${myApacheBinaryLocation} -version | grep -c 'Apache/2.0'` -gt 0 ] ; then
                echo -n "found Apache 2.0...";
                APACHEVERSION=20;
        elif [ `${myApacheBinaryLocation} -version | grep -c 'Apache/1.3'` -gt 0 ] ; then
                echo -n "found Apache 1.3...";
                APACHEVERSION=13;
        else
                echo -n "cannot autodetect...";
        fi
        echo "[DONE]";
        echo "";
	ApacheVersionPrompt;
}

function ApacheVersionPrompt {
	echo "";
        echo "What version of Apache are you running?";
        if [ $APACHEVERSION -eq 22 ] ; then
                echo "(I think it's Apache 2.2, but I could be wrong.)";
        elif [ $APACHEVERSION -eq 20 ] ; then
                echo "(I think it's Apache 2.0, but I could be wrong.)";
        elif [ $APACHEVERSION -eq 13 ] ; then
                echo "(I think it's Apache 1.3, but I could be wrong.)";
        else
                echo "(I cannot tell what version of Apache this is.)";
        fi
        echo "";
        PS3='Enter a Number: '
        select answer in "Apache_2.2" "Apache_2.0" "Apache_1.3" "Abort"
        do
                if [ ! $answer ] ; then
                        ApacheVersionPrompt;
                elif [ $answer = "Apache_2.2" ]; then
                        echo "Setting Apache version to 2.2...";
                        APACHEVERSION=22;
                elif [ $answer = "Apache_2.0" ]; then
                        echo "Setting Apache version to 2.0...";
                        APACHEVERSION=20;
                elif [ $answer = "Apache_1.3" ]; then
                        echo "Setting Apache version to 1.3...";
                        APACHEVERSION=13;
                elif [ $answer = "Abort" ]; then
                        echo "Exiting the installer...";
                        exit;
                else
                        ApacheVersionPrompt;
                fi
                break
        done
	CheckConnectorExistsInstaller;
}

function CheckConnectorExistsInstaller {
	# Make sure the file exists before we try to copy it
	if [ $ISTHIRTYTWO -eq 1 ] ; then
		# check the 32-bit connectors
		if [ $APACHEVERSION -eq 22 ] ; then
			# 32-bit apache 2.2
			if [ ! -e ${TheProcessorDir}/tomcat_connectors/i386/mod_jk-1.2.28-httpd-2.2.X.so ] ; then
		                echo "";
		                echo "The connector I need doesn't exist! Aborting connector installation!";
		                echo "";
		        else
		                echo "Found 32-bit connector for Apache 2.2. This is good.";
				CopyModJK;
		        fi
		elif [ $APACHEVERSION -eq 20 ] ; then
			# 32-bit apache 2.0
                        if [ ! -e ${TheProcessorDir}/tomcat_connectors/i386/mod_jk-1.2.28-httpd-2.0.X.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                echo "Found 32-bit connector for Apache 2.0. This is good.";
                                CopyModJK;
                        fi
		elif [ $APACHEVERSION -eq 13 ] ; then
			# 32-bit apache 1.3
                        if [ ! -e ${TheProcessorDir}/tomcat_connectors/i386/mod_jk-1.2.28-httpd-1.3.X-eapi.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                echo "Found 32-bit connector for Apache 1.3. This is good.";
                                CopyModJK;
                        fi
		fi
	elif [ $ISSIXTYFOUR -eq 1 ] ; then
		# check for 64-bit connectors
                if [ $APACHEVERSION -eq 22 ] ; then
                        # 64-bit apache 2.2
                        if [ ! -e ${TheProcessorDir}/tomcat_connectors/x86_64/mod_jk-1.2.28-httpd-2.2.X.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                echo "Found 64-bit connector for Apache 2.2. This is good.";
                                CopyModJK;
                        fi
                elif [ $APACHEVERSION -eq 20 ] ; then
                        # 64-bit apache 2.0
                        if [ ! -e ${TheProcessorDir}/tomcat_connectors/x86_64/mod_jk-1.2.28-httpd-2.0.X.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                echo "Found 64-bit connector for Apache 2.0. This is good.";
                                CopyModJK;
                        fi
                elif [ $APACHEVERSION -eq 13 ] ; then
                        # 64-bit apache 1.3
                        if [ ! -e ${TheProcessorDir}/tomcat_connectors/x86_64/mod_jk-1.2.28-httpd-1.3.X-eapi.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                echo "Found 64-bit connector for Apache 1.3. This is good.";
                                CopyModJK;
                        fi
                fi
	fi
}

function CopyModJK {
	# Copy mod_jk.so to the apache modules directory
	if [ $ISTHIRTYTWO -eq 1 ] ; then
                # check the 32-bit connectors
                if [ $APACHEVERSION -eq 22 ] ; then
                        # 32-bit apache 2.2
                        echo -n "Installing 32-bit connector for Apache 2.2...";
                        cp -f ${TheProcessorDir}/tomcat_connectors/i386/mod_jk-1.2.28-httpd-2.2.X.so ${myApacheModulesDir}mod_jk.so
			echo "[DONE]";
                elif [ $APACHEVERSION -eq 20 ] ; then
                        # 32-bit apache 2.0
                        echo -n "Installing 32-bit connector for Apache 2.0...";
                        cp -f ${TheProcessorDir}/tomcat_connectors/i386/mod_jk-1.2.28-httpd-2.0.X.so ${myApacheModulesDir}mod_jk.so
                        echo "[DONE]";
                elif [ $APACHEVERSION -eq 13 ] ; then
                        # 32-bit apache 1.3
                        echo -n "Installing 32-bit connector for Apache 1.3...";
                        cp -f ${TheProcessorDir}/tomcat_connectors/i386/mod_jk-1.2.28-httpd-1.3.X-eapi.so ${myApacheModulesDir}mod_jk.so
                        echo "[DONE]";
                fi
        elif [ $ISSIXTYFOUR -eq 1 ] ; then
                # check for 64-bit connectors
                if [ $APACHEVERSION -eq 22 ] ; then
                        # 64-bit apache 2.2
                        echo -n "Installing 64-bit connector for Apache 2.2...";
                        cp -f ${TheProcessorDir}/tomcat_connectors/x86_64/mod_jk-1.2.28-httpd-2.2.X.so ${myApacheModulesDir}mod_jk.so
                        echo "[DONE]";
                elif [ $APACHEVERSION -eq 20 ] ; then
                        # 64-bit apache 2.0
                        echo -n "Installing 64-bit connector for Apache 2.0...";
                        cp -f ${TheProcessorDir}/tomcat_connectors/x86_64/mod_jk-1.2.28-httpd-2.0.X.so ${myApacheModulesDir}mod_jk.so
                        echo "[DONE]";
                elif [ $APACHEVERSION -eq 13 ] ; then
                        # 64-bit apache 1.3
                        echo -n "Installing 64-bit connector for Apache 1.3...";
                        cp -f ${TheProcessorDir}/tomcat_connectors/x86_64/mod_jk-1.2.28-httpd-1.3.X-eapi.so ${myApacheModulesDir}mod_jk.so
                        echo "[DONE]";
                fi
        fi
	
	# if this is an upgrade, remove the previous config before adding the new one
	if [ $ISUPGRADE -eq 1 ] ; then
		# remove the <IfModule !mod_jk.c> segment...
                sed -i '/<IfModule !mod_jk.c>/,/<\/IfModule>/d' $myApacheConfigFile
                # remove the <IfModule !mod_jk.c> segment...
                sed -i '/<IfModule mod_jk.c>/,/<\/IfModule>/d' $myApacheConfigFile	
	fi
	
	# add the mod_jk parameters to the apache config file
	TEMP=`echo "<IfModule !mod_jk.c>" >> $myApacheConfigFile`;
	TEMP=`echo "	LoadModule jk_module ${DefaultApacheModulesDir}mod_jk.so" >> $myApacheConfigFile`;
	TEMP=`echo "</IfModule>" >> $myApacheConfigFile`;
	TEMP=`echo "" >> $myApacheConfigFile`;
	TEMP=`echo "<IfModule mod_jk.c>" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMount /*.cfm ajp13" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMount /*.cfc ajp13" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMount /*.do ajp13" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMount /*.jsp ajp13" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMount /*.cfchart ajp13" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMountCopy all" >> $myApacheConfigFile`;
	TEMP=`echo "	JkLogFile ${DefaultJKLogLoc}" >> $myApacheConfigFile`;
	TEMP=`echo "</IfModule>" >> $myApacheConfigFile`;
	
        echo "";
	echo "Attempting to restart Apache to apply configuration changes...";
	TEMP=`$myApacheControlScript restart`;
	echo "[DONE]";
}

# Ask the user if they want the script to clean up after itself...
function AskRemoveInstallFiles {
	echo "";
        echo "This installer created some temporary files during the install, do you";
	echo "want me to clean up those files now?";
        echo "";
        PS3='Enter a Number: '
        select answer in "No" "Yes"
        do
                if [ ! $answer ] ; then
                        AskRemoveInstallFiles;
                elif [ $answer = "No" ]; then
                        echo "Okay, I will NOT clean up after myself.";
                elif [ $answer = "Yes" ]; then
                        echo "Okay, cleaning up after myself now...";
                        echo "";
                        CleanUpInstallFiles;
                else
                        echo "";
                        AskRemoveInstallFiles;
                fi
                break
        done
}

function CleanUpInstallFiles {
	echo -n "Cleaning up...";
	# remove installer files
	rm -rf ${TheProcessorDir};
	echo "[DONE]";
}

function WhatNow {
clear;
echo "################################################################################";
echo "#                        Railo Installed Successfully!                         #";
echo "################################################################################";
echo "";
echo "";
echo "################################################################################";
echo "#                                                                              #";
echo "# IMPORTANT REMINDER:                                                          #";
echo "#   In order for your Apache VirtualHosts to be handled properly by            #";
echo "#   Tomcat, you MUST UPDATE Tomcat's server.xml file.                          #";
echo "#                                                                              #";
echo "#   This file is located in [Railo Install]/tomcat/conf/server.xml             #";
echo "#                                                                              #";
echo "################################################################################";
}


####################################################################################
# BEGIN FUNCTION SEQUENCE
# 
# The following function sequence determines the flow of the installer functions.
# Some functions are not called here because they are automatically called by a
# function that is required to run before them.
####################################################################################

CheckRunningRoot;
GetTheBaseDir;
DisplayLicense;
AutoDetectSystemType;
SetDirectoryDefaults;
InstallDirPrompt;
CheckForJDK;
InstallJDK;
CheckForTomcat;
TomcatInstall;
InstallRailo;
CheckTomcatStartup;
CheckApacheConnector;
AskRemoveInstallFiles;
WhatNow;
