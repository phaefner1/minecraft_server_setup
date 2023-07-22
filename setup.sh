#!/bin/bash

# Name:                      :::!~!!!!!:.
# mc_server_setup.sh    .xUHWH!! !!?M88WHX:.
#                     .X*#M@$!!  !X!M$$$$$$WWx:.
# Author:            :!!!!!!?H! :!$!$$$$$$$$$$8X:
# phil              !!~  ~:~!! :~!$!#$$$$$$$$$$8X:
#                  :!~::!H!<   ~.U$X!?R$$$$$$$$MM!
# Date:            ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!
# 15.07.23           !:~~~ .:!M"T#$$$$WX??#MRRMMM!
#                    ~?WuxiW*`   `"#$$$$8!!!!??!!!
# Version:         :X- M$$$$       `"T#$T~!8$WUXU~
# 1.0             :%`  ~#$$$m:        ~!~ ?$$$$$$
#               :!`.-   ~T$$$$8xx.  .xWW- ~""##*"
#     .....   -~~:<` !    ~?T#$$@@W@*?$$      /`
#   &TW$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :
#-~#?>#"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`
#..-<=:::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~
#=#$$-.~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `
#MM$#WWi.~!X$?!-~    : ?$$$B$Wu("**$RM!
#?JMM%$R@i.~~ !     :   ~$$$$$B$$en:``
#  \W!?MXT@Wx.~    :     ~"##*$$$$M~
#
# 
# Description:
# Automatically sets up a minecraft server on 
# the version of your choice and starts it.
#


# Set Lockfile
#
lockfile=/tmp/mc_server_setup.lock
 
set_lock() {
    	if [ -e $lockfile ]; then
        	echo "Lockfile exists already. Script might be running?.."
        	exit 1
    	else
        	touch $lockfile
        	echo "Lockfile created."
 	fi
}


# Version Select
#
choose_version() {
    echo -e "\nPlease select a Spigot Version:"
    select version in spigot-1.7.9.jar spigot-1.8.jar spigot-1.9.jar spigot-1.10.jar spigot-1.11.jar spigot-1.12.jar spigot-1.13.jar spigot-1.14.jar spigot-1.15.jar spigot-1.16.jar spigot-1.17.jar spigot-1.18.jar spigot-1.19.jar; do
        echo "You selected  $version "
        break
    done
}


# Download JAR-File
#
jar_download() {
	echo -e "\nStarting JAR-Download.."
	wget "lowelo.de/mc_versions/$version" > /dev/null 2>&1
    	if [ $? -ne 0 ]; then
        	echo "Download failed for version $version"
    		break
	fi
	echo "Download successful."
}


# Check Distribution
#
check_os() {
	echo -e "\nChecking for OS Version.."
    	if [ -f /etc/os-release ]; then
        	. /etc/os-release
        	echo "OS: Linux"
        	echo "Name: $NAME"
        	echo "Version: $VERSION_ID"
    	else
        	echo "Couldn't find Linux Distribution."
		break 
	fi
}


# Check if Screen is installed
#
check_screen() {
	echo -e "\nChecking for Screen installation.."
    	if command -v screen >/dev/null 2>&1; then
        	echo "Screen is already installed."
    	else
        	echo -e "Screen is not installed. Starting installation...\n\n"
        	if [ -f /etc/os-release ]; then
            		. /etc/os-release
            	   case $ID in
                	debian|ubuntu|linuxmint)
                    		sudo apt-get update
                    		sudo apt-get install -y screen
                    	;;
                	centos|fedora|rhel)
                    		sudo yum install -y screen
                    	;;
                	suse|opensuse*)
                    		sudo zypper install -y screen
                    	;;
                	arch|manjaro)
                    		sudo pacman -Syu screen
                    	;;
                	*)
                    	echo "Couldn't install 'screen'. Unknown Linux-Distribution."
                    	break
			;;
            	   esac
        	else
            echo "Cancelling screen installation. Couldn't find Linux-Distribution name."
        fi
    fi
}


# Main Function
#
main() {
	set_lock
	choose_version
	jar_download
	check_os
	check_screen

	rm $lockfile
	echo -e "\nLockfile removed."
}

main


