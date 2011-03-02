#!/bin/bash
#
################################################################################
# Script:     OpenBD Installer (Linux 64-bit Edition)
#
# Purpose:    This script is meant to automate the installation of a
#	      pre-configured version of the OpenBlueDragon CFML processing
#             engine running on top of Tomcat.
################################################################################
# Written By: Jordan Michaels (jordan@viviotech.net)
################################################################################
# Date:       May, 2009
# Version:    1.1.0 patch level 1
################################################################################
# Support:    Complete documentation is availalbe on the OpenBlueDragon WIKI:
#	      http://wiki.openbluedragon.org/wiki/index.php/OpenBD_Installer
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
echo "#                   Welcome to the Open BlueDragon Installer!                  #";
echo "################################################################################";
echo "";

# default settings
ISTHIRTYTWO=0;
ISSIXTYFOUR=1;
ISUPGRADE=0;
DefaultTempDir="/tmp";
DefaultOpenBDInstallDir="/opt/openbd/";
DefaultApacheConfigFile="/etc/httpd/conf/httpd.conf";
DefaultApacheModulesDir="/usr/lib64/httpd/modules/";
DefaultApacheBinaryLocation="/usr/sbin/httpd";
DefaultApacheControlScript="/etc/rc.d/init.d/httpd";
DefaultStartScriptDir="/etc/init.d/";
DefaultChkConfigCMD="/sbin/chkconfig openbd_ctl --add";
DefaultJKLogLoc="/var/log/httpd/mod_jk.log";
################################################################################
# BEGIN FUNCTION LIBRARY
################################################################################

function CheckRunningRoot {
	if [ ! $(id -u) = "0" ]; then
		echo "This installation script needs to be run as root.";
		echo "Exiting the installer...";
		exit;
	fi
}

function GetBDBaseDir {
        # This function sees where the script is being called from
        # and adds it to a variable, TheOpenBDDir
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
        echo $0 >> ${DefaultTempDir}/temp.openbd;
        TEMP=`cat ${DefaultTempDir}/temp.openbd`;
        # remove "install.sh" if it exists
        if [ "$TEMP" = "install.sh" ] ; then
                # if the user is just calling the install file directly,
                # make the path relative
                sed -i 's/install.sh/.\//' ${DefaultTempDir}/temp.openbd;
        else
                sed -i 's/install.sh//' ${DefaultTempDir}/temp.openbd;
        fi
        # for debugging
        #TEMP=`cat ${DefaultTempDir}/temp.openbd`;
        #echo $TEMP;
        #rm  ${DefaultTempDir}/temp.openbd
        #exit;
        # change the working directory to the same directory that the
        # install script is in 
        TheOpenBDDir=`cat ${DefaultTempDir}/temp.openbd`;
        # remove the temp file
        rm  ${DefaultTempDir}/temp.openbd 
        # change working directory
        #cd $TheOpenBDDir; # this may not be needed
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
		if [ $ISTHIRTYTWO = 1 ] ; then
			echo "WARNING!";
			echo "You are attempting to install the 32-bit version of";
			echo "the installer onto what appears to be a 64-bit machine.";
			echo "The installer will attempt to proceed normally, but if";
			echo "you encounter difficulties, please use the 64-bit";
			echo "version of the installer.";
			echo "";
		fi
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
        OSSelect="\"CentOS/RHEL 4/5 (64-bit)\"
                  \"Ubuntu 8.04 Server LTS (64-bit)\"
                  \"Other 64-bit OS\"
                  \"Abort\"";
	eval set $OSSelect
	PS3='Enter a Number: '
	select answer in "$@"
	do
	if [ ! "$answer" ] ; then
                        SetDirectoryDefaults;
                elif [ "$answer" = "CentOS/RHEL 4/5 (64-bit)" ]; then
                        echo "Setting system path defaults to CentOS/RHEL 4/5 (64-bit)";
                        ISSIXTYFOUR=1;
                        DefaultTempDir="/tmp";
                        DefaultOpenBDInstallDir="/opt/openbd/";
                        DefaultApacheConfigFile="/etc/httpd/conf/httpd.conf";
                        DefaultApacheModulesDir="/usr/lib64/httpd/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/httpd";
                        DefaultApacheControlScript="/etc/rc.d/init.d/httpd";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="/sbin/chkconfig openbd_ctl --add";
                        DefaultJKLogLoc="/var/log/httpd/mod_jk.log";
                elif [ "$answer" = "Ubuntu 8.04 Server LTS (64-bit)" ]; then
                        echo "Setting system path defaults to Ubuntu 8.04 Server LTS (64-bit)";
                        ISSIXTYFOUR=1;
                        DefaultTempDir="/tmp";
                        DefaultOpenBDInstallDir="/opt/openbd/";
                        DefaultApacheConfigFile="/etc/apache2/apache2.conf";
                        DefaultApacheModulesDir="/usr/lib/apache2/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/apache2";
                        DefaultApacheControlScript="/etc/init.d/apache2";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="update-rc.d openbd_ctl defaults";
                        DefaultJKLogLoc="/var/log/apache2/mod_jk.log";
                elif [ "$answer" = "Other 64-bit OS" ]; then
                        echo "Cannot set default paths. Please adjust for your system when prompted.";
                        ISSIXTYFOUR=1;
                        DefaultTempDir="/tmp";
                        DefaultOpenBDInstallDir="/opt/openbd/";
                        DefaultApacheConfigFile="/etc/httpd/conf/httpd.conf";
                        DefaultApacheModulesDir="/usr/lib64/httpd/modules/";
                        DefaultApacheBinaryLocation="/usr/sbin/httpd";
                        DefaultApacheControlScript="/etc/rc.d/init.d/httpd";
                        DefaultStartScriptDir="/etc/init.d/";
                        DefaultChkConfigCMD="/sbin/chkconfig openbd_ctl --add";
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
        echo "Open BlueDragon installed:";
        echo "";
	echo -n "Enter System Path [$DefaultOpenBDInstallDir]: ";
	read OpenBDInstallDir;
	
	if [ -z $OpenBDInstallDir ]; then
                echo "No directory entered. Using default ($DefaultOpenBDInstallDir)";
                myOpenBDInstallDir=$DefaultOpenBDInstallDir;
        else
                myOpenBDInstallDir=$OpenBDInstallDir;
        fi
	
	# check to make sure the directory exists
	if [ ! -d $myOpenBDInstallDir ] ; then
		# that directory doesn't exist
		ANSWERFOUND="No";
		while [ $ANSWERFOUND = "No" ] ; do
			echo "";
		        echo "The $myOpenBDInstallDir directory doesn't exist yet.";
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
		                        echo -n "Creating install directory at $myOpenBDInstallDir ";
		                        TEMP=`mkdir -p $myOpenBDInstallDir`;
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
                # the directory already exists, check for previous install directory
                # upgrade only supported for the last installer.
		AskUpgrade;

		# the directory already exists, warn the user about overwriting files
#		echo "";
#		echo "INSTALLATION DIRECTORY ALREADY EXISTS!";
#		echo "Please note that if there are files present in the installation directory";
#		echo "that match the names of files being installed, they will be OVERWRITEN!";
#		echo "PLEASE MAKE SURE YOU HAVE PROPER BACKUPS!";
#		echo "";
#		echo "Should I continue installing to this directory?";
#		echo "1) Yes, install OpenBD to $myOpenBDInstallDir";
#		echo "2) Nevermind, use a different directory";
#		echo "3) Abort Installation";
#		echo -n "Enter a number: ";
#		read case;
#		if [ $case ] ; then
#			if [ $case -lt 4 ] ; then
#				case $case in
#					1) echo "Continuing to install to $myOpenBDInstallDir";;
#					2) InstallDirPrompt;;
#					3) echo "Exiting the installer...";exit;;
#				esac
#			else
#				echo "Invalid option entered - reverting to default.";
#				InstallDirPrompt;
#			fi
#		fi
	fi
}

