#!/bin/bash
###############################################################################
# Purpose: 	to programmatically remove mod_cfml from Apache
# Author: 	Jordan Michaels (jordan@viviotech.net)
# License:	LGPL 3.0
# 		http://www.opensource.org/licenses/lgpl-3.0.html
#
# Usage:	remove_mod_cfml.sh
#		-f /path/to/apache.conf
#			Full system path to Apache config file.
#			IE: /etc/apache/apache2.conf
#		-d /path/to/apache/modules
#			Full system path to Apache modules directory
#			IE: /usr/lib/apache2/modules (ubuntu 32-bit)
#			    /usr/lib/httpd/modules (centos 32-bit)
#			    /usr/lib64/apache2/modules (ubuntu 64-bit)
#			    /usr/lib64/httpd/modules (centos 64-bit)
#		-c /path/to/apachectl
#			Full system path to Apache Control Script.
#			IE: /usr/sbin/apachectl
###############################################################################

if [ ! $(id -u) = "0" ]; then
        echo "* Error: This script needs to be run as root.";
        echo "* Exiting...";
        exit;
fi

# create the "usage" function to display to improper users
function usage {
cat << EOF
usage: $0 OPTIONS

OPTIONS:
   -f	/path/to/apache.conf	: Full system path to Apache config file.
				  IE: /etc/apache/apache2.conf (debian/ubuntu)
				      /etc/httpd/conf/httpd.conf (redhat/centos)
   -d	/path/to/apache/modules : Full system path to Apache modules directory
				  IE: /usr/lib/apache2/modules (ubuntu 32-bit)
				      /usr/lib/httpd/modules (centos 32-bit)
				      /usr/lib64/apache2/modules (ubuntu 64-bit)
				      /usr/lib64/httpd/modules (centos 64-bit)
   -c	/path/to/apachectl	: Full system path to Apache Control Script.
				  IE: /usr/sbin/apachectl

EOF
}

# declare initial variables (so we can check them later)
myApacheConf=
myApacheCTL=
myApacheMods=

# parse command-line params
while getopts “hf:c:d:” OPTION
do
     case $OPTION in
	 h)
	     usage
	     exit 1
	     ;;
         f)
             myApacheConf=$OPTARG
             ;;
         c)
             myApacheCTL=$OPTARG
             ;;
	 d)
	     myApacheMods=$OPTARG
	     ;;
         ?)
             usage
	     exit
             ;;
     esac
done

###################
# begin functions #
###################

function verifyInput {
	# verify myApacheCTL
	if [[ -z $myApacheCTL ]] || [[ ! -f $myApacheCTL ]] || [[ ! -x $myApacheCTL ]]; then
		echo "* Provided ApacheCTL verification failed.";
	        autodetectApacheCTL;
	fi

	# verify module directory
	if [[ -z $myApacheMods ]] || [[ ! -d $myApacheMods ]] || [[ ! -x $myApacheMods ]]; then
		echo "* Provided Apache module directory verification failed.";
		autodetectApacheMod;
	fi

	# verify apache conf file
	if [[ -z $myApacheConf ]] || [[ ! -f $myApacheConf ]] || [[ ! -w $myApacheConf ]]; then
		echo "* Provided Apache Config file verification failed.";
		audodetectApacheConf;
	fi
} # close verifyInput

function getLinuxVersion {
	# this function is thanks to Arun Singh c/o Novell
	local OS=`uname -s`
	local REV=`uname -r`
	local MACH=`uname -m`

	if [ "${OS}" = "SunOS" ] ; then
		local OS=Solaris
		local ARCH=`uname -p`	
		local OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
	elif [ "${OS}" = "AIX" ] ; then
		local OSSTR="${OS} `oslevel` (`oslevel -r`)"
	elif [ "${OS}" = "Linux" ] ; then
		local KERNEL=`uname -r`
		if [ -f /etc/redhat-release ] ; then
			local DIST='RedHat'
			local PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
			local REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
		elif [ -f /etc/SUSE-release ] ; then
			local DIST=`cat /etc/SUSE-release | tr "\n" ' '| sed s/VERSION.*//`
			local REV=`cat /etc/SUSE-release | tr "\n" ' ' | sed s/.*=\ //`
		elif [ -f /etc/mandrake-release ] ; then
			local DIST='Mandrake'
			local PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
			local REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
		elif [ -f /etc/debian_version ] ; then
			local DIST="Debian `cat /etc/debian_version`"
			local REV=""
		fi
		if [ -f /etc/UnitedLinux-release ] ; then
			local DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
		fi
	
		local OSSTR="${OS} ${DIST} ${REV}(${PSUEDONAME} ${KERNEL} ${MACH})"
	fi
	myLinuxVersion=${OSSTR};
}

