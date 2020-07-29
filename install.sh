#!/bin/bash
#===================================================================================
# install.sh
# UBUNTU - INSTALLATION SCRIPT FOR PRAKTOMAT
#
# COPYRIGHT
#----------------------------------------------------------------------------------
# Copyright (C) 2020, Armin Lehmann
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU General Public License for more details
# (http://www.opensource.org/licenses/gpl-2.0.php).
#===================================================================================

function failure()
{
	printf "\n$@\n"
	exit 2
}

# check if dialog tool is available
function check_dialog()
{
	if [ -z "$DIALOG" ]; then
		DIALOG=`which dialog`

		if [ ! -z "$DIALOG" ]; then
			DIALOG_TYPE=dialog
		fi
	fi

	if [ -z "$DIALOG" ]; then
		failure "You need dialog application to run this script,\nplease install it using 'apt-get install packagename' where packagename is\n'dialog' for dialog."
	fi
}

function dialog_msgbox()
{
	TITLE="$1"
	TEXT="$2"

	$DIALOG --ascii-lines --clear --title "$TITLE" --msgbox "$TEXT" 20 80
}

function dialog_question()
{
	TITLE="$1"
	TEXT="$2"

	$DIALOG --ascii-lines --clear --title "$TITLE" --yesno "$TEXT" 20 80
}

#***********************************************************************************
#	CREATE TEMPORARY FOLDER
#***********************************************************************************

function init_temp_dir()
{
	cd ~

	if [ -a ./install_tmp ]; then
		echo "Erasing existing install_tmp dir..."
		rm -rf ./install_tmp
	fi

	mkdir ./install_tmp
	cd install_tmp
}

#***********************************************************************************
#	WELCOME SCREEN
#***********************************************************************************

function show_welcome_msg
{
	dialog_msgbox "$APPNAME" \
	"$APPNAME is a shell script that setup PRAKTOMAT for you"
}

#***********************************************************************************
#	GET SECURITY UPDATES
#***********************************************************************************

function update_packages()
{
	clear
	echo "#############################################################################"
	echo "UPDATE SOURCES"
	echo "#############################################################################"
	sleep 2
	apt -y update
	sleep 2
	clear
	echo "#############################################################################"
	echo "UPGRADE INSTALLED PACKAGES"
	echo "#############################################################################"
	sleep 2
	apt -y upgrade
	sleep 2
	clear
}

#***********************************************************************************
#	ESSENTIAL SOFTWARE
#***********************************************************************************

function install_basics()
{
	echo "#############################################################################"
	echo " Installing needed software "
	echo "#############################################################################"
	sleep 2
	clear
	echo "#############################################################################"
	echo " install apache2 "
	echo "#############################################################################"
	$APTGETCMD -y install apache2
	sleep 2
	clear
	echo "#############################################################################"
 	echo " install postgresql "
	echo "#############################################################################"
	$APTGETCMD -y install postgresql
	sleep 2
	clear
	echo "#############################################################################"
	echo " install libpq-dev zlib1g-dev libmysqlclient-dev libsasl2-dev libssl-dev "
	echo "#############################################################################"
	$APTGETCMD -y install libpq-dev zlib1g-dev libmysqlclient-dev libsasl2-dev libssl-dev
	sleep 2
	clear
	echo "#############################################################################"
	echo " install swig "
	echo "#############################################################################"
	$APTGETCMD -y install swig
	sleap 2
	clear
	echo "#############################################################################"
	echo " install libapache2-mod-xsendfile libapache2-mod-wsgi-py3 "
	echo "#############################################################################"
	$APTGETCMD -y install libapache2-mod-xsendfile libapache2-mod-wsgi-py3
	sleep 2
	clear
	echo "#############################################################################"
	echo " install openjdk 11 "
	echo "#############################################################################"
	$APTGETCMD -y install openjdk-11-jdk
	sleep 2
	clear
	echo "#############################################################################"
	echo " install junit "
	echo "#############################################################################"
	$APTGETCMD -y install junit junit4
	sleep 2
	clear
	echo "#############################################################################"
	echo " install dejagnu "
	echo "#############################################################################"
	$APTGETCMD -y install dejagnu
	sleep 2
	clear
	echo "#############################################################################"
	echo " install r-base "
	echo "#############################################################################"
	$APTGETCMD -y install r-base
	sleep 2
	clear
	echo "#############################################################################"
	echo " install git-core "
	echo "#############################################################################"
	$APTGETCMD -y install git-core
	sleep 2
	clear
}

