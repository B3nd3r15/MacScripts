#!/bin/bash

###################################################################
# Script Name: letswork.sh
#
# Date Created: 2020-04-21
#
# Description: This script is used to launch work applications
#              and to connect a network share for RoyalTSx. 
#
# Args: N/A
#
# Author: be034739
# Email: blake.eaton@cerner.com
#
###################################################################

# Global variable for date/time format.
TIMESTAMP=$(date +"%F %T: ")

# Function to check to see if Microsoft Teams is running. If it's running move on, if not, start it.
teams(){
# Open Microsoft Teams
SERVICE="Teams"
if pgrep -xq -- "${SERVICE}"; then
     echo
     echo "$TIMESTAMP $SERVICE is running"
     echo
else
    echo
    echo "$TIMESTAMP $SERVICE stopped...Launching."
    echo
    open -a "Microsoft Teams"
fi
}

# Run Split_tunnel script to connect to VPN's.
split_tunnel(){
while true; do
    read -p "Do you need to run split_tunnel?" yn
    case $yn in
        [Yy]* ) /Users/be034739/split_tunnel >> /Users/be034739/split_tunnel.log 2>&1; break;;
        [Nn]* ) echo "Not connecting to split_tunnel.";;
        * ) echo "Please answer yes or no.";;
    esac
done
}

# First let's see if CWxVPN connected, if not exit
check_connectivity() {
    local test_ip
    local test_count

    test_ip="scriptsnas.cernerasp.com"
    test_count=1

    if ping -c ${test_count} ${test_ip} > /dev/null; then
       echo "Have CWxVPN Connectivity, Continuing..."
       echo
    else
       echo "FATAL ERROR: Can't ping scriptsnas.cernerasp.com, Check split_tunnel status. EXITING!!!"
       echo
       exit 1
    fi
}

royaltsx() {
    # Get user password from keychain.    
    PASS="$(security find-generic-password -D '802.1X Password' -l 'assoc-access' -wa "$USER")"
    SERVICE="RoyalTSX"

    while netstat -antu|grep  -q scriptsnas.cernerasp.com; do something; done
    
    # Opens network share
    if [ -d "/Volumes/RoyalTS-Connections" ] 
    then
        echo "Directory RoyalTS-Connections exists." 
        echo
else
        echo "Error: Directory RoyalTS-Connections does not exists but hopefully will in just a second."
        echo
        open "smb://cernerasp;be034739:$PASS@scriptsnas.cernerasp.com/scripts/FrontEnd/RoyalTS-Connections"

        # Sleep for 10 seconds so the share can connect before proceeding
    	sleep 10
fi

    # Open Royal TSX if not already opened.
    if pgrep -x "$SERVICE" >/dev/null
    then
        echo "$SERVICE is running."
        echo
    else
        echo "$SERVICE isn't running...Launching."
        echo
        open -a "Royal TSX"
    fi
}

teams
#split_tunnel
#check_connectivity
#royaltsx
# Self explanatory
exit 0

# The "$@" that follows this line is intentional and exists to allow you to call functions within the script from a command line.
"$@"
