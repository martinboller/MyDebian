#!/bin/bash

#####################################################################
#                                                                   #
# Author:       Martin Boller                                       #
#                                                                   #
# Email:        martin@bollers.dk                                   #
# Last Update:  2026-01-05                                          #
# Version:      2.00                                                #
#                                                                   #
# Changes:  Tested on Debian 13 (Debian)                            #
#                                                                   #
#####################################################################

do_intro() {
    /usr/bin/logger 'do_intro()' -t 'Customizing Debian';
    echo -e '\e[32m   ___          _                '  _     _
    echo -e '\e[32m / ___|   _ ___| |_ ___  _ __ ___ (_)___(_)_ __   __ _  '
    echo -e '\e[32m| |  | | | / __| __/ _ \| ´_ ` _ \| |_  / | ´_ \ / _` | '
    echo -e '\e[32m| |__| |_| \__ \ || (_) | | | | | | |/ /| | | | | (_| | '
    echo -e '\e[32m \____\__,_|___/\__\___/|_| |_| |_|_/___|_|_| |_|\__, | '
    echo -e '\e[32m|                                                |___/  '
    echo -e
    /usr/bin/logger 'do_intro() finished' -t 'Customizing Debian';
}

do_outro() {
    /usr/bin/logger 'do_outro()' -t 'Customizing Debian';
    echo -e '\e[32m  ____          _                  _          _   _              '
    echo -e '\e[32m / ___|   _ ___| |_ ___  _ __ ___ (_)______ _| |_(_) ___  _ __   '
    echo -e '\e[32m| |  | | | / __| __/ _ \| ´_ ` _ \| |_  / _` | __| |/ _ \| ´_ \  '
    echo -e '\e[32m| |__| |_| \__ \ || (_) | | | | | | |/ / (_| | |_| | (_) | | | | '
    echo -e '\e[32m \____\__,_|___/\__\___/|_|_|_| |_|_/___\__,_|\__|_|\___/|_| |_| '
    echo -e '\e[32m             |  ___(_)_ __ (_)___| |__   ___  __| |              '
    echo -e '\e[32m             | |_  | | ´_ \| / __| ´_ \ / _ \/ _` |              ' 
    echo -e '\e[32m             |  _| | | | | | \__ \ | | |  __/ (_| |              '
    echo -e '\e[32m             |_|   |_|_| |_|_|___/_| |_|\___|\__,_|              '
    echo -e
    /usr/bin/logger 'do_outro() finished' -t 'Customizing Debian';
}

configure_env() {
    echo -e "\e[32m - configure_env()\e[0m";
    /usr/bin/logger 'configure_env()' -t 'Customizing Debian';

    # Remember to change settings in the .env file.
    # Directory of script
    export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    
    # Configure environment from .env file
    set -a; source $SCRIPT_DIR/.env;
    # Get GNOME Version
    export GNOME_VERSION="$(gnome-shell --version | awk '{print $3}')"
    export GNOME_VERSION_MAJOR="$(gnome-shell --version | awk '{print $3}' | awk -F "." '{print $1}')"
    export GNOME_VERSION_MINOR="$(gnome-shell --version | awk '{print $3}' | awk -F "." '{print $2}')"
  
    echo -e "\e[1;35m-------------------------------------------------------------------\e[0m"
    echo -e "\e[1;35menv file version $ENV_VERSION\e[0m"
    echo -e
    echo -e "\e[1;35mAdding contrib and non-free repositories? $APT_CONFIGURE\e[0m"
    echo -e "\e[1;35mInstalling latest updates from Debian? $UPDATES_INSTALL\e[0m"
    echo -e "\e[1;35mConfiguration of Linux? $NIX_CONFIGURE\e[0m"
    echo -e "\e[1;35mInstall Flatpak? $FLATPAK_INSTALL\e[0m"
    echo -e "\e[1;35mInstall Flatpak Utilities $FLATPAK_UTILS\e[0m"
    echo -e "\e[1;35mInstall Debian Packages? $APT_UTILS\e[0m"
    echo -e "\e[1;35mInstall golang? $GO_INSTALL\e[0m"
    echo -e "\e[1;35mConfigure Minimize and Maximize buttons on Windows? $MM_BUTTONS_CONFIGURE\e[0m"
    echo -e "\e[1;35mConfigure access to Serial Ports for $USERNAME? $CONFIGURE_SERIAL\e[0m"
    echo -e
    echo -e "\e[1;35mGNOME version: $GNOME_VERSION\e[0m"
    #echo -e "\e[1;35mGNOME version major: $GNOME_VERSION_MAJOR\e[0m"
    #echo -e "\e[1;35mGNOME version minor: $GNOME_VERSION_MINOR\e[0m"

    # OS Version freedesktop.org and systemd
    . /etc/os-release
    export OS=$NAME
    export VER=$VERSION_ID
    export CODENAME=$VERSION_CODENAME
    echo -e "\e[1;35mOperating System: $OS Version: $VER: $CODENAME\e[0m";
    echo -e "\e[1;35m-------------------------------------------------------------------\e[0m"
    echo -e
    /usr/bin/logger "Operating System: $OS Version: $VER: $CODENAME" -t 'gce-23.1.0';

    if [ "$VER" == "$DEBIAN_SUPPORTED" ]; then
        echo -e "\e[1;36mRunning Debian $VER codename $CODENAME. All good to go\e[0m"
    else
        echo -e "\e[1;31mNOT running Debian $DEBIAN_SUPPORTED, but $OS, $VER codename $CODENAME. Script shall exit\e[0m"
        exit 1;
    fi
    echo -e "\e[36mEnvironment configured\e[0m";

    echo -e "\e[32m - configure_env() finished\e[0m";
    /usr/bin/logger 'configure_env() finished' -t 'Customizing Debian';
}

