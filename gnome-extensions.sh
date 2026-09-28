#!/bin/bash

# get Directory of script
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Configure environment from .env file
set -a; source $SCRIPT_DIR/.env;
/usr/bin/logger "GNOME Extensions to enable:$(gnome-extensions list)" -t 'Customizing Debian';
#Enabling installed GNOME Extensions
gnome-extensions list | xargs -n1 gnome-extensions enable;

# Configure Dash-to-panel extension
DASH2PANEL_INSTALLED=$(gnome-extensions list | grep -i dash-to-panel) > /dev/null 2>&1;
    #wait for dash-to-panel to be active
    until (gnome-extensions list --active | grep dash-to-panel); do
        /usr/bin/logger "Gnome Extension dash-to panel not yet active" -t 'Customizing Debian';
        sleep 1;
    done

    if [[ $DASH2PANEL_INSTALLED ]]; then
        if [ $GNOME_INTELLIHIDE == "Yes" ]; then
            gsettings set org.gnome.shell.extensions.dash-to-panel intellihide true
            #change -1 to 100 below for a full width panel
        fi
        #Disable overview at startup
        if [ $GNOME_HIDE_OVERVIEW == "Yes" ]; then
            gsettings set org.gnome.shell.extensions.dash-to-panel hide-overview-on-startup true
            /usr/bin/logger "GNOME Overview on startup disabled" -t 'Customizing Debian';
        fi
        #Set length of panel to be dynamic
        if [ $GNOME_PANEL_LENGTH_DYNAMIC == "Yes" ]; then
            gsettings set org.gnome.shell.extensions.dash-to-panel panel-lengths '{"RHT-0x00000000":-1}'
            /usr/bin/logger "Dynamic length for $DASH2PANEL_INSTALLED configured" -t 'Customizing Debian';
        fi
    fi

# Remove autostart so it does not run at every logon for this user
/usr/bin/logger "Removing autostart entry so it does not run at every logon for user: $USER" -t 'Customizing Debian';
rm -rf ~/.config/autostart/gnome-extensions.desktop

/usr/bin/logger "Enabling Gnome Extensions finished" -t 'Customizing Debian';