function AskUpgrade {
	# install directory exists, ask the user if they want to upgrade
	ANSWERFOUND="No";
        while [ $ANSWERFOUND = "No" ] ; do
	        echo "";
                echo "The $myOpenBDInstallDir directory already exists.";
                echo "Do you want me to see if I can upgrade a previous install?";
                PS3='Enter a Number: '
                select answer in "Yes" "No" "Abort"
                do
                	if [ ! $answer ] ; then
                        	AskUpgrade;
                        elif [ $answer = "No" ] ; then
                                echo "Alright, I will *NOT* attempt to upgrade a previous install.";
                                echo "IMPORTANT:";
                                echo "Please note that if there are files present in the installation directory";
                                echo "that match the names of files being installed, they will be OVERWRITTEN!";
                                echo "MAKE SURE YOU HAVE PROPER BACKUPS!";
                                echo "";
				ISUPGRADE=0;
				ANSWERFOUND="Yes";
				break;
                        elif [ $answer = "Yes" ] ; then
                                echo "Alright, I *WILL* attempt to upgrade a previous install. ";
				echo "IMPORTANT:";
				echo "While this installer will do it's best to perform the upgrade for you, it's";
				echo "VERY IMPORTANT that you maintain YOUR OWN BACKUPS just in case anything";
				echo "goes wrong. YOU are ultimately responsible for your data.";
                                echo "";
				# set the upgrade switch...
				ISUPGRADE=1;
				ANSWERFOUND="Yes";
				# perform the backup
				PerformUpgradeBackup;
				break;
                        elif [ $answer = "Abort" ] ; then
                                echo "Exiting the installer...";
                                exit;
                        else
                                AskUpgrade;
                        fi
                done
                if [ $ANSWERFOUND = "Yes" ] ; then
                        break;
                fi
	done
}

function AskBackupPreviousInstall {
	# ask the user if they want to backup before the upgrade
	ANSWERFOUND="No";
        while [ $ANSWERFOUND = "No" ] ; do
                echo "";
                echo "Would you like to create a BACKUP of $myOpenBDInstallDir before";
		echo "I proceed to attempt to upgrade? (HIGHLY RECOMMENDED!)";
                PS3='Enter a Number: '
                select answer in "Yes" "No" "Abort"
                do
                        if [ ! $answer ] ; then
                                AskBackupPreviousINstall;
                        elif [ $answer = "No" ] ; then
                                echo "Alright, I will *NOT* create a backup for you.";
                                echo "MAKE SURE YOU HAVE PROPER BACKUPS!";
                                echo "";
                                ANSWERFOUND="Yes";
				break;
                        elif [ $answer = "Yes" ] ; then
                                echo  -n "Alright, creating a backup for you... ";
				TheBackupFileName=openbd_installer_backup_$(date +%Y%m%d).tgz;
				TEMP=`cd ${myOpenBDInstallDir}; tar -czf ~/${TheBackupFileName} *;`;
				echo "[DONE]";
                                echo "The backup was saved to your home directory as openbd_installer_backup_$(date +%Y%m%d).tgz";
				echo "";
                                ANSWERFOUND="Yes";
                                break;
                        elif [ $answer = "Abort" ] ; then
                                echo "Exiting the installer...";
                                exit;
                        else
                                AskBackupPreviousINstall;
                        fi
                done
                if [ $ANSWERFOUND = "Yes" ] ; then
                        break;
                fi
        done
}

