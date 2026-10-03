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

    if [[ $DASH2PANEL_INSTALLED ]]; then
        
        #wait for dash-to-panel to be active
        until (gnome-extensions list --active | grep dash-to-panel); do
            /usr/bin/logger "Gnome Extension dash-to panel not yet active" -t 'Customizing Debian';
            sleep 1;
        done

        if [ $GNOME_INTELLIHIDE == "Yes" ]; then
            gsettings set org.gnome.shell.extensions.dash-to-panel intellihide true
        fi
        
        #Disable overview at startup
        if [ $GNOME_HIDE_OVERVIEW == "Yes" ]; then
            gsettings set org.gnome.shell.extensions.dash-to-panel hide-overview-on-startup true
            /usr/bin/logger "GNOME Overview on startup disabled" -t 'Customizing Debian';
        fi
        
        #Set length of panel to be dynamic
        if [ $GNOME_PANEL_LENGTH_DYNAMIC == "Yes" ]; then
            #change -1 to 100 below for a full width panel
            gsettings set org.gnome.shell.extensions.dash-to-panel panel-lengths '{"RHT-0x00000000":-1}'
            /usr/bin/logger "Dynamic length for $DASH2PANEL_INSTALLED configured" -t 'Customizing Debian';
        fi
    fi

# GNOME Favorite apps
if [[ $PRESET_SELECTED ]]; then
    /usr/bin/logger "Configuring Favorite Applications for $PRESET_SELECTED" -t 'Customizing Debian';
    if [[ $PRESET_SELECTED == "Reverse Engineering" ]]; then
        # Favorites for Reverse Engineering Preset
        gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Terminal.desktop', 'jupyter-lab.desktop', 'com.vscodium.codium.desktop', 'org.ghidra_sre.Ghidra.desktop', 'com.github.afrantzis.Bless.desktop', 'org.gnome.Software.desktop']";
    elif [[ $PRESET_SELECTED == "Hacking" ]]; then
        # Favorites for Hacking Preset
        gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.ghidra_sre.Ghidra.desktop', 'org.sigrok.PulseView.desktop', 'com.vscodium.codium.desktop', 'org.wireshark.Wireshark.desktop', 'org.gnome.Software.desktop']";
    elif  [[ $PRESET_SELECTED == "Networking" ]]; then
        # Favorites for Networking Preset
        gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.gnome.Nautilus.desktop', 'flent.desktop', 'org.wireshark.Wireshark.desktop', 'org.gnome.Terminal.desktop', 'org.ghidra_sre.Ghidra.desktop', 'com.github.afrantzis.Bless.desktop', 'org.gnome.Software.desktop']";
    elif [[ $PRESET_SELECTED == "Productivity" ]]; then
        # Favorites for Productivity Preset
        gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.gnome.Nautilus.desktop', 'libreoffice-calc.desktop', 'libreoffice-draw.desktop', 'libreoffice-impress.desktop', 'libreoffice-writer.desktop', 'jupyter-lab.desktop', 'org.gnome.Evolution.desktop', 'org.gnome.Software.desktop']";
    elif [[ $PRESET_SELECTED == "All" ]]; then
        # Favorites for All Preset 
        gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.ghidra_sre.Ghidra.desktop', 'org.sigrok.PulseView.desktop', 'com.vscodium.codium.desktop', 'jupyter-lab.desktop', 'org.wireshark.Wireshark.desktop', 'org.gnome.Software.desktop']";
    elif [[ $PRESET_SELECTED == "All" ]]; then
        # Favorites for Custom configuration
        /usr/bin/logger "No changes to Favorite Applications for $PRESET_SELECTED" -t 'Customizing Debian';    
    fi
    /usr/bin/logger "Favorite Applications for $PRESET_SELECTED configured" -t 'Customizing Debian';
fi

# Remove autostart so it does not run at every logon for this user
/usr/bin/logger "Removing autostart entry so it does not run at every logon for user: $USER" -t 'Customizing Debian';
rm -rf ~/.config/autostart/gnome-extensions.desktop

/usr/bin/logger "Enabling Gnome Extensions finished" -t 'Customizing Debian';
