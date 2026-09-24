#!/bin/bash

# get Directory of script
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Configure environment from .env file
set -a; source $SCRIPT_DIR/.env;

#echo -e "\e[36m .... Gnome Extensions\e[0m"
/usr/bin/logger "Gnome Extensions to enable:$(gnome-extensions list)" -t 'Customizing Debian';
gnome-extensions list | xargs -n1 gnome-extensions enable;
sync;
sleep 2;
# Configure dynamic length of Dash-to-panel extension
DASH2PANEL_INSTALLED=$(gnome-extensions list | grep -i dash-to-panel) > /dev/null 2>&1;
    if [ "$DASH2PANEL_INSTALLED" ]; then
        if [ $GNOME_INTELLIHIDE == "Yes" ]; then
            gsettings set org.gnome.shell.extensions.dash-to-panel intellihide true
            #change -1 to 100 below for a full width panel
        fi
        sleep 2;
        #Set length of panel to be dynamic
        if [ $GNOME_PANEL_LENGTH_DYNAMIC == "Yes" ]; then
            gsettings set org.gnome.shell.extensions.dash-to-panel panel-lengths '{"RHT-0x00000000":-1}'
            /usr/bin/logger "Dynamic length for $DASH2PANEL_INSTALLED configured" -t 'Customizing Debian';
        fi
        #Disable overview at startup
        if [ $GNOME_HIDE_OVERVIEW == "Yes" ]; then
            gsettings set org.gnome.shell.extensions.dash-to-panel hide-overview-on-startup true
            /usr/bin/logger "GNOME Overview on startup disabled" -t 'Customizing Debian';
        fi
    fi

# Remove autostart so it does not run at every logon for this user
/usr/bin/logger "Removing autostart entry so it does not run at every logon for user: - $USER -" -t 'Customizing Debian';

rm -rf ~/.config/autostart/gnome-extensions.desktop

#echo -e "\e[36m .... Gnome Extensions finished\e[0m"
/usr/bin/logger "Enabling Gnome Extensions finished" -t 'Customizing Debian';