function PerformUpgradeBackup {
	# before we continue, ask the user if they want to make a backup of the existing directory
	AskBackupPreviousInstall;
	# IMPORTANT - this process only supports 1.0.1 installs done by the previous installer
	# start by seeing if we can shut down our existing server...
	echo -n "Attempting to shut down existing install...";
        if [ ! -f ${myOpenBDInstallDir}/openbd_ctl ] ; then
                echo "[FAILED]";
                echo "CANNOT FIND openbd_ctl";
        else
		nohup ${myOpenBDInstallDir}/openbd_ctl stop > /dev/null;
                echo "[DONE]"; 
        fi	
	# Create backup folder in temp directory
	mkdir ${DefaultTempDir}/openbd-upgrade;
	# Check for the bluedragon.xml file...
	echo -n "Attempting to preserve bluedragon.xml...";
	if [ ! -f ${myOpenBDInstallDir}/tomcat/conf/openbd/bluedragon.xml ] ; then
		echo "[FAILED]";
		echo "CANNOT FIND bluedragon.xml!";
	else
		cp ${myOpenBDInstallDir}/tomcat/conf/openbd/bluedragon.xml ${DefaultTempDir}/openbd-upgrade/;
		echo "[SUCCESS]";
	fi
	# Check for Tomcat's server.xml file...
	echo -n "Attempting to preserve server.xml...";
        if [ ! -f ${myOpenBDInstallDir}/tomcat/conf/server.xml ] ; then
                echo "[FAILED]";
                echo "CANNOT FIND server.xml!";
        else
                cp ${myOpenBDInstallDir}/tomcat/conf/server.xml ${DefaultTempDir}/openbd-upgrade/;
                echo "[SUCCESS]";
        fi
	# attempt to preserve custom tags directory
	echo -n "Attempting to preserve default Custom Tags directory...";
	if [ ! -d ${myOpenBDInstallDir}/tomcat/conf/openbd/customtags ] ; then
                echo "[FAILED]";
                echo "CANNOT FIND customtags directory!";
        else
                cp -R ${myOpenBDInstallDir}/tomcat/conf/openbd/customtags ${DefaultTempDir}/openbd-upgrade/;
                echo "[SUCCESS]";
        fi
	echo "The rest of the installation will continue normally. Your previous files";
	echo "will be upgraded at the end of the install.";
	# done.
}

function CheckForJDK {
	if [ ! -d ${TheOpenBDDir}/jdk ] ; then
		# the JDK directory doesn't exist - running installer from wrong directory?
		echo "The folder: ${TheOpenBDDir}jdk/ doesn't exist!";
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
	cp -R ${TheOpenBDDir}/jdk $myOpenBDInstallDir;
	echo "[DONE]";
}

