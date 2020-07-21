#!/bin/bash

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}

# global variables
name="JAVA_20XX_WS"
MYDIR="`cd $0; pwd`"

# text settings
b="\Zb"             # bold
r="\Zb\Z1"          # red color
n="\Zn"             # reset

red="\033[31m"      # red color
white="\033[0m"     # white color
cyan="\033[96m"      # cyan color
green="\033[32m"
blink="\033[5m"       # blink

create_praktomat() {
    clear
    cd /srv/praktomat/$name
    echo "##############################################"
    echo "# $blink $green create virtualenv $name $white"
    echo "##############################################"
    virtualenv -p python3 --system-site-packages env/
    sleep 3
    clear
    echo "##############################################"
    echo "#$blink $green switching to virtualenv in $name $white"
    echo "##############################################"
    . env/bin/activate
    pip install -r Praktomat/requirements.txt
    sleep 3
    clear
    echo "##############################################"
    echo "# $blink $green create new database for $name $white"
    echo "##############################################"
    sudo -u postgres createdb -O praktomat $name
    sleep 3
    clear
    echo "##############################################"
    echo "#       prepare database                     #"
    echo "##############################################"
    ./Praktomat/src/manage-local.py collectstatic --noinput --link
    ./Praktomat/src/manage-local.py migrate --noinput
    sleep 3
    clear
    echo "##############################################"
    echo "#       create superuser for praktomat       #"
    echo "##############################################"
    ./Praktomat/src/manage-local.py createsuperuser
    cd $MYDIR
    exit 1
}

get_repository() {
    if [ -d /srv/praktomat/$name ]
    then
        dialog --colors  --msgbox "Der Praktomat mit dem Namen $b$r"$name"$n existiert bereits!" 0 0
        exit 1
    fi
    dialog --prgbox 'git clone --branch FRA-UAS git://github.com/schlom/Praktomat-1.git /srv/praktomat/"'$name'"/Praktomat --progress' 80 80
    create_praktomat
}

check_course() {
    if [ -z "$name" ]; then
        dialog --msgbox "Es muss ein Name eingegeben werden!" 0 0
        exit 1
    fi
}

input_new() {
    name=`dialog --inputbox "Wie soll der Praktomat heißen?" 0 0 "JAVA_20XX_WS" 3>&1 1>&2 2>&3`
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
    dialog --msgbox "Vielen Dank!" 0 0
    clear
    exit 1
}

start() {
    dialog --yesno "Wollen Sie einen neuen Praktomaten anlegen?" 0 0
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
   dialog --msgbox "The Script is not allowed to run as root!!!" 0 0
   clear
   exit 1
fi

while true; do
  start
done