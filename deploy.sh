#!/bin/bash
#===================================================================================
# deploy.sh
# UBUNTU - DEPLOYMENT SCRIPT FOR PRAKTOMAT
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

#***********************************************************************************
# CLONE GIT REPOSITORY FOR FIRST PRAKTOMAT
#***********************************************************************************

function get_repository()
{
	echo "#############################################################################"
	echo "Clone repository"
	echo "#############################################################################"
	sleep 2
	git clone --branch FRA-UAS git://github.com/schlom/Praktomat-1.git /srv/praktomat/"$name"/Praktomat
	sudo chmod -R 0775 Praktomat
    sudo chown -R praktomat:praktomat Praktomat
}

#***********************************************************************************
# CREATE FIRST PRAKTOMAT
#***********************************************************************************

function create_praktomat()
{
	clear
	cp /srv/praktomat/"$name"/Praktomat/docker-image/contrib/checkstyle-8.29-all.jar /srv/praktomat/contrib/
	cp /srv/praktomat/"$name"/Praktomat/docker-image/contrib/jplag-2.12.1-SNAPSHOT-jar-with-dependencies.jar /srv/praktomat/contrib/
	cd /srv/praktomat/"$name"
	echo "##############################################"
	echo "# create virtualenv "
	echo "##############################################"
	virtualenv -p python3 --system-site-packages env/
	sleep 2
	clear
	echo "##############################################"
	echo "# switching to virtualenv "
	echo "# and install requirements"
	echo "##############################################"
	. env/bin/activate
	pip install -r Praktomat/requirements.txt
	sleep 2
	clear
	echo "##############################################"
	echo "# create new database for $name "
	echo "##############################################"
	sudo -u postgres createuser -DRS praktomat
	sudo -u postgres createdb -O praktomat "$name"
	sleep 2
	clear
	echo "##############################################"
	echo "# set local.py "
	echo "##############################################"
	ipaddr=`dialog --ascii-lines --no-cancel --clear --inputbox "Geben Sie die URL des Praktomaten ein!\n\
	\n\
	\n Die URL ueber die die Seite erreichbar sein soll, z.B. http://localhost:8000" \
	0 0 "http://10.18.2.59:8000" 3>&1 1>&2 2>&3`
	sed -i "s|BASE_HOST = .*|BASE_HOST = \'${ipaddr}\'|" /srv/praktomat/"$name"/Praktomat/src/settings/local.py

	DST_FILE=/srv/praktomat/"$name"/Praktomat/src/email_settings.py
	EMAIL_BACKEND="django.core.mail.backends.smtp.EmailBackend"
    EMAIL_HOST="z.B. smtp.telco.com"
    EMAIL_PORT="465"
    EMAIL_HOST_USER="z.B. user@host.com"
    EMAIL_HOST_PASSWORD="******"
    EMAIL_USE_SSL="True or False"
    DEFAULT_FROM_EMAIL="z.B. user@host.com"

    # open fd
    exec 3>&1

    VALUES=$(dialog --ascii-lines --no-cancel --clear \
    --title "EMail-Konfiguration" \
    --form "\nBitte geben Sie die Konfiguration zum Versenden von EMails an:" 0 0 0 \
    "HOST:" 		1 1 "$EMAIL_HOST" 		1 25 255 0 \
    "PORT:" 		2 1 "$EMAIL_PORT" 		2 25 255 0 \
    "HOST USER:" 		3 1 "$EMAIL_HOST_USER" 		3 25 255 0 \
    "HOST PASSWORD:" 	4 1 "$EMAIL_HOST_PASSWORD" 	4 25 255 0 \
    "USE SSL:" 		5 1 "$EMAIL_USE_SSL" 		5 25 10 0 \
    "FROM EMAIL:" 		6 1 "$DEFAULT_FROM_EMAIL" 	6 25 255 0 \
    2>&1 1>&3)

    # close fd
    exec 3>&-

    array=($VALUES)

    echo "# Setting for E-Mail service" >> "$DST_FILE"
    echo "EMAIL_BACKEND = '$EMAIL_BACKEND'" >> "$DST_FILE"
    echo "EMAIL_HOST = \""${array[0]}"\"" >> "$DST_FILE"
    echo "EMAIL_PORT = "${array[1]}""  >> "$DST_FILE"
    echo "EMAIL_HOST_USER = \""${array[2]}"\""  >> "$DST_FILE"
    echo "EMAIL_HOST_PASSWORD = \""${array[3]}"\""  >> "$DST_FILE"
    echo "EMAIL_USE_SSL = "${array[4]}""  >> "$DST_FILE"
    echo "DEFAULT_FROM_EMAIL = \""${array[5]}"\""  >> "$DST_FILE"

    chmod +x $DST_FILE
    clear
	echo "##############################################"
	echo "# prepare database "
	echo "##############################################"
	mkdir -p PraktomatSupport
	./Praktomat/src/manage-local.py collectstatic --noinput --link
	./Praktomat/src/manage-local.py migrate --noinput
    sudo chown -R praktomat:praktomat Praktomat/static
	sleep 2
	clear
	echo "##############################################"
	echo "# create superuser for Praktomat "
	echo "##############################################"
	./Praktomat/src/manage-local.py createsuperuser
	deactivate
	sleep 2
	clear
}

