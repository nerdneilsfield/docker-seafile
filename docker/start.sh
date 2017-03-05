#!/bin/bash

OPT_DIR=/pan
VAR_DIR=$OPT_DIR/var
STATE_DIR=$VAR_DIR/state
SEAFILE_DIR=$OPT_DIR/seafile
SEAFILE_DATA_DIR=$SEAFILE_DIR/burkionline
SEAFILE_INSTALLED_DIR=$SEAFILE_DATA_DIR/installed


function setup {

    echo "Setting up seafile"
    
    # Setup directories
    if [ ! -d $OPT_DIR ]; then
        echo "Creating directory $OPT_DIR"
        mkdir -p $OPT_DIR
    fi
    
    if [ ! -d $VAR_DIR ]; then
        echo "Creating directory $VAR_DIR"
        mkdir -p $VAR_DIR
    fi
    
    if [ ! -d $STATE_DIR ]; then
        echo "Creating directory $STATE_DIR"
        mkdir -p $STATE_DIR
    fi
    
    if [ ! -d $SEAFILE_DIR ]; then
        echo "Creating directory $SEAFILE_DIR"
        mkdir -p $SEAFILE_DIR
    fi
    
    if [ ! -d $SEAFILE_DATA_DIR ]; then
        echo "Creating directory $SEAFILE_DATE_DIR"
        mkdir -p $SEAFILE_DATA_DIR
    fi
    
    if [ ! -d $SEAFILE_INSTALLED_DIR ]; then
        echo "Creating directory $SEAFILE_INSTSALLED_DIR"
        mkdir -p $SEAFILE_INSTALLED_DIR
    fi

    # Check if seafile is installed. Install it if necessary.
    if [ ! -f $SEAFILE_DATA_DIR/conf/seafile.conf ]; then
        echo "Installing seafile"
        curl -L https://download.seafile.de/server/community/linux/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz -o $SEAFILE_INSTALLED_DIR/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz
        tar zxvf $SEAFILE_INSTALLED_DIR/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz -C $SEAFILE_DATA_DIR
    fi

    SEAFILE_INSTALL_DIR=$SEAFILE_DATA_DIR/seafile-server-${SEAFILE_VERSION}
    $SEAFILE_INSTALL_DIR/setup-seafile.sh

    echo "max_upload_size=250" >> $SEAFILE_DATA_DIR/conf/seafile.conf
    echo "max_download_dir_size=500" >> $SEAFILE_DATA_DIR/conf/seafile.conf

    echo "LOGO_PATH = 'img/burkionline-cloud-logo.png'" >> $SEAFILE_DATA_DIR/conf/seahub_settings.py
    echo "LOGO_URL = 'http://cloud.burkionline.net:8000'" >> $SEAFILE_DATA_DIR/conf/seahub_settings.py

    mkdir $OPT_DIR/media
    mv /tmp/burkionline-cloud-logo.png $OPT_DIR/media/burkionline-cloud-logo.png
    cp $OPT_DIR/media/burkionline-cloud-logo.png $SEAFILE_INSTALL_DIR/seahub/media/img/burkionline-cloud-logo.png
    
    $SEAFILE_INSTALL_DIR/seafile.sh start
    $SEAFILE_INSTALL_DIR/seahub.sh start

    $SEAFILE_INSTALL_DIR/seahub.sh stop
    $SEAFILE_INSTALL_DIR/seafile.sh stop
}


function minor_upgrade {

    echo "Upgrading seafile"

    curl -L https://download.seafile.de/server/community/linux/seafile-server_${SEAFILE_NEW_VERSION}_x86-64.tar.gz -o $SEAFILE_INSTALLED_DIR/seafile-server_${SEAFILE_NEW_VERSION}_x86-64.tar.gz
    tar zxvf $SEAFILE_INSTALLED_DIR/seafile-server_${SEAFILE_NEW_VERSION}_x86-64.tar.gz -C $SEAFILE_DATA_DIR

    SEAFILE_INSTALL_DIR=$SEAFILE_DATA_DIR/seafile-server-${SEAFILE_NEW_VERSION}
    $SEAFILE_INSTALL_DIR/upgrade/minor-upgrade.sh
    cp $OPT_DIR/media/burkionline-cloud-logo.png $SEAFILE_INSTALL_DIR/seahub/media/img/burkionline-cloud-logo.png
}


function major_upgrade {

    echo "Upgrading seafile"

    curl -L https://download.seafile.de/server/community/linux/seafile-server_${SEAFILE_NEW_VERSION}_x86-64.tar.gz -o $SEAFILE_INSTALLED_DIR/seafile-server_${SEAFILE_NEW_VERSION}_x86-64.tar.gz
    tar zxvf $SEAFILE_INSTALLED_DIR/seafile-server_${SEAFILE_NEW_VERSION}_x86-64.tar.gz -C $SEAFILE_DATA_DIR

    OLD_MAJOR_VERSION=`echo ${SEAFILE_OLD_VERSION} | cut -d. -f1,2`
    NEW_MAJOR_VERSION=`echo ${SEAFILE_NEW_VERSION} | cut -d. -f1,2`
    
    SEAFILE_INSTALL_DIR=$SEAFILE_DATA_DIR/seafile-server-${SEAFILE_NEW_VERSION}
    $SEAFILE_INSTALL_DIR/upgrade/upgrade_${OLD_MAJOR_VERSION}_${NEW_MAJOR_VERSION}.sh
    cp $OPT_DIR/media/burkionline-cloud-logo.png $SEAFILE_INSTALL_DIR/seahub/media/img/burkionline-cloud-logo.png
}


function start {

    echo "Starting seafile"
    ulimit -n 30000
    exec /usr/local/bin/supervisord -c /etc/supervisord.conf -n
    exit 0
}


if [ -n "$1"  -a "$1" == "setup" ]; then

    setup

elif [ -n "$1"  -a "$1" == "minor_upgrade" ]; then

    minor_upgrade

elif [ -n "$1"  -a "$1" == "major_upgrade" ]; then

    major_upgrade

else

    start

fi

exit 0
