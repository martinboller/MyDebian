#!/bin/bash

# get Directory of script
#echo -e "\e[36m .... Gnome Extensions\e[0m"
/usr/bin/logger "Gnome Extensions" -t 'Customizing Debian';

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" 
/usr/bin/logger "Gnome Extensions to install:$(gnome-extensions list)" -t 'Customizing Debian';
#echo -e "\e[36m .... Gnome Extensions to enable:\r\n$(gnome-extensions list))"

gnome-extensions list | xargs -n1 gnome-extensions enable 
rm -rf ~/.config/autostart/gnome-extensions.desktop

#echo -e "\e[36m .... Gnome Extensions finished\e[0m"
/usr/bin/logger "Gnome Extensions finished" -t 'Customizing Debian';