install_updates() {
    echo -e "\e[32m - install_updates()\e[0m";
    /usr/bin/logger 'install_updates()' -t 'Customizing Debian';
    
    export DEBIAN_FRONTEND=noninteractive;
    sync
    echo -e "\e[36m .... update\e[0m" && sudo apt-get -qq update > /dev/null 2>&1
    echo -e "\e[36m .... full-upgrade\e[0m" && sudo apt-get -qq -y full-upgrade > /dev/null 2>&1
    echo -e "\e[36m .... cleaning up apt\e[0m";
    echo -e "\e[36m .... autoremove\e[0m" && sudo apt-get -qq -y --purge autoremove > /dev/null 2>&1
    echo -e "\e[36m .... autoclean\e[0m" && sudo apt-get -qq autoclean > /dev/null 2>&1
    echo -e "\e[36m .... Done\e[0m" > /dev/null 2>&1
    sync;
    
    echo -e "\e[32m - install_updates() finished\e[0m";
    /usr/bin/logger 'install_updates() finished' -t 'Customizing Debian';
}

install_ntfs() {
     echo -e "\e[32m - install_ntfs()\e[0m";
    /usr/bin/logger 'install_ntfs()' -t 'Customizing Debian';
    
    export DEBIAN_FRONTEND=noninteractive;
    sudo apt -qq -y install ntfs-3g;
    sync;
    
    echo -e "\e[32m - install_ntfs() finished\e[0m";
    /usr/bin/logger 'install_ntfs() finished' -t 'Customizing Debian';
}

