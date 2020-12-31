#!/usr/bin/env bash

#########################################################
#  _____                   _ _____           _          #
# |_   _|__ _ __ _ __ ___ (_)_   _|__   ___ | |___      #
#   | |/ _ \ '__| '_ ` _ \| | | |/ _ \ / _ \| / __|     #
#   | |  __/ |  | | | | | | | | | (_) | (_) | \__ \     #
#   |_|\___|_|  |_| |_| |_|_| |_|\___/ \___/|_|___/     #
#                                                       #
#               WRITTEN BY ROBIN BOERS                  #
#########################################################

name=$(whoami)

# Check if script is running as root
if ! [ $(id -u) = 0 ]; then
   whiptail --title "Error" --msgbox "\
This script needs to be run as root for it to work propperly.\
" 20 70 1
   exit
fi

function _about_screen() {

  whiptail --title "About" --msgbox "\
This tool can be used to configure any debian based 
installation from the commandline. It can setup wifi, change hostname, 
change root password and install a very basic and lightweight desktop.
It is made by Robin Boers, who is also known as Robijntje.\
" 20 70 1

}

function _not_done_screen() {

    whiptail --title "WIP" --msgbox "This module isn't finished yet." 20 70 1

}

function _experimental_screen() {
    EXMENU=$(whiptail --title "Experimental" --backtitle "USE AT OWN RISK" --menu "Choose an option" 20 70 4 \
        "1" "Install desktop" \
        "2" "Nothing at all, just placeholder" \
        "3" "Back" 3>&1 1>&2 2>&3)
    case $EXMENU in
        1)
            _install_desktop
        ;;
        2)
            whiptail --title "Placeholder" --msgbox "Absolutly nothing here, why didn't you believe me?!\n\ntest test test\nFizzBuzz\nHello, W0rld!" 20 70
        ;;
        3)
            # Return to main menu (yeah, that is automatic, so this is just kinda chilling here :) )
        ;;
    esac
}

function _system_info_screen() {

    # Get system info
    uptime=$(uptime | awk '{print $3;}')
    hostname=`cat /etc/hostname | tr -d " \t\n\r"`
    username=$(whoami)

    # Print system info
    whiptail --title "System Info" --msgbox "\
Uptime: $uptime 
Hostname: $hostname 
Username: $username\
" 20 70 1
}

function _set_wifi() {
    local action="$1"

    if [[ "$action" == "up" ]]; then
        if ! ifup wlan0; then
            ip link set wlan0 up
        fi
    elif [[ "$action" == "down" ]]; then
        if ! ifdown wlan0; then
            ip link set wlan0 down
        fi
    fi

}

function _install_desktop() {
    sudo apt -y install xorg openbox opconf obsession obmenu lxappearance lxrandr tint2 xterm
}

function _configure_locale() {
  dpkg-reconfigure locales
}

function _configure_timezone() {
    dpkg-reconfigure tzdata
}

function _configure_rootpass() {
    passwd root
}

function _configure_hostname() {

    # Display message to show the used what characters are allowed
    whiptail  --title "Hostname" --msgbox "\
Only the letters 'a' trough 'z', the digits '0' trough '9' and the hyphen are permitted. 
The hostname cannot have any spaces in it, nor can it start with a hyphen.\
" 20 70 1

    # Get currenct hostname, and ask for new one
    HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
    N_HOSTNAME=$(whiptail  --title "Hostname" --inputbox "Enter hostname" 20 60 "$CURRENT_HOSTNAME" 3>&1 1>&2 2>&3)

    # Write new hostname to file
    echo $NEW_HOSTNAME > /etc/hostname
    sed -i "s/127.0.1.1.*$HOSTNAME/127.0.1.1\t$N_HOSTNAME/g" /etc/hosts

    whiptail --title "Hostname" --msgbox "\
Please reboot now.\
" 20 70 1

}

while [ 1 ]
do
MENU=$(
whiptail --title "TermiTools" --menu "Choose setting to configure:" 20 70 9 --nocancel --backtitle "Made by Robin Boers" --ok-button Select \
	"1)" "Configure WiFi"   \
	"2)" "Configure locale"  \
	"3)" "Configure timezone" \
	"4)" "Change hostname" \
    "5)" "Change root password" \
	"6)" "System Info" \
	"7)" "About TermiTools" \
    "8)" "Experimental" \
	"9)" "Exit"  3>&2 2>&1 1>&3	
)


case $MENU in
	"1)")   
		_not_done_screen
	;;
	"2)")   
	    _configure_locale
	;;

	"3)")   
	    _configure_timezone
    ;;

	"4)")   
	    _configure_hostname
    ;;

	"5)")   
        _configure_rootpass
    ;;

	"6)")   
        _system_info_screen
    ;;

    "7)")   
        _about_screen
    ;;
    
    "8)")   
        _experimental_screen
    ;;

	"9)") exit
        ;;
esac
# Do nothing yet
done