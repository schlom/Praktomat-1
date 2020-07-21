#!/usr/bin/env bash

# styles for console
red="\033[31m"      # red color
white="\033[0m"     # white color
cyan="\033[96m"     # cyan color
green="\033[32m"    # green color
blink="\033[5m"     # blink

# global variables
name="20XX_WS"

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}

installer() {
    dialog --clear --title "$1" --prgbox ''S2'' 80 80
}

update_sources() {
    title "UPDATE SOURCES"
    apt -y update
    clear
    title "UPGRADE PACKAGES"
    apt -y upgrade
    clear
}

install_dialog(){
    echo "##############################################"
    echo "# $cyan update sources $white"
    echo "##############################################"
    apt -y update
    clear
    apt -y upgrade
    clear
    echo "##############################################"
    echo "# $cyan INSTALL dialog $white"
    echo "##############################################"
    apt -y install dialog
    clear
}

install_software() {
    title "INSTALL SOFTWARE"
    apt -y install postgresql apache2 libpq-dev zlib1g-dev libmysqlclient-dev libsasl2-dev libssl-dev swig \
    libapache2-mod-xsendfile libapache2-mod-wsgi-py3 openjdk-11-jdk junit junit4 dejagnu r-base git-core
    clear
}

install_python() {
    title "INSTALL PYTHON3"
    apt -y install python3-pip
    pip3 install -U pip virtualenv setuptools wheel urllib3[secure]
    apt -y install python3-setuptools python3-psycopg2 python3-virtualenv
    clear
}

clean_and_autoremove() {
    title "CLEAN"
    apt clean
    clear
    title "AUTOREMOVE"
    apt autoremove
    clear
}

add_user() {
    title "ADD USER PRAKTOMAT"
    adduser --disabled-password --gecos "" praktomat
    clear

    dialog --title "Passwort" \
--clear \
--insecure \
--passwordbox "Bitte das Passwort für den Nutzer Praktomat eingeben:" 10 30 2> $data

    praktomat:$data | chpasswd

    title "ADD USER TO sudo GROUP"
    usermod -aG sudo praktomat
    clear
}

install_process() {
    title "INSTALLATION PROCESS"
    echo "change to directory /srv"
    cd /srv
    echo "create directories"
    mkdir praktomat
    mkdir praktomat/contrib
    echo "change owner to praktomat"
    chown -R praktomat:praktomat praktomat/
    echo "switching to user praktomat"
    su praktomat
    echo "change to directory /srv/praktomat"
    cd /srv/praktomat/

    name=`dialog --inputbox "Wie soll der Praktomat heißen?\n\
\n\
Jahr_Semester            --> Programmieren Semester Jahr\n\
OOP_Jahr_Semester        --> OOP Java Informatik Semester Jahr\n\
SW_Projekt_jahr_Semester --> Softwareprojekt Semester Jahr\n\
oder\n\
Individuell" 0 0 "20XX_WS" --nocancel --clear 3>&1 1>&2 2>&3`
    echo "create directory $name"
    mkdir $name
    echo "change to directory /srv/praktomat/$name"
    cd $name
}

update_sources
install_dialog
install_software
install_python
clean_and_autoremove
add_user
install_process