function autodetectApacheCTL {
        # this function will be called if the $myApacheCTL variable is blank
        # and can be expanded upon as different OS's are tried and as OS's evolve.
	
	echo "* ApacheCTL undefined, autodetecting...";
	
	# GetLinuxVersion will return myLinuxVersion

	if [[ $myLinuxVersion == *RedHat*  ]] || [[ $myLinuxVersion == *Debian*  ]]; then
		# RedHat and Debian keep the apachectl file in the same place usually,
		# and will also cover CentOS, Ubuntu, and Mint.
		
		echo "* Checking default location of ApacheCTL...";

		local ctlFileFound=0;

		# test the default location
		local defaultLocation="/usr/sbin/apachectl";
		if [[ ! -f ${defaultLocation} ]] || [[ ! -x ${defaultLocation} ]]; then
			echo "* NOT found in /usr/sbin/apachectl...";
		else
			# looks good, set the variable
			myApacheCTL="/usr/sbin/apachectl";
			local ctlFileFound=1;
                        echo "* Found /usr/sbin/apachectl [SUCCESS]";
                fi
	
		local defaultLocation="/usr/sbin/apache2ctl";
                if [[ ! -f ${defaultLocation} ]] || [[ ! -x ${defaultLocation} ]]; then
                        echo "* NOT found in /usr/sbin/apache2ctl...";
                else
                        # looks good, set the variable
                        myApacheCTL="/usr/sbin/apache2ctl";
			local ctlFileFound=1;
                        echo "* Found /usr/sbin/apache2ctl [SUCCESS]";
                fi
			
		if [[ $ctlFileFound -eq 0 ]]; then
                        echo "* [ERROR] Apache control file not provided and not in default location. Unable to continue.";
                        echo "* Use the -c switch to specify the location of the 'apachectl' file manually.";
                        echo "* Exiting...";
                        exit 1;
		fi

	else
                echo "* [ERROR] Apache control file not provided and no default exists for this OS.";
                echo "* Use the -c switch to specify the location of the 'apachectl' file manually.";
                echo "* Exiting...";
                exit 1;
	fi
}

function autodetectApacheMod {
        # this function will be called if the $myApacheMods variable is blank
        # and will attempt to autodetect the apache modules directory based on
	# bit type and OS version.
	
	echo "* Missing or invalid Apache modules directory, attempting autodetect...";
	
	# reset to blank if an invalid dir was specified
	myApacheMods="";
	
        # GetLinuxVersion will return myLinuxVersion

        if [[ $myLinuxVersion == *RedHat*  ]] || [[ $myLinuxVersion == *Debian*  ]]; then
                # if the server is supported, check the default directories
		# should also cover CentOS, Ubuntu and Mint

                local modulesDirFound=0;

                # test the default location
                local defaultLocation="/usr/lib64/httpd/modules";
		echo -n "* Looking for /usr/lib64/httpd/modules...";
                if [[ ! -d ${defaultLocation} ]] || [[ ! -x ${defaultLocation} ]]; then
                        echo "[FAIL] (Doesn't exist or isn't executable)";
                else
                        # looks good, set the variable
                        myApacheMods="/usr/lib64/httpd/modules";
                        local modulesDirFound=1;
                        echo "[SUCCESS]";
                fi

		if [[ ! $modulesDirFound -eq 1 ]]; then
	                local defaultLocation="/usr/lib64/apache2/modules";
	                echo -n "* Looking for /usr/lib64/apache2/modules...";
	                if [[ ! -d ${defaultLocation} ]] || [[ ! -x ${defaultLocation} ]]; then
	                        echo "[FAIL] (Doesn't exist or isn't executable)";
	                else
	                        # looks good, set the variable
	                        myApacheMods="/usr/lib64/apache2/modules";
	                        local modulesDirFound=1;
	                        echo "[SUCCESS]";
	                fi
		fi

                if [[ ! $modulesDirFound -eq 1 ]]; then
                        local defaultLocation="/usr/lib/httpd/modules";
                        echo -n "* Looking for /usr/lib/httpd/modules...";
                        if [[ ! -d ${defaultLocation} ]] || [[ ! -x ${defaultLocation} ]]; then
                                echo "[FAIL] (Doesn't exist or isn't executable)";
                        else
                                # looks good, set the variable
                                myApacheMods="/usr/lib/httpd/modules";
                                local modulesDirFound=1;
                                echo "[SUCCESS]";
                        fi
                fi
                
                if [[ ! $modulesDirFound -eq 1 ]]; then
                        local defaultLocation="/usr/lib/apache2/modules";
                        echo -n "* Looking for /usr/lib/apache2/modules...";
                        if [[ ! -d ${defaultLocation} ]] || [[ ! -x ${defaultLocation} ]]; then
                                echo "[FAIL] (Doesn't exist or isn't executable)";
                        else
                                # looks good, set the variable
                                myApacheMods="/usr/lib/apache2/modules";
                                local modulesDirFound=1;
                                echo "[SUCCESS]";
                        fi
                fi

		# all done looking. Make sure we found it.  
                if [[ $modulesDirFound -eq 0 ]]; then
			echo "* [ERROR] Apache module directory not provided and no default directory found.";
			echo "* Use the -d switch to specify the Apache modules directory manually.";
                        echo "* Exiting...";
                        exit 1;
                fi

        else
                echo "* [ERROR] Apache module directory not provided and no supported OS was found.";
                echo "* Use the -d switch to specify the Apache modules directory manually.";
                echo "* Exiting...";
                exit 1;
        fi

}