#***********************************************************************************
#	INSTALL PYTHON 3
#***********************************************************************************

function install_py3()
{
	echo "#############################################################################"
	echo "Install Python 3"
	echo "#############################################################################"
	sleep 2
	$APTGETCMD -y install python3-pip
	sleep 2
	clear
	echo "#############################################################################"
	echo " install virtualenv setuptools wheel urllib3[secure] "
	echo "#############################################################################"
	pip3 install -U pip virtualenv setuptools wheel urllib3[secure]
	sleep 2
	clear
	echo "#############################################################################"
	echo " install python3-setuptools python3-psycopg2 python3-virtualenv "
	echo "#############################################################################"
	$APTGETCMD -y install python3-setuptools python3-psycopg2 python3-virtualenv
	sleep 2
	clear
}

#***********************************************************************************
#	ADD USER Praktomat TO SYSTEM
#***********************************************************************************

function add_user()
{
	echo "#############################################################################"
	echo "add user Praktomat to sudoer"
	echo "#############################################################################"
	sleep 2
	adduser --disabled-password --gecos "" praktomat
	data=$(dialog --ascii-lines --clear --title "Passwort fuer Praktomat" --no-cancel\
	--inputbox "Bitte das Passwort eingeben:" 10 30 3>&1- 1>&2- 2>&3-)
	echo "praktomat:$data" | chpasswd
	usermod -aG sudo praktomat
	clear
}

#***********************************************************************************
# CREATE FOLDER FOR FIRST PRAKTOMAT
#***********************************************************************************

function create_folder()
{
	echo "#############################################################################"
	echo "Creating folder for first installation"
	echo "#############################################################################"
	cp ~/deploy.sh /srv/deploy.sh
	sleep 2
	echo "changing to directory /srv"
	cd /srv
	echo "creating directories"
	mkdir -p praktomat
	mkdir -p praktomat/contrib
	echo "changing ownership to praktomat"
	chown -R praktomat:praktomat praktomat/
	echo "add praktomat to sudoers list"
 	echo '' >> /etc/sudoers
 	echo '# Praktomat may use safe-docker ' >> /etc/sudoers
	echo 'praktomat ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
#praktomat ALL=NOPASSWD: /usr/local/bin/safe-docker
#praktomat ALL=(tester)NOPASSWD:ALL, NOPASSWD:/usr/local/bin/safe-docker
	echo 'www-data ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
	#echo 'praktomat ALL=NOPASSWD:ALL, NOPASSWD:/usr/local/bin/safe-docker' >> /etc/sudoers
	echo "switching to user praktomat"
	sleep 2
	clear
	su praktomat -c ./deploy.sh
}

#***********************************************************************************
#	CLEAN TEMPORARY FOLDER
#***********************************************************************************

function cleanup()
{
	echo "#############################################################################"
	echo " CLEANUP "
	echo "#############################################################################"
	rm -rf ~/install_tmp

	if [ -a ~/.bash_profile ]; then
		source ~/.bash_profile
	fi

	$APTGETCMD -y clean
	$APTGETCMD -y autoremove
}
#***********************************************************************************
#	MAIN PROGRAM
#***********************************************************************************

#*** Initialization ***
#Set Dialog tool
DIALOG=
DIALOG_TYPE=
check_dialog

#Set application name & version
APPNAME=`basename $0`
VERSION="Version: 0.1"
APTGETCMD=`echo "apt"`

init_temp_dir

#Show welcome screen
show_welcome_msg

#Ask for a confirmation before altering user's system
dialog_question "Confirmation" "Are you sure you want to proceed with the installation?"
case $? in
  0)
    echo "Proceed with the installation.";;
  1)
    echo "Installation aborted."
    exit 0;;
esac

#Proceed with installation
update_packages
install_basics
install_py3
add_user
create_folder

cleanup

echo "Installation completed."
exit 0
