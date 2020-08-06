#!/bin/bash

#################################################################################################################
#
# NAME: work.sh
#
# AUTHOR: B3nd3r15
#
# SUPPORT: None
#
# DESCRIPTION: Useful commands/scripts that I use all the time. 
#
# License: GPL-3.0
# https://github.com/B3nd3r15/linuxscripts/blob/master/LICENSE
#
#################################################################################################################
#
# ASSUMPTIONS: Script is run manually, target server has access to internet.
#
# INSTALL LOCATION: Where your heart desires.
#
#################################################################################################################
#
#       Commands: Menu Driven.
#           
#
#################################################################################################################
#
#    Version      AUTHOR      DATE          COMMENTS
#                 ------      ----          --------
#  VER 1.0.1      B3nd3r      2020/05/05    Added disconnect_split_tunnel function.
#  VER 1.0.0      B3nd3r      2020/05/01    Initial creation and release.
#
#################################################################################################################


#-----------------------------------------------
# Script Version for updating.
#-----------------------------------------------
version=1.0.1

# A menu driven shell script
# ----------------------------------
# Define variables
# ----------------------------------

#----------------------------------
# Bash Colors.
#----------------------------------
reset="\033[0m"           # Reset
red="\033[0;31m"          # Red
green="\033[0;32m"        # Green
yellow="\033[0;33m"       # Yellow
blue="\033[0;34m"         # Blue
cyan="\033[0;36m"         # Cyan
#white="\033[0;37m"        # White
check="\xE2\x9C\x94"      # Check Mark


# Various variables used throughout the script.
TEST_SERVER="scriptsnas.cernerasp.com"
TEST_COUNT=1
PASS="$(security find-generic-password -D '802.1X Password' -l 'assoc-access' -wa "$USER")"
SERVICE="RoyalTSX"
SPLIT_TUNNEL="/Users/be034739/scripts/split_tunnel"
CLOSE_SPLIT_TUNNEL="/Users/be034739/scripts/close_split_tunnel"
SPLIT_TUNNEL_LOG="/Users/be034739/scripts/split_tunnel.log"
CLOSE_SPLIT_TUNNEL_LOG="/Users/be034739/scripts/close_split_tunnel.log"
 
# ----------------------------------
# User defined functions
# ----------------------------------
pause(){
    echo
  #read -p "\033[0;36m "Press [Enter] key to continue..." "$reset" fackEnterKey
  read -rp "$(echo -e "$cyan" "Press [Enter] key to continue... ""$reset")"
    echo
}

# error output for menu
invalid_entry(){
echo
echo -e "$red" "Error...Invalid Entry...Please try again..." "$reset" && sleep 2
echo
}

# Check github for updated version
self_update() {
#    cd $SCRIPTPATH
#    git fetch
#
#    [ -n $(git diff --name-only origin/$BRANCH | grep $SCRIPTNAME) ] && {
#        echo -e "$yellow" "Found a new version of me, updating myself..." "$reset"
#        git pull --force
#        git checkout $BRANCH
#        git pull --force
#        echo -e "$green" "$check" "Running the new version..." "$reset"
#        exec "$SCRIPTNAME" "$@"
#        # Now exit this old instance
#        exit 1
#    }
#    echo -e "$green" "$check" "Already the latest version." "$reset"
echo
echo -e "$yellow" "This functionality is still under development!" "$reset"
    pause
}

teams(){
	SERVICE="Teams"
if pgrep -xq -- "${SERVICE}"; then
     echo
     echo -e "$green" "$check" "$SERVICE is running" "$reset"
     echo
else
    echo
    echo -e "$yellow" "$SERVICE stopped...Launching." "$reset"
    echo
    open -a "Microsoft Teams"
fi
pause
}

# First let's see if CWxVPN connected, if not exit
check_connectivity() {
    if ping -c ${TEST_COUNT} ${TEST_SERVER} > /dev/null; then
       echo
       echo -e "$green" "$check" "CWxVPN connectivity check completed and successful. Returning to Main Menu." "$reset"
       echo
    else
       echo
       echo -e "$red" "FATAL ERROR: CWxVPN connectivity check FAILED, Check split_tunnel status. Returning to Main Menu!!!" "$reset"
       echo
    pause
    fi
}