install_utils_apt() {
    echo -e "\e[32m - install_utils_apt()\e[0m";
    /usr/bin/logger 'install_utils_apt()' -t 'Customizing Debian';

    export DEBIAN_FRONTEND=noninteractive;
    echo -e "\e[36m .... Installing some additional tools and utilities\e[0m";

    # NETTOOLS_INSTALL
    if [ "$NETTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Network tools from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing network tools\e[0m";
        sudo apt-get -y -qq install ipcalc-ng wireshark tcpdump nmap ncat ngrep ethtool aircrack-ng whois dnsutils > /dev/null 2>&1;
    fi

    # FORTOOLS_INSTALL
    if [ "$FORTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Forensics tools from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing forensics tools\e[0m";
        sudo apt-get -y -qq install forensics-all > /dev/null 2>&1;
        sudo apt-get -y -qq install testdisk sleuthkit geoip-bin geoip-database geoipupdate binwalk > /dev/null 2>&1;
    fi

    # SYSTOOLS_INSTALL
    if [ "$SYSTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing System tools from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing system tools\e[0m";
        sudo apt-get -y -qq install gparted wget nano p7zip p7zip-full unzip dconf-editor htop > /dev/null 2>&1;
    fi

    # USERTOOLS_INSTALL
    if [ "$USERTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing User tools from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing user utils and other tools\e[0m";
        sudo apt-get -y -qq install curl transmission-gtk vlc ffmpeg libavcodec-extra default-jdk sshpass rclone rclone-browser tldr > /dev/null 2>&1;
    fi

    # DEVTOOLS_INSTALL
    if [ "$DEVTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Development tools from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing development tools\e[0m";
        sudo apt-get -y -qq install git devscripts build-essential software-properties-common gnupg2 dirmngr --install-recommends > /dev/null 2>&1;
        # Required to build Proxmark and others
        sudo apt-get -qq -y install --no-install-recommends ca-certificates pkg-config libreadline-dev gcc-arm-none-eabi libnewlib-dev qtbase5-dev libbz2-dev liblz4-dev libbluetooth-dev libssl-dev > /dev/null 2>&1;
    fi
    
    # PYTHON_INSTALL
    if [ "$PYTHON_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Python stuff from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing Python tools\e[0m";   
        sudo apt-get -y -qq install python3 python3-pip python3-setuptools python3-gnupg python3-venv libpython3-dev > /dev/null 2>&1;
    fi

    echo -e "\e[32m - install_utils_apt() finished\e[0m";
    /usr/bin/logger 'install_utils_apt() finished' -t 'Customizing Debian';
}

install_flatpak() {
    echo -e "\e[32m - install_flatpak()\e[0m";
    /usr/bin/logger 'install_flatpak()' -t 'Customizing Debian';

    echo -e "\e[36m .... Installing flatpak and gnome software plugin\e[0m";
    sudo apt-get -qq -y install flatpak gnome-software-plugin-flatpak;
    echo -e "\e[36m .... Adding flathub repository\e[0m";
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sync;
    
    echo -e "\e[32m - install_flatpak() finished\e[0m";
    /usr/bin/logger 'install_flatpak() finished' -t 'Customizing Debian';
}

install_utils_flatpak() {
    echo -e "\e[32m - install_utils_flatpak()\e[0m";
    /usr/bin/logger 'install_utils_flatpak()' -t 'Customizing Debian';

    # FP_DEVTOOLS_INSTALL
    if [ "$FP_DEVTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak Devtools' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing vs-codium\e[0m";
        flatpak --assumeyes install com.vscodium.codium > /dev/null 2>&1;
        echo -e "\e[36m .... installing ImHex Hex Editor\e[0m";
        flatpak --assumeyes install net.werwolv.ImHex > /dev/null 2>&1;
        echo -e "\e[36m .... installing Bless Hex Editor\e[0m";
        flatpak --assumeyes install com.github.afrantzis.Bless > /dev/null 2>&1;
    fi

    # FP_USERTOOLS_INSTALL
    if [ "$FP_USERTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak Usertools' -t 'Customizing Debian';
        echo -e "\e[36m .... installing BitWarden\e[0m";
        flatpak --assumeyes install com.bitwarden.desktop > /dev/null 2>&1;
        echo -e "\e[36m .... installing Calibre\e[0m";
        flatpak --assumeyes install com.calibre_ebook.calibre > /dev/null 2>&1;
        echo -e "\e[36m .... installing ungoogled Chromium\e[0m";
        flatpak --assumeyes install com.github.Eloston.UngoogledChromium > /dev/null 2>&1;
        echo -e "\e[36m .... installing Codecs for Chromium\e[0m";
        flatpak --assumeyes install com.github.Eloston.UngoogledChromium.Codecs > /dev/null 2>&1;
        echo -e "\e[36m .... installing Mattermost\e[0m";
        flatpak --assumeyes install com.mattermost.Desktop > /dev/null 2>&1;
        echo -e "\e[36m .... installing Discord\e[0m";
        flatpak --assumeyes install com.discordapp.Discord > /dev/null 2>&1;
        echo -e "\e[36m .... installing RSS Reader NewsFlash\e[0m";
        flatpak --assumeyes install io.gitlab.news_flash.NewsFlash > /dev/null 2>&1;
        echo -e "\e[36m .... installing Signal Desktop\e[0m";
        flatpak --assumeyes install org.signal.Signal > /dev/null 2>&1;
        echo -e "\e[36m .... installing Authenticator App\e[0m";
        flatpak --assumeyes install com.belmoussaoui.Authenticator > /dev/null 2>&1;
        echo -e "\e[36m .... installing Zoom\e[0m";
        flatpak --assumeyes install us.zoom.Zoom > /dev/null 2>&1;
    fi
    
    echo -e "\e[32m - install_utils_flatpak() finished\e[0m";
    /usr/bin/logger 'install_utils_flatpak() finished' -t 'Customizing Debian';
}

install_gnome_dash_to_panel() {
    echo -e "\e[32m - install_gnome_dash_to_panel()\e[0m";
    /usr/bin/logger 'install_gnome_dash_to_panel()' -t 'Customizing Debian';

    echo -e "\e[36m .... installing the Dash-to-Panel Gnome Extension\e[0m";
    # Requires log out then logon
    sudo apt-get -y -qq install gnome-shell-extension-dash-to-panel;
    DASH_UUID="$(gnome-extensions list | grep dash)"
    gnome-extensions enable $DASH_UUID
     
    echo -e "\e[32m - install_gnome_dash_to_panel() finished\e[0m";
    /usr/bin/logger 'install_gnome_dash_to_panel() finished' -t 'Customizing Debian';
}

configure_nix() {
    echo -e "\e[32m - configure_nix()\e[0m";
    /usr/bin/logger 'configure_nix()' -t 'Customizing Debian';

    echo -e "\e[36m .... Configuring Linux changes\e[0m";
    # Currently nothing to do

    echo -e "\e[32m - configure_nix() finished\e[0m";
    /usr/bin/logger 'configure_nix() finished' -t 'Customizing Debian';
}

configure_sudo() {
    echo -e "\e[32m - configure_sudo()\e[0m";
    /usr/bin/logger 'configure_sudo()' -t 'Customizing Debian';
    
    echo -e "\e[36m .... Adding user: $USERNAME to group $SUDOGROUP\e[0m";
    echo -e "\e[35m .... You must provide the root password, then logout and rerun script";
    echo -e "\e[35m$(su - root -c "/sbin/adduser $USERNAME $SUDOGROUP")\e[0m"
    echo -e "\e[35m$("/usr/bin/newgrp $SUDOGROUP")\e[0m"
        
    echo -e "\e[32m - configure_sudo() finished\e[0m";
    /usr/bin/logger 'configure_sudo() finished' -t 'Customizing Debian';
}

configure_apt_repositories() {
    echo -e "\e[32m - configure_apt_repositories()\e[0m";
    /usr/bin/logger 'configure_apt_respositories()' -t 'Customizing Debian';

    echo -e "\e[36m .... adding contrib, non-free, and non-free-firmware repositories to sources.list\e[0m";
    sudo sed -ie "s/main/main contrib non-free non-free-firmware/" /etc/apt/sources.list
    sudo apt-get -qq update;
    
    echo -e "\e[32m - configure_apt_repositories() finished\e[0m";
    /usr/bin/logger 'configure_apt_respositories() finished' -t 'Customizing Debian';
}

configure_microsoft_apt_repository() {
    echo -e "\e[32m - configure_microsoft_apt_repository()\e[0m";
    /usr/bin/logger 'configure_microsoft_apt_respository()' -t 'Customizing Debian';

    echo -e "\e[36m .... adding packages-microsoft-prod.deb to sources.list\e[0m";
    # Download the Microsoft repository GPG keys
    echo -e "\e[36m .... Download the Microsoft repository GPG keys\e[0m";
    wget -q https://packages.microsoft.com/config/debian/$VER/packages-microsoft-prod.deb
    # Register the Microsoft repository GPG keys
    echo -e "\e[36m .... Register the Microsoft repository GPG keys\e[0m";
    sudo dpkg -i packages-microsoft-prod.deb  > /dev/null 2>&1;
    # Delete the Microsoft repository GPG keys file
    echo -e "\e[36m .... Delete the Microsoft repository GPG keys file\e[0m";
    rm packages-microsoft-prod.deb > /dev/null 2>&1;

    if [ "$MICROSOFT_APT_WORKAROUND" == "Yes" ]; then
        # Correct the repo to 11/Bullseye as 12/Debian stuff is mostly empty because Microsoft
        echo -e "\e[31m .... Correct the repo to 11/Bullseye as 12/Debian stuff is mostly empty because Microsoft\e[0m";
        echo -e "\e[31m .... This is BAD, and can hopefully be changed soon\e[0m"
        sudo sed -i "s/$VER/11/" /etc/apt/sources.list.d/microsoft-prod.list
        sudo sed -i "s/$CODENAME/bullseye/" /etc/apt/sources.list.d/microsoft-prod.list
    fi

    # Update the list of packages after we added packages.microsoft.com
    sudo apt-get -qq update

    echo -e "\e[32m - configure_microsoft_apt_repository() finished\e[0m";
    /usr/bin/logger 'configure_microsoft_apt_respository() finished' -t 'Customizing Debian';
}

configure_serial_access() {
    echo -e "\e[32m - configure_serial_access()\e[0m";
    /usr/bin/logger 'configure_serial_access()' -t 'Customizing Debian';
   
    if id -nG "$USERNAME" | grep -qw "$SERIALGROUP"; then
        echo -e "\e[32m - $USERNAME already  belongs to group: $SERIALGROUP, nothing to do\e[0m"
    else
        echo -e "\e[36m .... Adding User: $USERNAME to group $SERIALGROUP";
        echo -e "\e[35m .... $(sudo /sbin/adduser $USERNAME $SERIALGROUP)\e[0m"
    fi
   
    echo -e "\e[32m - configure_serial_access() finished\e[0m";
    /usr/bin/logger 'configure_serial_access() finished' -t 'Customizing Debian';
}

install_pwsh() {
    echo -e "\e[32m - install_pwsh()\e[0m";
    /usr/bin/logger 'install_pwsh()' -t 'Customizing Debian';

    # Install PowerShell
    echo -e "\e[36m .... Installing Powershell\e[0m";
    sudo apt-get -qq -y install powershell

    echo -e "\e[32m - install_pwsh() finished\e[0m";
    /usr/bin/logger 'install_pwsh() finished' -t 'Customizing Debian';
}

configure_kb_shortcuts() {
    echo -e "\e[32m - configure_kb_shortcuts()\e[0m";
    /usr/bin/logger 'configure_kb_shortcuts()' -t 'Customizing Debian';

    # Create custom keybindings myTerminal and myDisks
    echo -e "\e[36m .... Create custom keybindings\e[0m";
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myTerminal/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myDisks/']"
    echo -e "\e[36m .... Provide a name for the custom key myTerminal\e[0m";
    # Provide a name for the custom key myTerminal
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myTerminal/ name 'Gnome-Term'
    echo -e "\e[36m .... set keyboard combo to <Super> + t\e[0m";
    # set keyboard combo to <Super> + t
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myTerminal/ binding '<super>t'
    echo -e "\e[36m .... set gnome-terminal as command to run\e[0m";
    # set command to run
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myTerminal/ command '/usr/bin/gnome-terminal'
    echo -e "\e[36m .... Provide a name for the custom key myDisks\e[0m";
    # Provide a name for the custom key myDisks
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myDisks/ name 'Gnome-Disks'
    echo -e "\e[36m .... set keyboard combo to <Super> + d\e[0m";
    # set keyboard combo to <Super> + d
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myDisks/ binding '<super>d'
    echo -e "\e[36m .... set gnome-disks as command to run\e[0m";
    # set command to run
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myDisks/ command '/usr/bin/gnome-disks'

    if [ "$MENU_IS_COMPOSE" == "Yes" ]; then
        # configure menu key as compose
        gsettings set org.gnome.desktop.input-sources xkb-options "['menu:ctrl_shift_U', 'compose:menu']"
    fi

    echo -e "\e[32m - configure_kb_shortcuts() finshed\e[0m";
    /usr/bin/logger 'configure_kb_shortcuts() finished' -t 'Customizing Debian';
}

configure_min_max_buttons() {
    echo -e "\e[32m - configure_min_max_buttons()\e[0m";
    /usr/bin/logger 'configure_min_max_buttons()' -t 'Customizing Debian';

    echo -e "\e[36m .... Configuring GNOME Windows Manager to show minimize and maximize buttons\e[0m";
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

    echo -e "\e[32m - configure_min_max_buttons() finished\e[0m";
    /usr/bin/logger 'configure_min_max_buttons() finished' -t 'Customizing Debian';
}

install_golang() {
    echo -e "\e[32m - install_golang()\e[0m";
    /usr/bin/logger 'install_golang()' -t 'Customizing Debian';

    mkdir -p /tmp/golang/;
    cd /tmp/golang/;
    echo -e "\e[1;36m .... Downloading golang $GO_URL\e[0m";
    export GO_LATEST="$(curl $GO_URL | head -n1)";
    export GO_DOWNLOAD="https://go.dev/dl/$GO_LATEST.linux-amd64.tar.gz"
    wget -q "$GO_DOWNLOAD" -O /tmp/golang/go.tar.gz;
    echo -e "\e[1;36m .... Removing previous install of golang\e[0m";
    /usr/bin/logger 'Removing previous install of golang' -t 'Customizing Debian';
    sudo rm -rf /usr/local/go;
    echo -e "\e[1;36m .... Opening and extracting golang tarball\e[0m";
    /usr/bin/logger 'Open and extract the golang tarball' -t 'Customizing Debian';
    sudo tar -C /usr/local -zxf go.tar.gz > /dev/null 2>&1;
    sync;

    if test -f "/etc/profile.d/go_lang.sh"; then
        echo -e "\e[1;36m .... golang path already configured\e[0m";        
    else
        echo -e "\e[1;36m .... Configuring golang path\e[0m";        
        echo "export PATH=$PATH:/usr/local/go/bin" | sudo tee /etc/profile.d/go_lang.sh  > /dev/null 2>&1;
        sudo chmod 644 /etc/profile.d/go_lang.sh
    fi

    echo -e
    echo -e "\e[36m .... Installed $(/usr/local/go/bin/go version)"
    /usr/bin/logger "Installed $(/usr/local/go/bin/go version)" -t 'Customizing Debian';

    echo -e "\e[32m - install_golang()\e[0m";
    /usr/bin/logger 'install_golang()' -t 'Customizing Debian';
}

#################################################################################################################
## Main Routine                                                                                                 #
#################################################################################################################
main() {
    /usr/bin/logger 'main() routine starting' -t 'Customizing Debian';

    # Show intro message
    do_intro;

    # Configure variables from .env-file
    configure_env;

    if id -nG "$USERNAME" | grep -q "$SUDOGROUP"; then
        echo -e "\e[32m - $USERNAME already  belongs to group: $SUDOGROUP, installation will continue using sudo\e[0m"
        # Ensuring that sudo group membership is active.
        /usr/bin/newgrp $SUDOGROUP;
        # Get sudo password
        echo -e "\e[35m - Sudo password needed"
        echo -e "\e[35m - $(sudo echo .)\e[0m"


        # APT Repositories
        if [ "$APT_CONFIGURE" == "Yes" ]; then
          configure_nix;  
        fi

        # APT Repositories
        if [ "$APT_CONFIGURE" == "Yes" ]; then
            configure_apt_repositories;
        fi

        # Install updates from repositories
        if [ "$UPDATES_INSTALL" == "Yes" ]; then
            install_updates;
        fi

        # Install NTFS support
        if [ "$NTFS_INSTALL" == "Yes" ]; then
            install_ntfs;
        fi


        # Flatpak
        if [ "$FLATPAK_INSTALL" == "Yes" ]; then
            install_flatpak;
            if [ "$FLATPAK_UTILS" == "Yes" ]; then
                install_utils_flatpak;
            fi
        fi

        # Debian APT packages
        if [ "$APT_UTILS" == "Yes" ]; then
            install_utils_apt;
        fi
        
        # Gnome Keyboard Shortcuts
        if [ "$KB_SHORTCUTS" == "Yes" ]; then
            configure_kb_shortcuts;
        fi

        # Gnome Dash to Panel Extension
        if [ "$DASH_TO_PANEL" == "Yes" ]; then
            install_gnome_dash_to_panel;
        fi

        # Gnome show minimize and maximize buttons
        if [ "$MM_BUTTONS_CONFIGURE" == "Yes" ]; then
            configure_min_max_buttons;
        fi

        # GOLANG
        if [ "$GO_INSTALL" == "Yes" ]; then
            install_golang;            
        fi

        # Serial ports
        if [ "$CONFIGURE_SERIAL" == "Yes" ]; then
            configure_serial_access;            
        fi

        # Microsoft Debian Packages and PowerShell
        if [ "$MICROSOFT_APT" == "Yes" ]; then
            configure_microsoft_apt_repository;

            if [ "$PWSH_INSTALL" == "Yes" ]; then
                install_pwsh;
            fi
        fi

    # Cannot sudo
    else
        echo -e "\e[1;36m$USERNAME does not belong to group $SUDOGROUP, please provide root password\e[0m"
        configure_sudo;
        echo -e "\e[1;31mNow rerun this script\e[0m"
    fi

    # Show finishing message
    do_outro;

    /usr/bin/logger 'main() finished' -t 'Customizing Debian';
}

main

exit 0