function CheckForTomcat {
	# make sure our tomcat directory exists
	if [ ! -e ${TheOpenBDDir}/tomcat ] ; then
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
	TomCatUsersFile="${myOpenBDInstallDir}tomcat/conf/tomcat-users.xml";
	
	TomcatUNPrompt;
	TomcatPWPrompt;
	
	echo "";
	echo -n "Installing Tomcat...";
	cp -R ${TheOpenBDDir}/tomcat $myOpenBDInstallDir;
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
	
	TomcatControlScript="${myOpenBDInstallDir}openbd_ctl";
	
        # check to see if the file exists already
        if [ ! -e $TomcatControlScript ] ; then
                # the control script doesn't exist, let's create it
                TEMP=`touch $TomcatControlScript`;
	else
		# out with the old, in with the new
		rm $TomcatControlScript
		TEMP=`touch $TomcatControlScript`;
	fi
	
	echo -n "Creating OpenBD Control Script...";
        TEMP=`touch $TomcatControlScript`;
        TEMP=`echo "#!/bin/bash" >> $TomcatControlScript`;
        TEMP=`echo "# chkconfig: 345 22 78" >> $TomcatControlScript`;
        TEMP=`echo "# description: Tomcat/OpenBD Control Script" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;
        TEMP=`echo "# switch the subshell to the tomcat directory so that any relative" >> $TomcatControlScript`;
        TEMP=`echo "# paths specified in any configs are interpreted from this directory." >> $TomcatControlScript`;
        TEMP=`echo "cd ${myOpenBDInstallDir}tomcat/" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;
        TEMP=`echo "# set base params for subshell" >> $TomcatControlScript`;
        TEMP=`echo "CATALINA_BASE=${myOpenBDInstallDir}tomcat; export CATALINA_BASE" >> $TomcatControlScript`;
        TEMP=`echo "CATALINA_HOME=${myOpenBDInstallDir}tomcat; export CATALINA_HOME" >> $TomcatControlScript`;
        TEMP=`echo "CATALINA_TMPDIR=${myOpenBDInstallDir}tomcat/temp; export CATALINA_TMPDIR" >> $TomcatControlScript`;
        TEMP=`echo "JRE_HOME=${myOpenBDInstallDir}jdk/jre; export JRE_HOME" >> $TomcatControlScript`;
        TEMP=`echo "JAVA_HOME=${myOpenBDInstallDir}jdk; export JAVA_HOME" >> $TomcatControlScript`;
        TEMP=`echo "" >> $TomcatControlScript`;
        TEMP=`echo "start() {" >> $TomcatControlScript`;
        TEMP=`echo "        echo -n \\"Starting OpenBD: \\"" >> $TomcatControlScript`;
        TEMP=`echo "        \\$CATALINA_HOME/bin/startup.sh" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"[DONE]\\"" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"--------------------------------------------------------\\"" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"It may take a few moments for OpenBD to start processing\\"" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"CFML templates. This is normal.\\"" >> $TomcatControlScript`;
        TEMP=`echo "        echo \\"--------------------------------------------------------\\"" >> $TomcatControlScript`;
        TEMP=`echo "}" >> $TomcatControlScript`;
        TEMP=`echo "stop() {" >> $TomcatControlScript`;
        TEMP=`echo "        echo -n \\"Shutting down OpenBD: \\"" >> $TomcatControlScript`;
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
	
	if [ $ISUPGRADE = 1 ] ; then
		# if this is an upgrade, attempt to restore the previous server.xml file to tomcat
		# start by seeing if we could back it up when we started...
		echo -n "Attempting to restore previous server.xml...";
        	if [ ! -f ${DefaultTempDir}/openbd-upgrade/server.xml ] ; then
                	echo "[FAILED]";
	                echo "CANNOT FIND server.xml! I probably wasn't able to back it up.";
	        else
        	        # back up new server.xml file (just in case)
			cp ${myOpenBDInstallDir}/tomcat/conf/server.xml ${myOpenBDInstallDir}/tomcat/conf/server.xml.default;
			# now copy our backup
			cp ${DefaultTempDir}/openbd-upgrade/server.xml ${myOpenBDInstallDir}/tomcat/conf/;
                	echo "[SUCCESS]";
			echo "";
			echo "For your reference, a default server.xml file is located at:";
			echo "${myOpenBDInstallDir}/tomcat/conf/server.xml.default";
			echo "";
			echo "If you run into problems with the upgrade, this file can be";
			echo "referenced to find proper settings.";
			echo "";
	        fi
	fi
}

function OpenBDPWPrompt {
        if [ $ISUPGRADE = 0 ] ; then
		# if it's not an upgrade, prompt for PW
		echo "";
	        echo "Please enter a password for the OpenBD Administrator:";
	        echo "";
	        echo -n "Enter OpenBD Administrator Password: ";
	        read OpenBDAdminPassword;

	        if [ -z $OpenBDAdminPassword ] || [ ! $OpenBDAdminPassword ] ; then
	                echo "No password entered. I need a password in order to continue.";
	                OpenBDPWPrompt;
	        else
	                myOpenBDAdminPassword=$OpenBDAdminPassword;
	        fi
	else
		# if it's not an upgrade, set the password variable to default (so it
		# can be written into the default bluedragon.xml file) and let the user
		# know their OpenBD pass won't change.
		echo "Upgrading, your OpenBD password will stay the same.";
		echo "";
		myOpenBDAdminPassword="admin";
	fi
}