function audodetectApacheConf {
	# this function will be called if the $myApacheConf variable is blank
        # and can be expanded upon as different OS's are tried and as OS's evolve.

        echo "* ApacheConf undefined, attempting autodetect...";

	myApacheConf="";

        # GetLinuxVersion will return myLinuxVersion

        if [[ $myLinuxVersion == *RedHat*  ]]; then
		# test the default location
		local defaultLocation="/etc/httpd/conf/httpd.conf";
		echo -n "* Looking for /etc/httpd/conf/httpd.conf...";
		
	        if [[ ! -f $defaultLocation ]] || [[ ! -w $defaultLocation ]]; then
                        echo "[FAIL]";
                        echo "* [ERROR] Apache config file not provided, not in default location or not writable.";
			echo "* Unable to continue. Use the -f switch to specify the location of the Apache";
			echo "* config file manually.";
                        echo "* Exiting...";
                        exit 1;
                else
                        # looks good, set the variable
                        myApacheConf=$defaultLocation;
                        echo "[SUCCESS]";
		fi

	elif [[ $myLinuxVersion == *Debian*  ]]; then
                # test the default location
                local defaultLocation="/etc/apache2/apache2.conf";
		echo -n "* Looking for /etc/apache2/apache2.conf...";

                if [[ ! -f ${defaultLocation} ]] || [[ ! -w $defaultLocation ]]; then
                        echo "[FAIL]";
                        echo "* [ERROR] Apache config file not provided, not in default location or not writable.";
                        echo "* Unable to continue. Use the -f switch to specify the location of the Apache";
                        echo "* config file manually.";
                        echo "* Exiting...";
                        exit 1;
                else
                        # looks good, set the variable
                        myApacheConf=$defaultLocation;
                        echo "[SUCCESS]";
                fi
        fi

        if [[ -z $myApacheConf ]]; then
                # if we're still empty, script can't find it.
                echo "* [ERROR] No Apache config file provided and can't autodetect.";
                echo "* You can manually set the Apache config file using the -f switch.";
                echo "* Exiting...";
                exit 1;
        fi
}

function autodetectApacheVersion {
	echo "* Attempting to detect Apache version...";
	
	# parse the result to save the Apache version
	if [[ `$myApacheCTL -V | grep 'Apache/2.4'` ]]; then
		echo "* Found Apache version 2.4 [SUCCESS]";
		myApacheVersion="24";
	elif [[ `$myApacheCTL -V | grep 'Apache/2.2'` ]]; then
		echo "* Found Apache version 2.2 [SUCCESS]";
		myApacheVersion="22";
	else
		echo "* [ERROR] Unable to detect Apache version or version not supported.";
		echo "* Unable to continue.";
		echo "* Exiting... ";
		exit 1;
	fi
	
	# check for 32-bit Apache 2.4 (not supported - does it exist?)
	if [[ ! `uname -m` == "x86_64" ]] && [[ $myApacheVersion == "24" ]]; then
		echo "* [ERROR] Apache 2.4 on 32-bit systems is not supported. Aborting...";
		exit 1;
	fi
}

