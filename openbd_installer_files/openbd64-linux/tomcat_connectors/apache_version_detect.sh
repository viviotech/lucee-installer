#!/bin/bash
################################################################################
# Written By: Jordan Michaels (jordan@viviotech.net)
# Purpose:
#   The purpose of this script is to work with the BitRock installer for Linux
#   32 and 64-bit versions in order to help the user determine what version of
#   Apache they are running. The script takes one paramater (the apache binary
#   location) and implements it to check for a version number. The result is
#   then displayed to the end user to aid them in their version determination.
################################################################################

if [ -z $1 ] ; then
	echo "";
#	echo "Error: missing apache binary location.";
#	echo "Usage: ./apache_version_detect.sh /path/to/apache/binary";
#	echo "Please try again.";
#	echo "";
	exit;
elif [ ! -f $1 ] ; then
	echo "";
#	echo "Error: Not a file.";
#        echo "Usage: ./apache_version_detect.sh /path/to/apache/binary";
#        echo "Please try again.";
#	echo "";
	exit;
fi

myApacheBinaryLocation=$1;

function AutoDetectApacheVersion {
        if [ ! $myApacheBinaryLocation ] ; then
                # if the binary has not been specified... kick back...
                GetApacheBinaryLocation;
        fi
        # echo -n "Attempting to autodetect Apache version...";
        if [ `${myApacheBinaryLocation} -version | grep -c 'Apache/2.2'` -gt 0 ] ; then
                echo "I think it's Apache 2.2, but I could be wrong.";
        elif [ `${myApacheBinaryLocation} -version | grep -c 'Apache/2.0'` -gt 0 ] ; then
                echo "I think it's Apache 2.0, but I could be wrong.";
        elif [ `${myApacheBinaryLocation} -version | grep -c 'Apache/1.3'` -gt 0 ] ; then
                echo "I think it's Apache 1.3, but I could be wrong.";
        else
                echo "";
        fi
}

AutoDetectApacheVersion;
exit;