function InstallOpenBD {
	# copy the directories belonging to OpenBD into the install directory
	echo -n "Installing OpenBD...";
	cp -R ${TheOpenBDDir}/bin $myOpenBDInstallDir;
        echo -n ".";
	cp -R ${TheOpenBDDir}/classes $myOpenBDInstallDir;
        echo -n ".";
	cp -R ${TheOpenBDDir}/conf $myOpenBDInstallDir;
        echo -n ".";
	cp -R ${TheOpenBDDir}/customtags $myOpenBDInstallDir;
        echo -n ".";
	cp -R ${TheOpenBDDir}/lib $myOpenBDInstallDir;
        echo -n ".";
	cp -R ${TheOpenBDDir}/logs $myOpenBDInstallDir;
        echo -n ".";
	cp -R ${TheOpenBDDir}/webresources $myOpenBDInstallDir;
        echo -n ".";
	cp -R ${TheOpenBDDir}/work $myOpenBDInstallDir;
        echo "[DONE]";

	OpenBDXMLFile="${myOpenBDInstallDir}conf/bluedragon.xml";
	
	# remove the default bluedragon.xml file
	if [ -e $OpenBDXMLFile= ] ; then
		rm -f $OpenBDXMLFile
	fi

	# write custom bluedragon.xml file
        if [ ! -e $OpenBDXMLFile ] ; then
		# Create the XML File
		TEMP=`touch $OpenBDXMLFile`;
		TEMP=`echo "<?xml version=\\"1.0\\" encoding=\\"UTF-8\\"?>" >> $OpenBDXMLFile`;
                TEMP=`echo "<server>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <system>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <buffersize>0</buffersize>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <password>${myOpenBDAdminPassword}</password>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <licensekey></licensekey>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <assert>false</assert>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <missingtemplatehandler></missingtemplatehandler>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <tempdirectory>\\$${myOpenBDInstallDir}work/temp</tempdirectory>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <lastfile>${myOpenBDInstallDir}conf/bluedragon.xml.bak.1</lastfile>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <runtimelogging>true</runtimelogging>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <deniedips></deniedips>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <defaultcharset>UTF-8</defaultcharset>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <component-cfc>\\$${myOpenBDInstallDir}conf/component.cfc</component-cfc>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <scriptsrc>/bluedragon/scripts</scriptsrc>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <resourcepath>\\$${myOpenBDInstallDir}webresources</resourcepath>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <debug>false</debug>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <legacyformvalidation>true</legacyformvalidation>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <scriptprotect>false</scriptprotect>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <nativelibdir>${myOpenBDInstallDir}bin</nativelibdir>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <errorhandler></errorhandler>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <lastupdated>14/May/2009 07:26.22</lastupdated>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <allowedips></allowedips>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <whitespacecomp>false</whitespacecomp>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </system>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <file>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <maxfiles>1000</maxfiles>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <trustcache>false</trustcache>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </file>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <cfcollection>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <collection name=\\"demo\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "      <storebody>false</storebody>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <name>demo</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <path>${myOpenBDInstallDir}work/cfcollection</path>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <language>english</language>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </collection>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </cfcollection>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <javacustomtags>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <classes>${myOpenBDInstallDir}classes</classes>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <mapping name=\\"cfx_javabluedragonhello\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "      <name>cfx_javabluedragonhello</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <displayname>CFX_JavaBlueDragonHello</displayname>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <description>A simple Java CFX tag example</description>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <class>com.newatlanta.BlueDragonHello</class>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </mapping>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </javacustomtags>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <nativecustomtags>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <mapping name=\\"cfx_nativebluedragonhello\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "      <function>ProcessTagRequest</function>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <keeploaded>true</keeploaded>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <name>cfx_nativebluedragonhello</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <displayname>CFX_NativeBlueDragonHello</displayname>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <module>\\$${myOpenBDInstallDir}customtags/BlueDragonHello.dll</module>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <description>A simple C++ CFX tag example</description>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </mapping>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </nativecustomtags>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <cfchart>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <cachesize>1000</cachesize>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <storage>file</storage>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </cfchart>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <cfquery>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <cache>true</cache>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <cachecount>1000</cachecount>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <dbdrivers>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <driver name=\\"microsoft sql server (jtds)\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "        <datasourceconfigpage>sqlserver-jtds.cfm</datasourceconfigpage>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <version>1.2.2</version>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <name>microsoft sql server (jtds)</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <drivername>net.sourceforge.jtds.jdbc.Driver</drivername>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <driverdescription>Microsoft SQL Server (jTDS)</driverdescription>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <jdbctype>4</jdbctype>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <provider>jTDS</provider>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <defaultport>1433</defaultport>" >> $OpenBDXMLFile`;
                TEMP=`echo "      </driver>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <driver name=\\"other\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "        <datasourceconfigpage>other.cfm</datasourceconfigpage>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <version></version>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <name>other</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <drivername></drivername>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <driverdescription>Other JDBC Driver</driverdescription>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <jdbctype></jdbctype>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <provider></provider>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <defaultport></defaultport>" >> $OpenBDXMLFile`;
                TEMP=`echo "      </driver>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <driver name=\\"h2 embedded (h2)\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "        <datasourceconfigpage>h2-embedded.cfm</datasourceconfigpage>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <version></version>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <name>h2 embedded (h2)</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <drivername>org.h2.Driver</drivername>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <driverdescription>H2 Embedded (H2)</driverdescription>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <jdbctype>4</jdbctype>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <provider>H2</provider>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <defaultport></defaultport>" >> $OpenBDXMLFile`;
                TEMP=`echo "      </driver>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <driver name=\\"oracle (oracle)\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "        <datasourceconfigpage>oracle.cfm</datasourceconfigpage>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <version>10.2.0.4</version>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <name>oracle (oracle)</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <drivername>oracle.jdbc.OracleDriver</drivername>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <driverdescription>Oracle (Oracle)</driverdescription>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <jdbctype>4</jdbctype>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <provider>Oracle</provider>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <defaultport>1521</defaultport>" >> $OpenBDXMLFile`;
                TEMP=`echo "      </driver>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <driver name=\\"mysql 4/5\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "        <datasourceconfigpage>mysql5.cfm</datasourceconfigpage>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <version>5.1.6</version>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <name>mysql 4/5</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <drivername>com.mysql.jdbc.Driver</drivername>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <driverdescription>MySQL 4/5 (MySQL)</driverdescription>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <jdbctype>4</jdbctype>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <provider>MySQL</provider>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <defaultport>3306</defaultport>" >> $OpenBDXMLFile`;
                TEMP=`echo "      </driver>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <driver name=\\"microsoft sql server 2005 (microsoft)\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "        <datasourceconfigpage>sqlserver2005-ms.cfm</datasourceconfigpage>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <version>1.2</version>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <name>microsoft sql server 2005 (microsoft)</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <drivername>com.microsoft.sqlserver.jdbc.SQLServerDriver</drivername>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <driverdescription>Microsoft SQL Server 2005 (Microsoft)</driverdescription>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <jdbctype>4</jdbctype>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <provider>Microsoft</provider>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <defaultport>1433</defaultport>" >> $OpenBDXMLFile`;
                TEMP=`echo "      </driver>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <driver name=\\"postgresql (postgresql)\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "        <datasourceconfigpage>postgresql.cfm</datasourceconfigpage>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <version>8.3-603</version>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <name>postgresql (postgresql)</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <drivername>org.postgresql.Driver</drivername>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <driverdescription>PostgreSQL (PostgreSQL)</driverdescription>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <jdbctype>4</jdbctype>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <provider>PostgreSQL</provider>" >> $OpenBDXMLFile`;
                TEMP=`echo "        <defaultport>5432</defaultport>" >> $OpenBDXMLFile`;
                TEMP=`echo "      </driver>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </dbdrivers>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </cfquery>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <debugoutput>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <executiontimes>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <show>false</show>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <highlight>250</highlight>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </executiontimes>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <enabled>false</enabled>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <exceptions>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <show>false</show>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </exceptions>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <tracepoints>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <show>false</show>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </tracepoints>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <database>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <show>false</show>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </database>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <ipaddresses></ipaddresses>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <variables>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <url>true</url>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <form>true</form>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <cookie>true</cookie>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <cgi>true</cgi>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <client>true</client>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <server>true</server>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <request>true</request>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <application>true</application>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <session>true</session>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <local>true</local>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <cffile>true</cffile>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <show>true</show>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <variables>false</variables>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </variables>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <timer>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <show>false</show>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </timer>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </debugoutput>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <cfapplication>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <j2eesession>false</j2eesession>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <applicationtimeout>#CreateTimeSpan(2,0,0,0)#</applicationtimeout>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <clientpurgeenabled>true</clientpurgeenabled>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <sessiontimeout>#CreateTimeSpan(0,0,20,0)#</sessiontimeout>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <cf5clientdata>false</cf5clientdata>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <clientexpiry>90</clientexpiry>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <enabled>true</enabled>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <clientstorage>cookie</clientstorage>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <clientGlobalUpdatesDisabled>true</clientGlobalUpdatesDisabled>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </cfapplication>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <openbdadminapi>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <version>1.1</version>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <lastupdated>14/May/2009 04:21:00</lastupdated>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </openbdadminapi>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <cfmail>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <interval>240</interval>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <smtpserver>127.0.0.1</smtpserver>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <smtpport>25</smtpport>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <charset>UTF-8</charset>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </cfmail>" >> $OpenBDXMLFile`;
                TEMP=`echo "  <cfmlcustomtags>" >> $OpenBDXMLFile`;
                TEMP=`echo "    <mapping name=\\"cf\\">" >> $OpenBDXMLFile`;
                TEMP=`echo "      <directory>\\$${myOpenBDInstallDir}customtags</directory>" >> $OpenBDXMLFile`;
                TEMP=`echo "      <name>cf</name>" >> $OpenBDXMLFile`;
                TEMP=`echo "    </mapping>" >> $OpenBDXMLFile`;
                TEMP=`echo "  </cfmlcustomtags>" >> $OpenBDXMLFile`;
                TEMP=`echo "</server>" >> $OpenBDXMLFile`;
		# all done finally...
	fi
	if [ $ISUPGRADE = 1 ] ; then
                # if this is an upgrade, attempt to restore the previous bluedragon.xml file
                # start by seeing if we could back it up when we started...
                echo -n "Attempting to restore previous bluedragon.xml...";
                if [ ! -f ${DefaultTempDir}/openbd-upgrade/bluedragon.xml ] ; then
                        echo "[FAILED]";
                        echo "CANNOT FIND bluedragon.xml! I probably wasn't able to back it up.";
                else
                        # back up new bluedragon.xml file (just in case)
                        cp ${myOpenBDInstallDir}/conf/bluedragon.xml ${myOpenBDInstallDir}/conf/bluedragon.xml.default;
                        # now copy our backup
                        cp ${DefaultTempDir}/openbd-upgrade/bluedragon.xml ${myOpenBDInstallDir}/conf/;
                        echo "[SUCCESS]";
			echo "";
                        echo "For your reference, a default bluedragon.xml file is located at:";
                        echo "${myOpenBDInstallDir}/conf/bluedragon.xml.default";
                        echo "";
                        echo "If you run into problems with the upgrade, this file can be";
                        echo "referenced to find proper settings.";
                        echo "";
                fi
		# perform bluedragon.xml file settings upgrades
		OkayToModifyBDxml=0;
		echo -n "Backing up bluedragon.xml to bluedragon.xml.backup...";
		if [ ! -f ${myOpenBDInstallDir}/conf/bluedragon.xml.backup ] ; then
			# only make the backup if one doesn't already exist...
			cp ${myOpenBDInstallDir}/conf/bluedragon.xml ${myOpenBDInstallDir}/conf/bluedragon.xml.backup;
			echo "[SUCCESS]";
			OkayToModifyBDxml=1;
		else
			echo "[FAIL] - file already exists. Will not overwrite or modify.";
			echo "";
			echo "********** IMPORTANT **********";
			echo "You will need to update the paths in your bluedragon.xml file by hand.";
			echo "Please refer to the bluedragon.xml.default file for location guidelines.";
			echo "OpenBD will not fuction without proper values in the bluedragon.xml file.";
			echo "********** IMPORTANT **********";
			echo "";
		fi
		# update bluedragon.xml file locations to new locations if the origional
		if [ $OkayToModifyBDxml = 1 ] ; then
			# run sed statements to update default locations
			# create work file
			cp ${myOpenBDInstallDir}/conf/bluedragon.xml ${myOpenBDInstallDir}/conf/bluedragon.xml.new
			# update default resource path
			sed -i 's:<resourcepath>../../conf/openbd/resources</resourcepath>:<resourcepath>\$'${myOpenBDInstallDir}'webresources</resourcepath>:' ${myOpenBDInstallDir}/conf/bluedragon.xml.new
			# update default component.cfc path
			sed -i 's:<component-cfc>../../conf/openbd/component.cfc</component-cfc>:<component-cfc>\$'${myOpenBDInstallDir}'conf/component.cfc</component-cfc>:' ${myOpenBDInstallDir}/conf/bluedragon.xml.new
			sed -i 's:<nativelibdir>../../conf/openbd/bin</nativelibdir>:<nativelibdir>'${myOpenBDInstallDir}'bin</nativelibdir>:' ${myOpenBDInstallDir}/conf/bluedragon.xml.new
			sed -i 's:<lastfile>../../conf/openbd/bluedragon.xml.bak.1</lastfile>:<lastfile>'${myOpenBDInstallDir}'conf/bluedragon.xml.bak.1</lastfile>:' ${myOpenBDInstallDir}/conf/bluedragon.xml.new
			sed -i 's:<tempdirectory>../../conf/openbd/temp</tempdirectory>:<tempdirectory>\$'${myOpenBDInstallDir}'work/temp</tempdirectory>:' ${myOpenBDInstallDir}/conf/bluedragon.xml.new
			sed -i 's:<classes>../../conf/openbd/classes</classes>:<classes>'${myOpenBDInstallDir}'classes</classes>:' ${myOpenBDInstallDir}/conf/bluedragon.xml.new
			sed -i 's:<directory>../../conf/openbd/customtags</directory>:<directory>\$'${myOpenBDInstallDir}'customtags</directory>:' ${myOpenBDInstallDir}/conf/bluedragon.xml.new
			# copy finished file to production
			cp ${myOpenBDInstallDir}/conf/bluedragon.xml.new ${myOpenBDInstallDir}/conf/bluedragon.xml
			# remove the work file
			rm ${myOpenBDInstallDir}/conf/bluedragon.xml.new
		fi
		# see if we restore the customtags directory
		echo -n "Attempting to restore previous Custom Tags Directory...";
                if [ ! -d ${DefaultTempDir}/openbd-upgrade/customtags ] ; then
                        echo "[FAILED]";
                        echo "CANNOT FIND directory! I probably wasn't able to back it up.";
                else
                        # back up new customtags dir (just in case)
                        mv ${myOpenBDInstallDir}/customtags ${myOpenBDInstallDir}/customtags.default;
                        # now copy our backup
                        cp -R ${DefaultTempDir}/openbd-upgrade/customtags/ ${myOpenBDInstallDir}/;
                        echo "[SUCCESS]";
                        echo "";
                        echo "For your reference, a default customtags directory was renamed to:";
                        echo "${myOpenBDInstallDir}/customtags.default";
                        echo "";
                fi
        fi
}

