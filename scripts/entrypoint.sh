#!/bin/sh
	
	if [ $RM_INSTALL_FOLDER = 1 ]; then
        echo "\n* Removing install folder ...";
        rm -r ${GALETTE_INSTALL}/install;
    fi
    
    exec apachectl -D FOREGROUND
