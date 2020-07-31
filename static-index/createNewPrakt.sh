#!/bin/bash
#===================================================================================
# createNewPrakt.sh
# UBUNTU - SCRIPT FOR PRAKTOMAT to create new Praktomat on existing server
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

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}

# global variables
name="20XX_WS"
MYDIR="`cd $0; pwd`"

create_praktomat() {
    clear
    cd /srv/praktomat/"$name"
    echo "##############################################"
    echo "# create virtualenv $name "
    echo "##############################################"
    virtualenv -p python3 --system-site-packages env/
    sleep 3
    clear
    echo "##############################################"
    echo "# switching to virtualenv in $name "
    echo "##############################################"
    . env/bin/activate
    pip install -r Praktomat/requirements.txt
    sleep 3
    clear
    echo "##############################################"
    echo "# create new database for $name "
    echo "##############################################"
    sudo -u postgres createdb -O praktomat "$name"
    sleep 3
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

    dialog --ascii-lines --no-cancel --clear \
    --title "EMail-Konfiguration" \
    --form "\nBitte geben Sie die Konfiguration zum Versenden von EMails an:" 0 0 0 \
    "HOST:" 		1 1 "$EMAIL_HOST" 		1 25 255 0 \
    "PORT:" 		2 1 "$EMAIL_PORT" 		2 25 255 0 \
    "HOST USER:" 		3 1 "$EMAIL_HOST_USER" 		3 25 255 0 \
    "HOST PASSWORD:" 	4 1 "$EMAIL_HOST_PASSWORD" 	4 25 255 0 \
    "USE SSL:" 		5 1 "$EMAIL_USE_SSL" 		5 25 10 0 \
    "FROM EMAIL:" 		6 1 "$DEFAULT_FROM_EMAIL" 	6 25 255 0

    echo "# Setting for E-Mail service" >> "$DST_FILE"
    echo "EMAIL_BACKEND = '$EMAIL_BACKEND'" >> "$DST_FILE"
    echo "EMAIL_HOST = \"$EMAIL_HOST\"" >> "$DST_FILE"
    echo "EMAIL_PORT = $EMAIL_PORT"  >> "$DST_FILE"
    echo "EMAIL_HOST_USER = \"$EMAIL_HOST_USER\""  >> "$DST_FILE"
    echo "EMAIL_HOST_PASSWORD = \"$EMAIL_HOST_PASSWORD\""  >> "$DST_FILE"
    echo "EMAIL_USE_SSL = $EMAIL_USE_SSL"  >> "$DST_FILE"
    echo "DEFAULT_FROM_EMAIL = \"$DEFAULT_FROM_EMAIL\""  >> "$DST_FILE"

    chmod +x $DST_FILE
    clear
    echo "##############################################"
    echo "#       prepare database                     #"
    echo "##############################################"
	mkdir -p PraktomatSupport
	./Praktomat/src/manage-local.py collectstatic --noinput --link
	./Praktomat/src/manage-local.py migrate --noinput
    sudo chown -R praktomat:praktomat Praktomat/static
    sleep 3
    clear
    echo "##############################################"
    echo "#       create superuser for praktomat       #"
    echo "##############################################"
    ./Praktomat/src/manage-local.py createsuperuser
    deactivate
    cd $MYDIR
    clear

    cd /srv/praktomat
    output=$(dialog --ascii-lines --clear --title "Edit index.html\n\
    ergaenzen Sie Aehnliches am Ende der Datei:
    <div class=\"all-current\">\n\
    \t<a href=\"https://10.18.2.59/20XX_WS/\" class=\"current\">\n\
	\t<span class=\"lecture\">Softwareprojekt (JAVA)</span><br/>\n\
	\t<span class=\"year\">Wintersemester 20XX/XX</span><br/>\n\
    \t<span class=\"course\">EIT/EKT</span>\n\
	\t</a>\n\
	</div>" --no-cancel \
    --editbox "/srv/praktomat/index.html" 0 0 3>&1- 1>&2- 2>&3-)
    echo "$output" > index.html

    tmp=$(dialog --ascii-lines --clear --title "Edit 000-default.conf\n\
    ergaenzen Sie Aehnliches am Ende der Datei:
	Use Praktomat 2022_WS     /srv/praktomat/2022_WS     80" --no-cancel \
    --editbox "/etc/apache2/sites-available/000-default.conf" 0 0 3>&1- 1>&2- 2>&3-)
    sudo echo "$tmp" > /etc/apache2/sites-available/000-default.conf

    sudo service apache2 restart

    clear

    exit 1
}

get_repository() {
    if [ -d /srv/praktomat/$name ]
    then
        dialog --ascii-lines --clear --msgbox "Der Praktomat mit dem Namen "$name" existiert bereits!" 0 0
        exit 1
    fi
    dialog --clear --prgbox 'git clone --branch FRA-UAS git://github.com/schlom/Praktomat-1.git /srv/praktomat/"'$name'"/Praktomat --progress' 80 80
	sudo chmod -R 0775 Praktomat
    sudo chown -R praktomat:praktomat Praktomat
    create_praktomat
}

check_course() {
    if [ -z "$name" ]; then
        dialog --ascii-lines --clear --msgbox "Es muss ein Name eingegeben werden!" 0 0
        exit 1
    fi
}

input_new() {
    name=`dialog --ascii-lines --clear --inputbox "Wie soll der Praktomat heißen?\n\
    \n Sommersemester (SS); Wintersemester (WS)\
    \n\
    Jahr_Semester            --> Programmieren Semester Jahr\n\
    OOP_Jahr_Semester        --> OOP Java Informatik Semester Jahr\n\
    SW_Projekt_Jahr_Semester --> Softwareprojekt Semester Jahr\n\
    oder\n\
    Individuell" 0 0 "20XX_WS" 3>&1 1>&2 2>&3`
    return_value=$?
    case $return_value in
        $DIALOG_OK)
            check_course
            ;;
        $DIALOG_CANCEL)
            bye
            ;;
    esac
    get_repository
    exit 1
}

bye() {
    dialog --ascii-lines --clear --msgbox "Vielen Dank!" 0 0
    clear
    exit 1
}

start() {
    dialog --ascii-lines --clear --yesno "Wollen Sie einen neuen Praktomaten anlegen?" 0 0
    # Get the exit status
    return_value=$?
    # clear screen
    dialog --clear
    # Act on it
    case $return_value in
        $DIALOG_OK)
            input_new
            ;;
        $DIALOG_CANCEL)
            bye
            ;;
     esac
}

if [ $(id -u) = 0 ]; then
   dialog --ascii-lines --clear --msgbox "The Script is not allowed to run as root!!!\n\
   Please run as user praktomat, e.g. su praktomat -c createNewPrakt.sh" 0 0
   clear
   exit 1
fi

while true; do
  start
done