# see if the user wants to add tomcat to the system start up scripts
function CheckTomcatStartup {
	echo "";
        echo "Do you want to start OpenBD at system boot?";
        PS3='Enter a Number: '
        select answer in "No" "Yes"
        do
                if [ ! $answer ] ; then
                        CheckTomcatStartup;
                elif [ $answer = "No" ]; then
                        echo "Okay, OpenBD will NOT be started at system boot.";
                elif [ $answer = "Yes" ]; then
                        echo "Okay, Configuring Tomcat/OpenBD to start at system boot...";
                        echo "";
			AddTomcatStartup;
                else
                        echo "";
			CheckTomcatStartup;
                fi
                break
        done
}

# using chkconfig, add the Tomcat/OpenBD script to system boot process
function AddTomcatStartup {
	# check for the existance of the start script directory
	if [ ! -d $DefaultStartScriptDir ] ; then
		echo "Cannot find $DefaultStartScriptDir!";
		echo "";
		echo "System appears incompatible with this installer. Please configure";
		echo "the boot script manually.";
	else
		echo -n "Configuring OpenBD to start at system boot...";
		cp ${myOpenBDInstallDir}openbd_ctl ${DefaultStartScriptDir}openbd_ctl;
		chmod 755 ${DefaultStartScriptDir}openbd_ctl;
		${DefaultChkConfigCMD};
		# /sbin/chkconfig openbd_ctl --add;
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
	if [ $ISUPGRADE = 0 ] ; then
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
			if [ ! -e ${TheOpenBDDir}/tomcat_connectors/i386/mod_jk-1.2.27-httpd-2.2.6.so ] ; then
		                echo "";
		                echo "The connector I need doesn't exist! Aborting connector installation!";
		                echo "";
		        else
		                CopyModJK;
		        fi
		elif [ $APACHEVERSION -eq 20 ] ; then
			# 32-bit apache 2.0
                        if [ ! -e ${TheOpenBDDir}/tomcat_connectors/i386/mod_jk-1.2.27-httpd-2.0.61.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                CopyModJK;
                        fi
		elif [ $APACHEVERSION -eq 13 ] ; then
			# 32-bit apache 1.3
                        if [ ! -e ${TheOpenBDDir}/tomcat_connectors/i386/mod_jk-1.2.27-httpd-1.3.39-eapi.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                CopyModJK;
                        fi
		fi
	elif [ $ISSIXTYFOUR -eq 1 ] ; then
		# check for 64-bit connectors
                if [ $APACHEVERSION -eq 22 ] ; then
                        # 64-bit apache 2.2
                        if [ ! -e ${TheOpenBDDir}/tomcat_connectors/x86_64/mod_jk-1.2.27-httpd-2.2.6.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                CopyModJK;
                        fi
                elif [ $APACHEVERSION -eq 20 ] ; then
                        # 64-bit apache 2.0
                        if [ ! -e ${TheOpenBDDir}/tomcat_connectors/x86_64/mod_jk-1.2.27-httpd-2.0.61.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
                                CopyModJK;
                        fi
                elif [ $APACHEVERSION -eq 13 ] ; then
                        # 64-bit apache 1.3
                        if [ ! -e ${TheOpenBDDir}/tomcat_connectors/x86_64/mod_jk-1.2.27-httpd-1.3.39-eapi.so ] ; then
                                echo "";
                                echo "The connector I need doesn't exist! Aborting connector installation!";
                                echo "";
                        else
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
                        cp -f ${TheOpenBDDir}/tomcat_connectors/i386/mod_jk-1.2.27-httpd-2.2.6.so ${myApacheModulesDir}mod_jk.so
                elif [ $APACHEVERSION -eq 20 ] ; then
                        # 32-bit apache 2.0
                        cp -f ${TheOpenBDDir}/tomcat_connectors/i386/mod_jk-1.2.27-httpd-2.0.61.so ${myApacheModulesDir}mod_jk.so
                elif [ $APACHEVERSION -eq 13 ] ; then
                        # 32-bit apache 1.3
                        cp -f ${TheOpenBDDir}/tomcat_connectors/i386/mod_jk-1.2.27-httpd-1.3.39-eapi.so ${myApacheModulesDir}mod_jk.so
                fi
        elif [ $ISSIXTYFOUR -eq 1 ] ; then
                # check for 64-bit connectors
                if [ $APACHEVERSION -eq 22 ] ; then
                        # 64-bit apache 2.2
                        cp -f ${TheOpenBDDir}/tomcat_connectors/x86_64/mod_jk-1.2.27-httpd-2.2.6.so ${myApacheModulesDir}mod_jk.so
                elif [ $APACHEVERSION -eq 20 ] ; then
                        # 64-bit apache 2.0
                        cp -f ${TheOpenBDDir}/tomcat_connectors/x86_64/mod_jk-1.2.27-httpd-2.0.61.so ${myApacheModulesDir}mod_jk.so
                elif [ $APACHEVERSION -eq 13 ] ; then
                        # 64-bit apache 1.3
                        cp -f ${TheOpenBDDir}/tomcat_connectors/x86_64/mod_jk-1.2.27-httpd-1.3.39-eapi.so ${myApacheModulesDir}mod_jk.so
                fi
        fi
	
	# if this is an upgrade, remove the previous config before adding the new one
	if [ $ISUPGRADE = 1 ] ; then
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
	TEMP=`echo "	JkMount /*.cfres ajp13" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMount /*.cfm/* ajp13" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMount /*.cfml/* ajp13" >> $myApacheConfigFile`;
	TEMP=`echo "	JkMountCopy all" >> $myApacheConfigFile`;
        TEMP=`echo "	JkLogFile ${DefaultJKLogLoc}" >> $myApacheConfigFile`;
	TEMP=`echo "</IfModule>" >> $myApacheConfigFile`;
	
        echo "";
	echo "Attempting to restart Apache to apply configuration changes...";
	TEMP=`$myApacheControlScript restart`;
	echo "[DONE]";
}

function CopyUninstaller {
	# Copy the uninstall directory to openbd's new home
        cp -r ${TheOpenBDDir}/uninstall ${myOpenBDInstallDir}
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
	rm -rf ${TheOpenBDDir};
	echo "[DONE]";
	# remove upgrade files if this is an upgrade
	if [ $ISUPGRADE = 1 ] ; then
        	rm -rf ${DefaultTempDir}/openbd-upgrade;
	fi
}

function WhatNow {
clear;
echo "################################################################################";
echo "#                   Open BlueDragon Installed Successfully!                    #";
echo "################################################################################";
echo "";
echo "";
echo "################################################################################";
echo "#                                                                              #";
echo "# IMPORTANT REMINDER:                                                          #";
echo "#   In order for your Apache VirtualHosts to be handled properly by            #";
echo "#   Tomcat, you MUST UPDATE Tomcat's server.xml file.                          #";
echo "#                                                                              #";
echo "#   This file is located in [OBD Install]/tomcat/conf/server.xml               #";
echo "#                                                                              #";
echo "#   Documentation for this installation can be found online at:                #";
echo "#     http://wiki.openbluedragon.org/wiki/index.php/OpenBD_Installer           #";
echo "#                                                                              #";
echo "#         Visit us online at:      http://www.openbluedragon.org/              #";
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
GetBDBaseDir;
DisplayLicense;
AutoDetectSystemType;
SetDirectoryDefaults;
InstallDirPrompt;
CheckForJDK;
InstallJDK;
CheckForTomcat;
TomcatInstall;
OpenBDPWPrompt;
InstallOpenBD;
CheckTomcatStartup;
CheckApacheConnector;
CopyUninstaller;
AskRemoveInstallFiles;
WhatNow;
