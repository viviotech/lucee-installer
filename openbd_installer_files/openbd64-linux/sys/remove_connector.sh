#!/bin/bash
####################################################################################
# Written By: Jordan Michaels (jordan@viviotech.net)
####################################################################################
# Purpose:    This is an uninstallation script for the Open BlueDragon Project
#             that removes the componants that were installed by the installation
#             script that accompanied this distribution of OpenBD.
#
# Usage:      ./remove_connector.sh /path/to/apache.conf
####################################################################################
# LICENSE:    http://www.opensource.org/licenses/bsd-license.php
####################################################################################
# Copyright (c) 2009, Jordan Michaels, Vivio Technologies
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

if [ ! $(id -u) = "0" ]; then
	echo "This script needs to be run as root.";
        echo "Exiting...";
        exit;
fi

# make sure the first parameter was specified and assign it a variable name
if [ -z $1 ]; then
	echo "No Apache config file specified."
	echo "Usage: ./remove_connector.sh /path/to/apache.conf";
	exit;
else
	myApacheConfigFile=$1;
fi


# Make sure the file exists
if [ ! -e $myApacheConfigFile ] ; then
        echo "The file you spefied doesn't exist.";
        echo "Exiting...";
	exit;
fi

echo "";
# grep the conf file to see if mod_jk is present already
JKLineCount=`cat $myApacheConfigFile | grep -c mod_jk.so`;
if [ $JKLineCount -eq 0 ] ; then
        echo "It doesn't look like mod_jk is installed...";
	echo "Exiting...";
	exit;
fi

# remove the <IfModule !mod_jk.c> segment...
sed -i '/<IfModule !mod_jk.c>/,/<\/IfModule>/d' $myApacheConfigFile
	
# remove the <IfModule mod_jk.c> segment...
sed -i '/<IfModule mod_jk.c>/,/<\/IfModule>/d' $myApacheConfigFile
	
echo "";
echo "Mod_JK entries removed...";

sed -i '/^PerlRequire/d' $myApacheConfigFile
sed -i '/^PerlHeaderParserHandler/d' $myApacheConfigFile
sed -i '/^PerlSetVar/d' $myApacheConfigFile

echo "Mod_CFML entries removed...";

echo "Apache config updated sucessfully.";
echo "";