# Just in case we need to mount the network share only
share_connect(){
    # Get user password from keychain.    
    #PASS="$(security find-generic-password -D '802.1X Password' -l 'assoc-access' -wa "$USER")"
    #SERVICE="RoyalTSX"
    
    # Opens network share. First checks to see if it is already mounted. If so move on, if not mount it
    if [ -d "/Volumes/RoyalTS-Connections" ] 
    then
        echo
        echo -e "$green" "Directory RoyalTS-Connections exists." "$reset"
        echo
else
        echo
        echo -e "$red" "Error: Directory RoyalTS-Connections does not exists but hopefully will in just a second." "$reset"
        echo
        open "smb://cernerasp;be034739:$PASS@scriptsnas.cernerasp.com/scripts/FrontEnd/RoyalTS-Connections"
    # Sleep for 10 seconds so the share can connect before proceeding
    sleep 10
fi

}
 
# do something in royaltsx()
royaltsx() {
    check_connectivity
    
    # Opens network share. First checks to see if it is already mounted. If so move on, if not mount it
    if [ -d "/Volumes/RoyalTS-Connections" ] 
    then
        echo
        echo -e "$green" "Directory RoyalTS-Connections exists." "$reset"
        echo
else
        echo
        echo -e "$red" "Error: Directory RoyalTS-Connections does not exists but hopefully will in just a second." "$reset"
        echo
        open "smb://cernerasp;be034739:$PASS@scriptsnas.cernerasp.com/scripts/FrontEnd/RoyalTS-Connections"

        # Sleep for 10 seconds so the share can connect before proceeding
    	sleep 10
fi
    # Open Royal TSX if not already opened.
    if pgrep -x "$SERVICE" >/dev/null
    then
        echo
        echo -e "$green" "check" "$SERVICE is running." "$reset"
        echo
    else
        echo
        echo -e "$red" "$SERVICE isn't running...Launching." "$reset"
        echo
        open -a "Royal TSX"
    fi
   pause
}

# Runs the split_tunnel script.
split_tunnel(){
	if [ -f "/var/run/openconnect-corp.pid" ]
	then
		echo
		echo -e "$green" "$check" "Looks like we're connected." "$reset"
		echo
	else
		echo
		echo -e "$yellow" "Did not see openconnect-corp.pid file. Let's get connected." "$reset"
		"$SPLIT_TUNNEL" -v >> "$SPLIT_TUNNEL_LOG" 2>&1;
	fi
	pause
}

# Checks for cwxvpn connectivity
cwxvpn(){
	check_connectivity
	"$SPLIT_TUNNEL" -cv >> "$SPLIT_TUNNEL_LOG" 2>&1;
pause
}

# Used to disconnect from split_tunnel vpn's
disconnect_split_tunnel(){
    echo
	sudo "$CLOSE_SPLIT_TUNNEL" >> "$CLOSE_SPLIT_TUNNEL_LOG" 2>&1;
	echo
	pause
}
 
# function to display menus
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U | Version:$version "
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Launch Teams"
	echo "2. Launch RoyalTSX"
	echo "3. Connect to VPN's"
	echo "4. Connect CWxVPN Only"
	echo "5. Check CWxVPN Connectivity"
	echo "6. Disconnect VPN's"
	echo "7. Check for script updates"

	echo
	echo "0. Exit"
}
# read input from the keyboard and take a action
# invoke the teams() when the user selects 1 from the menu option.
# invoke the royaltsx() when the user selects 2 from the menu option.
# invoke the split_tunnel() when user selects 3 from the menu option.
# invoke the cwxvpn() when user selects 4 from the menu option.
# invoke the check_connectivity() when user selects 5 from the menu option.
# invoke the disconnect_split_tunnel() when user selects 6 from the menu option.
# invoke the self_update() when user selects 7 from the menu option.
# Exit when user the user selects 0 form the menu option.
read_options(){
	local choice
	read -rp "Enter choice [ 0 - 7] " choice
	case $choice in
		1) teams ;;
		2) royaltsx ;;
		3) split_tunnel ;;
		4) cwxvpn ;;
		5) check_connectivity ;;
		6) disconnect_split_tunnel ;;
		7) self_update ;;
		0) exit 0;;
		*) invalid_entry ;;
	esac
}
 
# ----------------------------------------------
# Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Main logic - infinite loop
# ------------------------------------
while true
do
 
	show_menus
	read_options
done