#***********************************************************************************
# CONFIGURE APACHE SERVER
#***********************************************************************************

function config_apache()
{
	echo "##############################################"
	echo "# configure apache server "
	echo "##############################################"
    sudo a2enmod macro
    sudo a2enmod ssl
    sudo mkdir /etc/apache2/ssl
    sudo cp /srv/praktomat/mailsign/signer_key.pem /etc/apache2/ssl/apache.key
    sudo cp /srv/praktomat/mailsign/signer.pem /etc/apache2/ssl/apache.pem
    echo "copied ssl key and certificate"
	sleep 2
	clear
	sudo mv /srv/praktomat/"$name"/Praktomat/documentation/mpm_event.conf /etc/apache2/sites-available/mpm_event.conf
    sudo mv /srv/praktomat/"$name"/Praktomat/documentation/000-default.conf /etc/apache2/sites-available/000-default.conf

	ipaddr=`dialog --ascii-lines --no-cancel --clear --inputbox "Geben Sie die URL des Praktomaten ein!\n\
	\n\
	\n Die IP-Adresse ueber die die Seite erreichbar sein soll:" \
	0 0 "10.18.2.59" 3>&1 1>&2 2>&3`
	sudo sed -i "s|ServerName .*|ServerName \'${ipaddr}\'|" /etc/apache2/sites-available/000-default.conf

	sudo sed -i "s|Use Praktomat  .*|Use Praktomat  \'${name}\'    /srv/praktomat/${name}    80|" /etc/apache2/sites-available/000-default.conf
	sleep 2
	clear
	echo "restarting apache server"
	sudo service apache2 restart
	sleep 2
	clear
}

#***********************************************************************************
# EDIT LANDING PAGE
#***********************************************************************************

function edit_indexhtml()
{
	echo "##############################################"
	echo "# edit index.html "
	echo "##############################################"
	sleep 2
    sudo mv /srv/praktomat/"$name"/Praktomat/static-index/* /srv/praktomat

    output=$(dialog --ascii-lines --clear --title "Edit index.html" --no-cancel \
    --editbox "/srv/praktomat/index.html" 0 0 3>&1- 1>&2- 2>&3-)
    sudo echo "$output" > index.html

    clear
}

#***********************************************************************************
#	INSTALL DOCKER
#***********************************************************************************

function install_docker()
{
	echo "#############################################################################"
	echo " INSTALL DOCKER "
	echo "#############################################################################"
	sudo apt-get -y install libipc-run-perl libdata-guid-perl libterm-readline-gnu-perl
    sudo apt-get -y install apt-transport-https curl gnupg-agent software-properties-common
    sleep 2
	clear
    echo "-----------------------------"
    echo "Add Docker’s official GPG key"
    echo "-----------------------------"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
	sleep 2
	clear
    echo "-----------------------------"
    echo "Add Docker repository"
    echo "-----------------------------"
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sleep 2
	clear
    echo "-----------------------------"
    echo "Install Docker Engine"
    echo "-----------------------------"
    sudo apt-get -y update
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io
	sleep 2
	clear
}

#***********************************************************************************
#	CREATE DOCKER IMAGE
#***********************************************************************************

function create_docker_image()
{
	echo "#############################################################################"
	echo " CREATE DOCKER IMAGE "
	echo "#############################################################################"
    sudo mv /srv/praktomat/"$name"/Praktomat/safe-docker/safe-docker /usr/local/bin
    sudo chmod +x /usr/local/bin/safe-docker
    cd /srv/praktomat/"$name"/Praktomat
    sudo docker build -t safe-docker docker-image
    echo "-----------------------------"
    echo "Show Docker Images"
    echo "-----------------------------"
    sudo docker image ls
    sleep 5
    cd /srv
    sudo chown -R praktomat:praktomat praktomat/
    clear
}

#***********************************************************************************
# Main PROGRAM
#***********************************************************************************

echo "changing to directory /srv/praktomat"
cd /srv/praktomat/

name=`dialog --ascii-lines --no-cancel --clear --inputbox "Wie soll der Praktomat heissen?\n\
\n Sommersemester (SS); Wintersemester (WS)\
\n\
Jahr_Semester            --> Programmieren Semester Jahr\n\
OOP_Jahr_Semester        --> OOP Java Informatik Semester Jahr\n\
SW_Projekt_Jahr_Semester --> Softwareprojekt Semester Jahr\n\
oder\n\
Individuell" 0 0 "20XX_WS" 3>&1 1>&2 2>&3`

clear
echo "creating directory $name"
mkdir -p "$name"

echo "##############################################"
echo "#  Add mailsign key "
echo "##############################################"
mkdir -p /srv/praktomat/mailsign
echo "##############################################"
echo "#  OPENSSL Self-Signed Certificate creation "
echo "##############################################"
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout signer_key.pem -out signer.pem
mv signer_key.pem /srv/praktomat/mailsign/signer_key.pem
mv signer.pem /srv/praktomat/mailsign/signer.pem

echo "changing to directory /srv/praktomat/$name"
cd "$name"
clear
sleep 2

get_repository
create_praktomat
config_apache
edit_indexhtml

install_docker
create_docker_image
