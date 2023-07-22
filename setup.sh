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


# Color Vars
#
light_blue="\e[34m"
dark_blue="\e[36m"
green="\e[32m"
red="\e[31m"
reset="\e[0m"


# Set Lockfile
#
lockfile=/tmp/mc_server_setup.lock
 
set_lock() {
    	if [ -e $lockfile ]; then
        	echo -e "${red}Lockfile exists already. Script might be running?..${reset}"
        	exit 1
    	else
        	touch $lockfile
        	echo -e "${green}Lockfile created.${reset}"
 	fi
}


# Version Select
#
choose_version() {
    echo -e "\n${light_blue}Please select a Spigot Version:"
    select version in spigot-1.7.9.jar spigot-1.8.jar spigot-1.9.jar spigot-1.10.jar spigot-1.11.jar spigot-1.12.jar spigot-1.13.jar spigot-1.14.jar spigot-1.15.jar spigot-1.16.jar spigot-1.17.jar spigot-1.18.jar spigot-1.19.jar; do
        echo -e "You selected  $version ${reset}"
        break
    done
}


# Download JAR-File
#
jar_download() {
	echo -e "\n${dark_blue}Starting JAR-Download..${reset}"
	wget -c "lowelo.de/mc_versions/$version" -O Spigot.jar > /dev/null 2>&1
    	if [ $? -ne 0 ]; then
        	echo -e "${red}Download failed for version $version${reset}"
		rm $lockfile 
   		break
	fi
	echo -e "${green}Download successful.${reset}"
}


# Check Distribution
#
check_os() {
	echo -e "\n${light_blue}Checking for OS Version.."
    	if [ -f /etc/os-release ]; then
        	. /etc/os-release
        	echo -e "	OS: Linux"
        	echo -e "	Name: $NAME"
        	echo -e "	Version: $VERSION_ID"
    	else
        	echo -e "${red}Couldn't find Linux Distribution.${reset}"
		break 
	fi
}


# Check if Screen is installed
#
check_screen() {
	echo -e "\n${dark_blue}Checking for Screen installation..${reset}"
    	if command -v screen >/dev/null 2>&1; then
        	echo -e "${green}Screen is already installed.${reset}"
    	else
        	echo -e "${dark_blue}Screen is not installed. Starting installation...${reset}\n\n"
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
                    	echo -e "${red}Couldn't install 'screen'. Unknown Linux-Distribution.${reset}"
                    	break
			;;
            	   esac
        	else
            echo -e "${red}Cancelling screen installation. Couldn't find Linux-Distribution name.${reset}"
        fi
    fi
}


# Check & Ask for Server RAM
#
chosen_ram=0
check_ram() {
	system_ram=$(free -g | awk '/Mem:/ {print $2}')
	echo -e "${light_blue}\n\nTotal Memory: $system_ram GB.${reset}"
	echo -e "${light_blue}We recommend atleast 2 GB of RAM for ur server.${reset}"
	echo -e "${light_blue}Enter RAM Amount : ${reset}" 
	read chosen_ram

	# Check if the chosen_ram is a number
	if ! [[ "$chosen_ram" =~ ^[0-9]+$ ]] ; then
   		echo -e "${red}Error: Not a number${reset}" >&2; rm $lockfile; exit 1
	fi

	# Check if the chosen_ram is between 0 and max_ram
	if ((chosen_ram >= 0 && chosen_ram <= system_ram)); then
		echo -e "${green}$chosen_ram GB RAM selected.${reset}"
	else
  		echo -e "${red}Error: The entered RAM amount is not within the valid range (0-$system_ram).${reset}" >&2; rm $lockfile; exit 1
	fi
}


# Create start.sh
#
server_name="MinecraftServer"
create_startsh() {
	echo -e "${dark_blue}\n\nPlease enter the Servers name:${reset}"
	read server_name
	server_name=$(echo "${server_name}" | sed 's/[^a-zA-Z0-9]//g')
	
	echo -e "${dark_blue}\nStarting creation of start.sh${reset}"
	echo "screen -S $server_name java -Xms${chosen_ram}G -Xmx${chosen_ram}G -jar Spigot.jar" > start.sh
	echo -e "${green}Successfully created start.sh.${reset}"
	chmod 755 start.sh
	echo -e "${green}Successfully set file permissions."
}


# Create eula file
#
create_eula() {
	echo -e "${light_blue}\n\nCreating eula file.${reset}" 
	echo "eula=true" > eula.txt
	echo -e "${green}Successfully created eula file."
}


# Server Boot
#
server_boot() {
	echo -e "${dark_blue}\n\nServer ready for bootup.${reset}"
	read -p "Continue with server boot? (y/n): " confirm
	if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
    		echo -e "${green}Starting server..${reset}"
		./start.sh 
	else
		rm $lockfile
		exit
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
	check_ram
	create_startsh
	create_eula
	server_boot

	rm $lockfile
	echo -e "\nLockfile removed."
}

main