function checkModCFMLInstalled {
	echo -n "* Checking for pre-existing mod_cfml install...";

        if [[ $myLinuxVersion == *Debian*  ]]; then
                # if it's debian, we can use the a2query tool
                a2query -q -m modmodcfml;
                if [ $? -eq 0 ]; then
                        # exit code 0 means module was found
                        echo "[FOUND]";
                else
                        echo "[NOT FOUND]";
                        echo "* [NOTICE] mod_cfml doesn't appear to be installed.";
                        echo "* Nothing to do.";
                        exit 0;
                fi
        else
                # if it's something else, default to RedHat and see if the mod_cfml config is present in httpd.conf
                myLinuxVersion="RedHat";
                myModCFMLFound=`cat ${myApacheConf} | grep -c mod_cfml`;

                if [[ "$myModCFMLFound" -gt "0" ]]; then
                        echo "[FOUND]";
                else
                        echo "[NOT FOUND]";
                        echo "* [NOTICE] mod_cfml doesn't appear to be installed.";
                        echo "* Nothing to do.";
                        exit 0;
                fi

        fi
}

function removeModCFML {
	# remove configs/files
	if [[ $myLinuxVersion == *RedHat*  ]]; then
		# remove for CentOS
	        echo -n "* Removing mod_cfml from Apache config...";
		sed -i '/^LoadModule\ modcfml_module/d' $myApacheConf;
		sed -i '/^CFMLHandlers/d' $myApacheConf;
		sed -i '/^ModCFML_SharedKey/d' $myApacheConf;
		sed -i '/^LogHeaders/d' $myApacheConf;
		sed -i '/^LogHandlers/d' $myApacheConf;
		sed -i '/^LogAliases/d' $myApacheConf;
		sed -i '/^VDirHeader/d' $myApacheConf;
		echo "[SUCCESS]";
	elif [[ $myLinuxVersion == *Debian*  ]]; then

		# get the base apache config directory
		baseapacheconf=$( cd "$( dirname "$myApacheConf" )" && pwd );

		# disable module
		a2dismod modcfml;
                if [ ! $? -eq 0 ]; then
                        echo "* [ERROR] Cannot disable mod_cfml module.";
                        echo "* Please try to manually disable with 'a2dismod modcfml'.";
                        echo "* Aborting....";
                        exit 1;
                fi

		# test for standard 'mods-available' directory
		echo -n "* Verifying mods-available: $baseapacheconf/mods-available/...";
		if [[ ! -d $baseapacheconf/mods-available/ ]] || [[ ! -x $baseapacheconf/mods-available/ ]] || [[ ! -w $baseapacheconf/mods-available/ ]]; then
			echo "[FAIL]";
			echo "* Directory either doesn't exist or has wrong permissions.";
			exit 1;
		else
			echo "[SUCCESS]";
		fi
		
		# remove loader
		echo "* Removing mod_cfml load file: ${baseapacheconf}/mods-available/modcfml.load...";
		rm -rf "${baseapacheconf}/mods-available/modcfml.load";
		if [ ! $? -eq 0 ]; then
                        echo "* [FAIL] Unable to remove modcfml.load.";
                        echo "* File must be manually removed.";
                fi
	
		# remove config
		echo "* Removing mod_cfml config file: ${baseapacheconf}/mods-available/modcfml.conf...";
		rm -rf "${baseapacheconf}/mods-available/modcfml.conf";
                if [ ! $? -eq 0 ]; then
                        echo "* [FAIL] Unable to remove modcfml.conf.";
                        echo "* File must be manually removed.";
                fi
		
	fi

	# restart apache so changes take effect
	echo "* Restarting Apache so changes take effect...";
	$myApacheCTL restart;
	if [ ! $? -eq 0 ]; then
                echo "* [FAIL]";
		echo "* Apache restart failed. Please try to restart manually.";
                echo "* Aborting....";
                exit 1;
        fi

	# finally, remove the actual mod_cfml.so file
        echo -n "* Removing mod_cfml.so from file system...";
        rm -rf ${myApacheMods}/mod_cfml.so;
        if [ ! $? -eq 0 ]; then
                echo "[FAIL]";
                echo "* Cannot remove: ${myApacheMods}/mod_cfml.so";
	else
		echo "[SUCCESS]";
        fi

	echo "* mod_cfml removal complete.";
}

#####################
# Run function list #
#####################

# start by verifying input
getLinuxVersion;
verifyInput;
autodetectApacheVersion;
checkModCFMLInstalled;
removeModCFML;
