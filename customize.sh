#!/bin/bash

#####################################################################
#                                                                   #
# Author:       Martin Boller                                       #
#                                                                   #
# Email:        martin@bollers.dk                                   #
# Last Update:  2026-09-19                                          #
# Version:      3.00                                                #
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
    export PKG_COUNT=1;

    echo -e "\e[1;35m-------------------------------------------------------------------\e[0m"
    echo -e "\e[1;35menv file version $ENV_VERSION\e[0m"
    echo -e
    show_features_enabled;
    echo -e
    echo -e "\e[1;35mGNOME version: $GNOME_VERSION\e[0m"

    # OS Version freedesktop.org and systemd
    . /etc/os-release
    export OS=$NAME
    export VER=$VERSION_ID
    export CODENAME=$VERSION_CODENAME
    echo -e "\e[1;35mOperating System: $OS Version: $VER: $CODENAME\e[0m";
    echo -e "\e[1;35m-------------------------------------------------------------------\e[0m"
    echo -e
    /usr/bin/logger "Operating System: $OS Version: $VER: $CODENAME" -t 'Customizing Debian';

    if [ "$VER" == "$DEBIAN_SUPPORTED" ]; then
        echo -e "\e[1;36mRunning Debian $VER codename $CODENAME. All good to go\e[0m"
    else
        echo -e "\e[1;31mNOT running Debian $DEBIAN_SUPPORTED, but $OS, $VER codename $CODENAME. Script shall exit\e[0m"
        exit 1;
    fi

    mkdir -p $GIT_HOME;
    mkdir -p $SOURCE_DIR;
    mkdir -p $RE_DIR;

    echo -e "\e[32m - configure_env() finished\n\e[0m";
    /usr/bin/logger 'configure_env() finished' -t 'Customizing Debian';
}

config_venv() {
    echo -e "\e[32m - config_venv()\e[0m";
    /usr/bin/logger 'config_venv()' -t 'Customizing Debian';

    TOOL_INSTALL="Python VENV $VENV_NAME for $TOOL_INSTALL";
    TOOL_SOURCE="Python VENV";

    if [ -d "\$HOME/$VENV_NAME/bin" ] ; then
        echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m already installed from $TOOL_SOURCE\e[0m"   
        check_status_install;
    else
        python3 -m venv ~/$VENV_NAME #> /dev/null 2>&1;
        check_status_install;

        echo -e "\e[1;36m .... Checking VENV path\e[0m";
        export VENV_PATH=$(grep "$VENV_NAME/bin" ~/.profile)
        if [ -n "$VENV_PATH" ]; then
            echo -e "\e[1;36m .... VENV path already configured\e[0m";
        else
            echo -e "\e[1;36m .... Adding VENV path to $HOME/.profile\e[0m";
            cat << ___EOF___ >> ~/.profile

# set PATH so it includes user's private virtual environment/bin if it exists
if [ -d "\$HOME/$VENV_NAME/bin" ] ; then
    PATH="\$HOME/$VENV_NAME/bin:\$PATH"
fi
___EOF___
        fi
    fi
    
    export PATH="$HOME/$VENV_NAME/bin:$PATH"
    # activate Virtual Env
    source ~/$VENV_NAME/bin/activate


    echo -e "\e[32m - config_venv() finished\n\e[0m";
    /usr/bin/logger 'config_venv() finished' -t 'Customizing Debian';
}

configure_grub() {
    echo -e "\e[32m - configure_grub()\e[0m";
    /usr/bin/logger 'configure_grub()' -t 'Customizing Debian';

    # change grub timeout
    TOOL_SOURCE="Grand Unified Bootloader";
    
    if [ $(grep "GRUB_TIMEOUT=$GRUB_TIMEOUT" /etc/default/grub) ]; then 
        TOOL_INSTALL="GRUB Timeout already set to $GRUB_TIMEOUT. Nothing to do.";
        check_status_install;
    else
        TOOL_INSTALL="GRUB_TIMEOUT=$GRUB_TIMEOUT";
        sudo sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=$GRUB_TIMEOUT/" /etc/default/grub
        sudo update-grub > /dev/null 2>&1;
        check_status_install;
    fi

    echo -e "\e[32m - configure_grub() finished\e[0m";
    /usr/bin/logger 'configure_grub() finished' -t 'Customizing Debian';
}

check_connectivity_ping() {
    # Checking that we can reach $TEST_URL over icmp
    until ping -c 1 -W 2 $TEST_URL > /dev/null 2>&1; do
        echo -e "\e[31m --- \tWaiting for connectivity to $TEST_URL...\e[0m"
        sleep 5
    done
    echo -e "\e[36m ---\t ICMP access to $TEST_URL. Continuing installation...\e[0m";
}

check_connectivity_http() {
    # Checking that we can reach $TEST_URL over HTTP
    until curl --user-agent $USER_AGENT --silent --head --request GET https://$TEST_URL > /dev/null 2>&1; do
        echo -e "\e[31m ---\t Waiting for network access to $TEST_URL...\e[0m"
        sleep 5
    done
        echo -e "\e[36m ---\t HTTPS access to $TEST_URL\e[0m"
}

check_already_installed() {
    # check if already installed
    TOOL_FOUND=$(which $TOOL_ELF) > /dev/null 2>&1;
    if [ -n "$TOOL_FOUND" ]; then
        TOOL_INSTALLED=True;
        echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "$TOOL_ELF successfully installed" -t 'Customizing Debian';
    else
        TOOL_INSTALLED=False;
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}


check_install() {
    which $TOOL_INSTALL > /dev/null 2>&1;
    if [ "$?" == 0 ]; then
        echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "$TOOL_INSTALL successfully installed from $TOOL_SOURCE" -t 'Customizing Debian';
    else
        echo -e "\e[31m$PKG_COUNT.\tERROR: $TOOL_INSTALL not installed correctly\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "\e[31m------- ERROR: $TOOL_INSTALL not installed -------\e[0m" -t 'Customizing Debian';
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}

check_status_install() {
    if [ "$?" == 0 ]; then
        /usr/bin/logger "$TOOL_INSTALL successfully installed from $TOOL_SOURCE" -t 'Customizing Debian';
        echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
     else
        echo -e "\e[31m$PKG_COUNT.\tERROR: $TOOL_INSTALL not installed correctly\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "\e[31m------- ERROR: $TOOL_INSTALL not installed -------\e[0m" -t 'Customizing Debian';
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}

check_fp_install() {
    FP_INSTALL=$(flatpak list | grep -i $TOOL_INSTALL | awk '{print $1}');
    if [ -n "$FP_INSTALL" ]; then
        echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m successfully installed from flatpak repository\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "$TOOL_INSTALL successfully installed" -t 'Customizing Debian';
    else
        echo -e "\e[31m$PKG_COUNT.\tERROR: $TOOL_INSTALL not installed correctly\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "\e[31m------- ERROR: $TOOL_INSTALL not installed -------\e[0m" -t 'Customizing Debian';
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}

check_ldd_install() {
    # check libraries for TOOL_ELF are installed
    LDD_TOOL=$(which $TOOL_ELF | xargs ldd | grep $TOOL_INSTALL) > /dev/null 2>&1;
    if [ -n "$LDD_TOOL" ]; then
        echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "$TOOL_INSTALL successfully installed" -t 'Customizing Debian';
    else
        echo -e "\e[31m$PKG_COUNT.\tERROR: $TOOL_INSTALL not installed correctly\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "\e[31m------- ERROR: $TOOL_INSTALL not installed -------\e[0m" -t 'Customizing Debian';
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}

install_updates() {
    echo -e "\e[32m - install_updates()\e[0m";
    /usr/bin/logger 'install_updates()' -t 'Customizing Debian';
    
    TEST_URL="debian.org";
    check_connectivity_ping;

    export DEBIAN_FRONTEND=noninteractive; 
    TOOL_INSTALL="apt update";
    sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
    check_status_install;

    TOOL_INSTALL="apt full-upgrade";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade > /dev/null 2>&1
    check_status_install;

    sudo DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove > /dev/null 2>&1
    sudo DEBIAN_FRONTEND=noninteractive apt-get autoclean > /dev/null 2>&1
    sync;
    cd $SCRIPT_DIR;

    echo -e "\e[32m - install_updates() finished\n\e[0m";
    /usr/bin/logger 'install_updates() finished' -t 'Customizing Debian';
}

show_features_enabled() {
    echo -e "\e[1;35m ### Installing the following Features ###"
    while IFS='=' read -r key value; do
        # Remove leading/trailing spaces and quotes from key and value
        key=$(echo "$key" | tr -d ' ')
        value=$(echo "$value" | tr -d ' "' | cut -d'#' -f1)

            if [ "$value" = "Yes" ]; then
                echo -e "\e[36m\t ++ $key\e[0m"
            fi
    done < $SCRIPT_DIR/.env;
}

open_featureslog() {
    touch $SCRIPT_DIR/features.log;
    # Start new terminal window tailing features.log
    x-terminal-emulator -e bash -c "tail -f $SCRIPT_DIR/features.log" &
}

install_ntfs() {
     echo -e "\e[32m - install_ntfs()\e[0m";
    /usr/bin/logger 'install_ntfs()' -t 'Customizing Debian';
    
    TEST_URL="debian.org";
    check_connectivity_http;
    TOOL_SOURCE="Debian Repository";
    export DEBIAN_FRONTEND=noninteractive;
    TOOL_INSTALL="ntfs-3g";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ntfs-3g > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="exfat";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install exfat-fuse exfatprogs > /dev/null 2>&1;
    check_status_install;

    cd $SCRIPT_DIR;
    
    echo -e "\e[32m - install_ntfs() finished\n\e[0m";
    /usr/bin/logger 'install_ntfs() finished' -t 'Customizing Debian';
}

install_utils_apt() {
    echo -e "\e[32m - install_utils_apt()\e[0m";
    /usr/bin/logger 'install_utils_apt()' -t 'Customizing Debian';

    export DEBIAN_FRONTEND=noninteractive;
    echo -e "\e[36m .... Installing some additional tools and utilities\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    # NETTOOLS_INSTALL
    if [ "$NETTOOLS_INSTALL" == "Yes" ]; then
        install_networktools;
    fi

    # FORTOOLS_INSTALL
    if [ "$FORTOOLS_INSTALL" == "Yes" ]; then
        install_forensicstools;
    fi

    # SYSTOOLS_INSTALL
    if [ "$SYSTOOLS_INSTALL" == "Yes" ]; then
      install_systemtools;
    fi

    # USERTOOLS_INSTALL
    if [ "$USERTOOLS_INSTALL" == "Yes" ]; then
        install_usertools
    fi
    
    # PYTHON_INSTALL
    if [ "$PYTHON_INSTALL" == "Yes" ]; then
        install_pythontools;
        install_jupyterlab;
        if [ "$USERTOOLS_INSTALL" == "Yes" ]; then
            install_ytdlp;
        fi
    fi

    # DEVTOOLS_INSTALL
    if [ "$DEVTOOLS_INSTALL" == "Yes" ]; then
        install_devtools;
    fi

    echo -e "\e[32m - install_utils_apt() finished\n\e[0m";
    /usr/bin/logger 'install_utils_apt() finished' -t 'Customizing Debian';
    
    # Trixie backports
    if [ "$BACKPORTS_INSTALL" == "Yes" ]; then
        install_backports;
    fi
}

install_hashcat() {
    /usr/bin/logger 'installing hashcat' -t 'Customizing Debian';
    echo -e "\e[32m - install_hashcat()\e[0m";

    TOOL_ELF="hashcat";
    check_already_installed;
        
    if [ $TOOL_INSTALLED == False ]; then
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="hashcat prerequisites";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libpocl-dev libbz2-dev libssl-dev libncurses5-dev libffi-dev libreadline-dev libsqlite3-dev \
            liblzma-dev > /dev/null 2>&1;
        check_status_install;
        
        # install .pyenv for hashcat
        TOOL_INSTALL="hashcat prerequisites";
        TOOL_SOURCE="PYENV";
        curl --user-agent $USER_AGENT --silent https://pyenv.run | bash > /dev/null 2>&1;
        check_status_install;

        # Check that github is reachable
        TEST_URL="github.com";
        check_connectivity_http;

        TOOL_SOURCE="Source";
        TOOL_INSTALL="hashcat";
        cd $SOURCE_DIR;
        git clone https://github.com/hashcat/hashcat.git > /dev/null 2>&1;
        cd hashcat
        make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        sync;
        check_install;
        cd $SCRIPT_DIR;
        TOOL_INSTALL="libhashcat.so";
        TOOL_ELF="hashcat";
        check_ldd_install;
    fi

    echo -e "\e[32m - install_hashcat() finished\n\e[0m";
    /usr/bin/logger 'installing hashcat finished' -t 'Customizing Debian';
}

install_backports() {
    /usr/bin/logger 'installing Debian backports repository ' -t 'Customizing Debian';
    echo -e "\e[32m - install_backports()\e[0m";
    
    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Trixie backports";
    if [ -f /etc/apt/sources.list.d/debian-backports.sources ]; then
        echo -e "\e[32m - backports already configured\n\e[0m";
        check_status_install;
    else    
    sudo tee /etc/apt/sources.list.d/debian-backports.sources << __EOF__ /etc/apt/sources.list.d/debian-backports.sources > /dev/null
Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: trixie-backports
Components: main
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
__EOF__
    sync;
    sudo apt update > /dev/null 2>&1;
    check_status_install;
    fi

    cd $SCRIPT_DIR;

    echo -e "\e[32m - install_backports() finished\n\e[0m";
    /usr/bin/logger 'installing Debian backports repository finished' -t 'Customizing Debian';
}

install_pythontools() {
    /usr/bin/logger 'installing Python stuff from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[32m - install_pythontools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="python-dotenv";
    echo -e "\e[36m .... Installing Python tools\e[0m";   
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python3 python3-pip python3-setuptools python3-gnupg python3-venv \
        libpython3-dev > /dev/null 2>&1;
    check_status_install;
    cd $SCRIPT_DIR;

    echo -e "\e[32m - install_pythontools() finished\n\e[0m";
    /usr/bin/logger 'installing Python tools from Debian repository finished' -t 'Customizing Debian';
}

install_networktools() {
    /usr/bin/logger 'installing Network tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[32m - install_networktools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    # Set tool source and what to install
    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Wireshark";
    if [ $(which wireshark) ]; then
        echo -e "\e[36m .... Wireshark already installed\e[0m";
        check_status_install;
    else
        echo -e "\e[36m .... Installing network tools\e[0m";
        echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark > /dev/null 2>&1;
        check_status_install;
        sudo usermod -a -G wireshark $USER > /dev/null 2>&1;
    fi

    TOOL_INSTALL="Network Tools";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install iputils-arping iputils-tracepath arpwatch arpalert tcpdump nmap ncat ngrep ethtool aircrack-ng \
        whois dnsutils flent net-tools tshark termshark > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="Network Engineering Tools";
    echo 'iperf3  iperf3/start_daemon     boolean false' | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install tcpflow-nox ipcalc-ng arp-scan fping lldpd netsniff-ng iperf3 mtr-tiny socat frr python3-scapy dnsenum \
        dnsmap onesixtyone sslscan > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="Avahi (mDNS) Tools";
    # Avahi Tools to verify test avahi (avoid mdns on corp)
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install avahi-utils mdns-scan > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="AirCrack-ng Tools";
    # Aircrack Tools to test wireless
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install aircrack-ng airgraph-ng mdk4 wifite > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="Bettercap Tools";
    # bettercap Tools
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install bettercap > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="TCPFLOW No X Dependencies";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install tcpflow-nox > /dev/null 2>&1;
    check_status_install;

    cd $SCRIPT_DIR;

    echo -e "\e[32m - install_networktools() finished\n\e[0m";
    /usr/bin/logger 'installing Network tools from Debian repository finished' -t 'Customizing Debian';
}

install_forensicstools() {
    /usr/bin/logger 'installing Forensics tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[32m - install_forensicstools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Wireshark";
    if [ $(which wireshark) ]; then
        echo -e "\e[36m .... Wireshark already installed\e[0m";
        check_status_install;
    else
        echo -e "\e[36m .... Installing network tools\e[0m";
        echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark > /dev/null 2>&1;
        check_status_install;
        sudo usermod -a -G wireshark $USER > /dev/null 2>&1;
    fi

    TOOL_INSTALL="Forensics Tools"    
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install forensics-all > /dev/null 2>&1;
    check_status_install;
    TOOL_INSTALL="Additional Forensics Tools"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install testdisk sleuthkit geoip-bin geoip-database > /dev/null 2>&1;
    check_status_install;
    TOOL_INSTALL="Forensics Extra Package"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install forensics-extra > /dev/null 2>&1;
    check_status_install;
    sudo usermod -a -G wireshark $USER > /dev/null 2>&1;
    
    cd $SCRIPT_DIR;

    echo -e "\e[32m - install_forensicstools() finished\n\e[0m";
    /usr/bin/logger 'installing Forensics tools from Debian repository finished' -t 'Customizing Debian';
}

install_systemtools() {
    /usr/bin/logger 'installing System tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[32m - install_systemtools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="System Tools";
    echo -e "\e[36m .... Installing system tools\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gparted wget nano p7zip p7zip-full unzip dconf-editor htop screen > /dev/null 2>&1;
    check_status_install;
    cd $SCRIPT_DIR;

    echo -e "\e[32m - install_systemtools() finished\n\e[0m";
    /usr/bin/logger 'installing System tools from Debian repository finished' -t 'Customizing Debian';
}

install_usertools() {
    /usr/bin/logger 'installing User tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[32m - install_usertools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="User Tools";
    echo -e "\e[36m .... Installing user utils and other tools\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install curl transmission-gtk vlc ffmpeg libavcodec-extra default-jdk sshpass rclone \
        rclone-browser figlet lolcat cowsay sl cmatrix dconf-editor > /dev/null 2>&1;
    check_status_install;
    cd $SCRIPT_DIR;
    
    echo -e "\e[32m - install_usertools() finished\n\e[0m";
    /usr/bin/logger 'installing User tools from Debian repository finished' -t 'Customizing Debian';
}

install_devtools() {
    /usr/bin/logger 'installing Development tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[36m .... Installing development tools\e[0m";
    
    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Core Development Tools"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install git devscripts build-essential gnupg2 dirmngr --install-recommends > /dev/null 2>&1;
    check_status_install;

    # Some additional helpful tools
    TOOL_INSTALL="Additional Development Tools"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gawk xxd vbindiff gdb gdb-multiarch ddd binutils strace ltrace --install-recommends > /dev/null 2>&1;
    # Required to build Proxmark and others
    check_status_install;
   
    # cmake and QT development tools
    TOOL_INSTALL="cmake and QT Development Tools"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install --install-recommends ca-certificates pkg-config libreadline-dev gcc-arm-none-eabi \
        libnewlib-dev qtbase5-dev libbz2-dev liblz4-dev libbluetooth-dev libssl-dev cmake > /dev/null 2>&1;
    check_status_install;

    # Back to script directory
    cd $SCRIPT_DIR;
    
    /usr/bin/logger 'installing Development tools from Debian repository finished' -t 'Customizing Debian';
    echo -e "\e[36m .... Installing development tools finished\n\e[0m";
}

install_jupyterlab() {
    echo -e "\e[32m - install_jupyterlab()\e[0m";
    /usr/bin/logger 'install_jupyterlab()' -t 'Customizing Debian';
    
    # Check that PyPi is reachable
    TEST_URL="pypi.org";
    check_connectivity_http;

    TOOL_INSTALL="jupyter Virtual Environment";
    TOOL_SOURCE="Python VENV";
    # venv for jupyterlab
    VENV_NAME=".jupyter";
    config_venv;
    TOOL_SOURCE="PIP Repository";
    TOOL_INSTALL="jupyterlab";
    pip install jupyterlab > /dev/null 2>&1;
    check_status_install;
    
    #Adding desktop shortcut for jupyter lab
    cp $SCRIPT_DIR/files/jupyter-lab.desktop ~/.local/share/applications/;
    chmod 700 ~/.local/share/applications/jupyter-lab.desktop;
    chown $USER:$USER ~/.local/share/applications/jupyter-lab.desktop;

    echo -e "\e[32m - install_jupyterlab()\n\e[0m";
    /usr/bin/logger 'install_jupyterlab() finished' -t 'Customizing Debian';
}

install_pulseview() {
    echo -e "\e[32m - install_pulseview()\e[0m";
    /usr/bin/logger 'install_pulseview()' -t 'Customizing Debian';
    
    TOOL_ELF="pulseview";
    check_already_installed;
    if [ $TOOL_INSTALLED == False ]; then
        # Installing Debian Package
        #sudo DEBIAN_FRONTEND=noninteractive apt-get -y install pulseview > /dev/null 2>&1;
        
        # Check that debian.org is reachable
        TEST_URL="debian.org";
        check_connectivity_http;

        # Check that GitHub is reachable
        TEST_URL="github.com";
        check_connectivity_http;

        # Installing from source    
        # Installing prerequisites
        echo -e "\e[32m - installing pulseview Prerequisites\e[0m";
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="Sigrok Prerequisite Packages (i)";
        /usr/bin/logger 'installing pulseview Prerequisites' -t 'Customizing Debian';
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install autoconf autoconf-archive automake sdcc libtool libboost-all-dev asciidoctor \
            libzip-dev ruby-dev > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="Sigrok Prerequisite Packages (ii)";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install pkg-config libglib2.0-dev libglib2.0-dev libzip5 libtirpc-dev libserialport0 libvisa0 libvisa-dev \
            libusb-1.0-0 libusb-1.0-0-dev libhidapi-hidraw0 libhidapi-libusb0 libftdi1-dev python3-pyvisa-py libieee1284-3-dev \
            libgio-2.0-dev libghc-nettle-dev check doxygen graphviz swig libglibmm-2.68-dev python-setuptools-doc python-gi-dev \
            python3-numpy python3-numpy-dev python3-doxypypy ruby openjdk-25-jdk > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="Sigrok Prerequisite Packages (iii)";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools qttools5-dev-tools qttools5-dev \
            libqt5svg5-dev > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="Sigrok Prerequisite Packages (iv)";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gpib-user-tools python3-gpib libgpib0 libgpib-dev libhidapi-dev > /dev/null 2>&1;
        check_status_install;

        # These require Debian Backports
        TOOL_INSTALL="Sigrok Prerequisite Packages (v)";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install rpcbind libtirpc3 libavahi-client-dev check > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="Sigrok Python Virtual Environment";
        TOOL_SOURCE="Python VENV";
        VENV_NAME=".venv";    
        config_venv;
        # Python pip modules needed for libsigrok
        TOOL_INSTALL="Sigrok Python Prerequisites";
        TOOL_SOURCE="PIP Repository";
        pip install setuptools numpy > /dev/null 2>&1;
        check_status_install;

        TOOL_SOURCE="Source";
        mkdir -p $SOURCE_DIR/sigrok;
        cd $SOURCE_DIR/sigrok/;
        # Install libsigrokdecode from source
        # Note: Depending on trixie backports

        TOOL_INSTALL="libsigrokdecode";
        echo -e "\e[32m - installing libsigrokdecode\e[0m";
        /usr/bin/logger 'installing libsigrokdecode' -t 'Customizing Debian';
        git clone git://sigrok.org/libsigrokdecode > /dev/null 2>&1;
        cd libsigrokdecode > /dev/null 2>&1;
        ./autogen.sh > /dev/null 2>&1;
        ./configure > /dev/null 2>&1;
        make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        /usr/bin/logger "$TOOL_INSTALL successfully installed" -t 'Customizing Debian';
        sudo echo > /dev/null 2>&1;

        # Install fork of libsigrok with support for SiPEED SLogic 8 and 16
        TOOL_INSTALL="libsigrok"
        echo -e "\e[32m - installing libsigrok\e[0m";
        /usr/bin/logger 'installing libsigrok' -t 'Customizing Debian';
        cd $SOURCE_DIR/sigrok/;
        TOOL_INSTALL="libsigrok";
        git clone https://github.com/martinboller/libsigrok > /dev/null 2>&1;
        #git clone -b slogic-dev https://github.com/sipeed/libsigrok > /dev/null 2>&1;
        #git clone git://sigrok.org/libsigrok > /dev/null 2>&1;
        cd libsigrok > /dev/null 2>&1;
        ./autogen.sh > /dev/null 2>&1;
        ./configure > /dev/null 2>&1;
        make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        sudo echo > /dev/null 2>&1;

        # Install sigrok-cli from source
        echo -e "\e[32m - installing sigrok-cli\e[0m";
        /usr/bin/logger 'installing sigrok-cli' -t 'Customizing Debian';
        cd $SOURCE_DIR/sigrok/;
        TOOL_INSTALL="sigrok-cli";
        git clone git://sigrok.org/sigrok-cli > /dev/null 2>&1;
        cd sigrok-cli > /dev/null 2>&1;
        ./autogen.sh > /dev/null 2>&1;
        ./configure > /dev/null 2>&1;
        make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        check_install;

        # check libraries for sigrok are installed
        TOOL_INSTALL="libsigrok.so";
        TOOL_ELF="sigrok-cli";
        check_ldd_install;
        TOOL_INSTALL="libsigrokdecode.so"
        check_ldd_install;
        TOOL_INSTALL="libglib";
        check_ldd_install;

        # sigrok-firmware-fx2lafw
        TOOL_INSTALL="sigrok-firmware-fx2lafw";
        echo -e "\e[32m - installing sigrok-firmware-fx2lafw\e[0m";
        /usr/bin/logger 'installing sigrok-firmware-fx2lafw' -t 'Customizing Debian';
        cd $SOURCE_DIR/sigrok/;
        git clone git://sigrok.org/sigrok-firmware-fx2lafw > /dev/null 2>&1;
        cd sigrok-firmware-fx2lafw > /dev/null 2>&1;
        ./autogen.sh > /dev/null 2>&1;
        ./configure > /dev/null 2>&1;
        make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        check_status_install;

        # Install pulseview from source
        echo -e "\e[32m - installing pulseview\e[0m";
        /usr/bin/logger 'installing pulseview' -t 'Customizing Debian';
        cd $SOURCE_DIR/sigrok/;
        TOOL_INSTALL="pulseview"
        git clone git://sigrok.org/pulseview > /dev/null 2>&1;
        cd pulseview > /dev/null 2>&1;
        cmake .  > /dev/null 2>&1;
        #make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        sudo ldconfig;
        check_install;

        # Load udev rules
        TOOL_SOURCE="Load UDEV Rules";
        TOOL_SOURCE="Linux";
        sudo udevadm control --reload > /dev/null 2>&1;
    fi

    # Back home to where install script is running from
    cd $SCRIPT_DIR

    echo -e "\e[32m - install_pulseview() finished\n\e[0m";
    /usr/bin/logger 'install_pulseview() finished' -t 'Customizing Debian';
}

install_hwhacktools() {
    echo -e "\e[32m - install_hwhacktools()\e[0m";
    /usr/bin/logger 'install_hwhacktools()' -t 'Customizing Debian';

    ## Hardware Hacking Tools for Debian. Note: require development tools
    # Directory for source-code (declared in .env)
    mkdir -p $SOURCE_DIR;
    cd $SOURCE_DIR;

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    # Check that GitHub is reachable
    TEST_URL="github.com";
    check_connectivity_http;

    #ST-LINK (STM microcontrollers)
    TOOL_INSTALL="ST Link Tools";
    TOOL_SOURCE="Debian Repository";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install stlink-tools > /dev/null 2>&1;
    /usr/bin/logger 'Installed st-link-tools' -t 'Customizing Debian';
    check_status_install;

    # ESP32 tool
    TOOL_INSTALL="ESP Tool";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install esptool > /dev/null 2>&1;
    check_status_install;

    TOOL_ELF="flashrom";
    check_already_installed;
    if [ $TOOL_INSTALLED == False ]; then
        # flashrom
        TOOL_INSTALL="flashrom Prerequisites";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gcc meson ninja-build pkg-config python3-sphinx libcmocka-dev libpci-dev libusb-1.0-0-dev \
            libftdi1-dev libjaylink-dev > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="flashrom";
        TOOL_SOURCE="Source";
        cd $SOURCE_DIR;
        git clone https://github.com/whid-injector/flashrom-whidboard > /dev/null 2>&1;
        cd $SOURCE_DIR/flashrom-whidboard/ > /dev/null 2>&1;
        sudo mkdir -p /usr/local/sbin > /dev/null 2>&1;
        meson setup builddir > /dev/null 2>&1;
        meson compile -C builddir > /dev/null 2>&1;
        meson test -C builddir > /dev/null 2>&1;
        sudo meson install -C builddir > /dev/null 2>&1;
        ## Flashrom install in /usr/local/sbin which is not in PATH by default
        sudo cp $SCRIPT_DIR/files/flashrom.sh /etc/profile.d/ > /dev/null 2>&1;
        export PATH=$PATH:/usr/local/sbin;
        sync
        check_install;
        /usr/bin/logger 'Installed flashrom' -t 'Customizing Debian';
    fi

    TOOL_ELF="openocd";
    check_already_installed;
        
    if [ $TOOL_INSTALLED == False ]; then
        # openOCD
        cd $SOURCE_DIR;
        TOOL_INSTALL="openocd Prerequisites";
        TOOL_SOURCE="Debian Repository";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libtool pkg-config texinfo libusb-dev libusb-1.0-0-dev libftdi-dev autoconf automake make \
            git libftdi* libhidapi-hidraw0 > /dev/null 2>&1;
        check_status_install;
        sudo ldconfig > /dev/null 2>&1;

        TOOL_INSTALL="openocd";
        TOOL_SOURCE="Source";
        git clone --recursive https://github.com/whid-injector/openocd-linux > /dev/null 2>&1;
        cd ./openocd-linux/ > /dev/null 2>&1;
        sudo mkdir -p /usr/bin > /dev/null 2>&1;
        chmod -R 755 OpenOCD_SourceCode_CH347/ > /dev/null 2>&1;
        cd ./OpenOCD_SourceCode_CH347 > /dev/null 2>&1;
        ./bootstrap > /dev/null 2>&1;
        autoreconf --force --install > /dev/null 2>&1;
        ./configure --disable-doxygen-html --disable-doxygen-pdf --disable-gccwarnings --disable-wextra --enable-ch347 > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        mkdir ~/.openocd > /dev/null 2>&1;
        cp $SCRIPT_DIR/files/*.cfg ~/.openocd/ > /dev/null 2>&1;
        sync
        check_install;
        /usr/bin/logger 'Installed openOCD' -t 'Customizing Debian';
    fi

    TOOL_ELF="snander";
    check_already_installed;
    if [ $TOOL_INSTALLED == False ]; then
        # SNANDER
        cd $SOURCE_DIR;
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="snander Prerequisites";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install mingw-w64 gcc-mingw-w64-x86-64 libusb-1.0-0-dev > /dev/null 2>&1;
        check_status_install;
        sudo ldconfig > /dev/null 2>&1;

        TOOL_INSTALL="snander";
        TOOL_SOURCE="Source";
        sudo mkdir -p /usr/bin > /dev/null 2>&1;
        git clone https://github.com/martinboller/SNANDer > /dev/null 2>&1;
        cd SNANDer > /dev/null 2>&1;
        ./build-for-linux.sh > /dev/null 2>&1;
        sync;
        sudo cp ./build/snander /usr/bin/ > /dev/null 2>&1;
        check_install;
        /usr/bin/logger 'Installed snander' -t 'Customizing Debian';
    fi

    TOOL_ELF="ufsnorprog";
    check_already_installed;
    if [ $TOOL_INSTALLED == False ]; then
        # ufprog
        cd $SOURCE_DIR;
        TOOL_INSTALL="ufprog Prerequisites";
        TOOL_SOURCE="Debian Repository";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libjson-c-dev libhidapi-dev libusb-dev libusb-1.0-0-dev > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="ufsnorprog";
        TOOL_SOURCE="Source";
        git clone https://github.com/whid-injector/ufprog > /dev/null 2>&1;
        cd ufprog > /dev/null 2>&1;
        cmake -DCMAKE_BUILD_TYPE=None -DBUILD_PORTABLE=OFF -DCMAKE_INSTALL_PREFIX=/usr -B build > /dev/null 2>&1;
        cd build > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        sudo cp -r /usr/share/ufprog/ /usr/lib/ > /dev/null 2>&1;
        check_install;
        /usr/bin/logger 'Installed ufprog' -t 'Customizing Debian';
    fi

    # BUSSide
    TOOL_INSTALL="BUSSide"
    TOOL_SOURCE="Source";
    if [ -d $RE_DIR/$TOOL_INSTALL ]; then
        cd $SOURCE_DIR;
        check_status_install;
    else
        cd $SOURCE_DIR;
        git clone https://github.com/martinboller/BUSSide.git > /dev/null 2>&1;
        check_status_install;

        # Python stuff for BUSSide
        cd ./BUSSide/Client > /dev/null 2>&1;
        TOOL_INSTALL="BUSSide Python Virtual Environment"
        TOOL_SOURCE="Python VENV";
        VENV_NAME=".venv"
        config_venv;
        # activate Virtual Env
        TOOL_INSTALL="BUSSide PIP Requirements"
        pip install pyserial click esptool > /dev/null 2>&1;
        check_status_install;
    fi

    # Serial U-BOOT tool (Python)
    TOOL_INSTALL="sertack"
    TOOL_SOURCE="Source";
    if [ -d $RE_DIR/$TOOL_INSTALL ]; then
        cd $SOURCE_DIR;
    else
        cd $SOURCE_DIR;
        git clone https://github.com/martinboller/sertack.git > /dev/null 2>&1;
        check_status_install;
    fi

    TOOL_INSTALL="python3-serial"
    TOOL_SOURCE="Debian Repository";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python3-serial > /dev/null 2>&1;
    /usr/bin/logger 'Installed sertack' -t 'Customizing Debian';
    check_status_install;
    
    # udev stuff to make devices work
    cd ~
    sudo ldconfig;
    sudo cp $SCRIPT_DIR/files/*.rules /etc/udev/rules.d/ > /dev/null 2>&1;
    sudo udevadm control --reload > /dev/null 2>&1;
    cd $SCRIPT_DIR;

    echo -e "\e[32m - install_hwhacktools() finished\n\e[0m";
    /usr/bin/logger 'install_hwhacktools() finished' -t 'Customizing Debian';
}

install_reversetools() {
    echo -e "\e[32m - install_reversetools()\e[0m";
    /usr/bin/logger 'install_reversetools()' -t 'Customizing Debian';
    
    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    # Reverse Engineering tools
    mkdir -p $RE_DIR;
    cd $RE_DIR;

    TOOL_ELF="cargo";
    check_already_installed;
    if [ $TOOL_INSTALLED == False ]; then
        # Binwalk 3.x
        TOOL_INSTALL="cargo";
        #git clone https://github.com/ReFirmLabs/binwalk.git
        # binwalk require cargo and some other packages which may not be installed depending on config
        PATH="$HOME/.cargo/bin:$PATH";
        echo -e "\e[1;36m .... Checking cargo path\e[0m";
        export CARGO_PATH=$(grep '.cargo/bin' ~/.profile)

        if [ -n "$CARGO_PATH" ]; then
            echo -e "\e[1;36m .... Cargo path already configured\e[0m";
        else
            echo -e "\e[1;36m .... Adding cargo path to $HOME/.profile\e[0m";
            cat << ___EOF___ >> ~/.profile
# set PATH so it includes user's private .cargo/bin if it exists
if [ -d "\$HOME/.cargo/bin" ] ; then
    PATH="\$HOME/.cargo/bin:\$PATH"
fi
___EOF___
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install cargo build-essential libfontconfig1-dev liblzma-dev > /dev/null 2>&1;
        check_status_install;
        fi
    fi

    TOOL_ELF="binwalk";
    check_already_installed;
    if [ $TOOL_INSTALLED == False ]; then
        TEST_URL="crates.io"; # Cargo repository
        check_connectivity_http;
        TOOL_INSTALL="binwalk";
        TOOL_SOURCE="Cargo Repository (crates.io)";
        cargo install binwalk > /dev/null 2>&1;
        check_install;
    fi
    
    TOOL_INSTALL="firmwalker";
    TOOL_SOURCE="Source";
    # firmwalker bash script
    if [ -d $RE_DIR/binwally ]; then
        cd $RE_DIR;
        check_status_install;
    else    
        cd $RE_DIR;
        git clone https://github.com/hotelzululima/firmwalker.git > /dev/null 2>&1;
        check_status_install;
    fi

    TOOL_INSTALL="binwally";
    TOOL_SOURCE="Source"
    if [ -d $RE_DIR/binwally ]; then
        cd $RE_DIR;
        check_status_install;
    else
        # binwally for python3
        cd $RE_DIR;
        git clone https://github.com/martinboller/binwally.git > /dev/null 2>&1;
        check_status_install;

        # Python stuff for binwally
        TOOL_INSTALL="binwally Python Virtual Environment";
        TOOL_SOURCE="Python VENV";
        VENV_NAME=".venv";
        config_venv;
        
        TOOL_INSTALL="binwally PIP Requirements";
        TOOL_SOURCE="PIP Repository";
        pip install -r $RE_DIR/binwally/requirements.txt > /dev/null 2>&1;
        check_status_install;
    fi

    TOOL_INSTALL="Didier Stevens Suite";
    TOOL_SOURCE="Source"
    if [ -d $RE_DIR/DidierStevensSuite ]; then
        cd $RE_DIR;
        check_status_install;
    else
        cd $RE_DIR;
        git clone https://github.com/DidierStevens/DidierStevensSuite.git > /dev/null 2>&1;
        check_status_install;
        
        # Python stuff for DidierStevensSuite
        TOOL_INSTALL="Didier Stevens Suite";
        TOOL_SOURCE="Python VENV";
        VENV_NAME=".venv";
        config_venv;
        
        TOOL_SOURCE="PIP Repository";
        pip install -r $RE_DIR/DidierStevensSuite/requirements.txt > /dev/null 2>&1;
        check_status_install;
    fi   

    cd $SCRIPT_DIR;

    echo -e "\e[32m - install_reversetools() finished\n\e[0m";
    /usr/bin/logger 'install_reversetools() finished' -t 'Customizing Debian';
}

install_virtualization() {
    echo -e "\e[32m - install_virtualization()\e[0m";
    /usr/bin/logger 'install_virtualization()' -t 'Customizing Debian';

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;
    
    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="virsh";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-system-x86 libvirt-daemon-system libvirt-clients bridge-utils > /dev/null 2>&1;
    check_status_install;

    # Configure user rights to kvm and libvirt
    sudo usermod -aG kvm $USER > /dev/null 2>&1;
    sudo usermod -aG libvirt $USER > /dev/null 2>&1;
    # enable libvirtd
    sudo systemctl enable --now libvirtd > /dev/null 2>&1;
    
    # Install Virtual Machine Manager. Manage Virtual machines outside of virsh
    TOOL_INSTALL="Virtual Machine Manager";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install virt-manager > /dev/null 2>&1;
    check_status_install;
    
    # Lightweight and quick way to manage simple virtual machines in Gnome
    TOOL_INSTALL="gnome-boxes";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gnome-boxes > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m - install_virtualization() finished\n\e[0m";
    /usr/bin/logger 'install_virtualization() finished' -t 'Customizing Debian';
}

install_flatpak() {
    echo -e "\e[32m - install_flatpak()\e[0m";
    /usr/bin/logger 'install_flatpak()' -t 'Customizing Debian';

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_INSTALL="Flatpak Support"
    TOOL_SOURCE="Debian Repository";
    echo -e "\e[36m .... Installing flatpak and gnome software plugin\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install flatpak gnome-software-plugin-flatpak > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="flathub.org Repository";
    TOOL_SOURCE="Linux";
    echo -e "\e[36m .... Adding flathub repository\e[0m";
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m - install_flatpak() finished\n\e[0m";
    /usr/bin/logger 'install_flatpak() finished' -t 'Customizing Debian';
}

install_utils_flatpak() {
    echo -e "\e[32m - install_utils_flatpak()\e[0m";
    /usr/bin/logger 'install_utils_flatpak()' -t 'Customizing Debian';

    # Check that flathub.org is reachable
    TEST_URL="flathub.org";
    check_connectivity_http;


    # FP_DEVTOOLS_INSTALL
    if [ "$FP_DEVTOOLS_INSTALL" == "Yes" ]; then
        TOOL_INSTALL="vscodium";
        /usr/bin/logger 'installing Flatpak Devtools' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing vs-codium\e[0m";
        flatpak --assumeyes install com.vscodium.codium > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="imhex";
        echo -e "\e[36m .... installing ImHex Hex Editor\e[0m";
        flatpak --assumeyes install net.werwolv.ImHex > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="bless";
        echo -e "\e[36m .... installing Bless Hex Editor\e[0m";
        flatpak --assumeyes install com.github.afrantzis.Bless > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="ghidra";
        echo -e "\e[36m .... installing Ghidra\e[0m";
        flatpak --assumeyes install org.ghidra_sre.Ghidra > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="arduino";
        echo -e "\e[36m .... installing Arduino IDE v2\e[0m";
        flatpak --assumeyes install cc.arduino.IDE2 > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="STM32CubeMX";
        echo -e "\e[36m .... installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.st.STM32CubeMX > /dev/null 2>&1;
        check_fp_install;
    fi

    # FP_USERTOOLS_INSTALL
    if [ "$FP_USERTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak Usertools' -t 'Customizing Debian';

        TOOL_INSTALL="bitwarden";
        echo -e "\e[36m .... installing BitWarden\e[0m";
        flatpak --assumeyes install com.bitwarden.desktop > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="calibre";
        echo -e "\e[36m .... installing Calibre\e[0m";
        flatpak --assumeyes install com.calibre_ebook.calibre > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="Chromium";
        echo -e "\e[36m .... installing ungoogled Chromium\e[0m";
        flatpak --assumeyes install io.github.ungoogled_software.ungoogled_chromium > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="codecs";
        echo -e "\e[36m .... installing Codecs for Chromium\e[0m";
        flatpak --assumeyes install com.github.Eloston.UngoogledChromium.Codecs > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="mattermost";
        echo -e "\e[36m .... installing Mattermost\e[0m";
        flatpak --assumeyes install com.mattermost.Desktop > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="discord";
        echo -e "\e[36m .... installing Discord\e[0m";
        flatpak --assumeyes install com.discordapp.Discord > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="newsflash";
        echo -e "\e[36m .... installing RSS Reader NewsFlash\e[0m";
        flatpak --assumeyes install io.gitlab.news_flash.NewsFlash > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="signal";
        echo -e "\e[36m .... installing Signal Desktop\e[0m";
        flatpak --assumeyes install org.signal.Signal > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="authenticator";
        echo -e "\e[36m .... installing Authenticator App\e[0m";
        flatpak --assumeyes install com.belmoussaoui.Authenticator > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="zoom";
        echo -e "\e[36m .... installing Zoom\e[0m";
        flatpak --assumeyes install us.zoom.Zoom > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="remmina";
        echo -e "\e[36m .... installing Remmina\e[0m";
        flatpak --assumeyes install org.remmina.Remmina > /dev/null 2>&1;
        check_fp_install;
        
        TOOL_INSTALL="anki";
        echo -e "\e[36m .... installing Anki\e[0m";
        flatpak --assumeyes install net.ankiweb.Anki > /dev/null 2>&1;
        check_fp_install;
        
        TOOL_INSTALL="draw.io";
        echo -e "\e[36m .... installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.jgraph.drawio.desktop > /dev/null 2>&1;
        check_fp_install;
    fi
    
    # FP_ELECTRONICSTOOLS_INSTALL
    if [ "$FP_ELECTRONICSTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak Electronics Tools' -t 'Customizing Debian';

        TOOL_INSTALL="simulide";
        echo -e "\e[36m .... installing Electronic Circuit Simulator\e[0m";
        flatpak --assumeyes install com.simulide.simulide > /dev/null 2>&1;
        check_fp_install;
    fi

    # FP_3DTOOLS_INSTALL
    if [ "$FP_3DTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak 3D Tools' -t 'Customizing Debian';
        
        TOOL_INSTALL="openscad";
        echo -e "\e[36m .... installing openSCAD\e[0m";
        flatpak --assumeyes install org.openscad.OpenSCAD > /dev/null 2>&1;
        echo -e "\e[36m .... installing Fast STL Viewer\e[0m";
        flatpak --assumeyes install io.github.wdaniau.fstl > /dev/null 2>&1;
        check_fp_install;
    fi

    echo -e "\e[32m - install_utils_flatpak() finished\n\e[0m";
    /usr/bin/logger 'install_utils_flatpak() finished' -t 'Customizing Debian';
}

install_gnome_dash_to_panel() {
    echo -e "\e[32m - install_gnome_dash_to_panel()\e[0m";
    /usr/bin/logger 'install_gnome_dash_to_panel()' -t 'Customizing Debian';

    # Check that gnome.org is reachable
    TEST_URL="gnome.org";
    check_connectivity_http;

    TOOL_SOURCE="Gnome Extensions";
    TOOL_INSTALL="$GNOME_DASH_TO_PANEL_NAME";
    echo -e "\e[36m .... installing the Dash-to-Panel Gnome Extension\e[0m";
    # Requires log out then logon
    cd $SCRIPT_DIR;
    wget --user-agent="$USER_AGENT" "$EXTENSIONS_URL/$GNOME_DASH_TO_PANEL_NAME" > /dev/null 2>&1; 
    export D2P_UUID=$(unzip -c $SCRIPT_DIR/$GNOME_DASH_TO_PANEL_NAME metadata.json | grep uuid | cut -d \" -f4) > /dev/null 2>&1;
    echo -e "\e[36m .... Installing the Dash-to-Panel Gnome Extension $D2P_UUID\e[0m";
    gnome-extensions install $SCRIPT_DIR/$GNOME_DASH_TO_PANEL_NAME > /dev/null 2>&1;
    sudo cp ~/.local/share/gnome-shell/extensions/$D2P_UUID/schemas/*.gschema.xml /usr/share/glib-2.0/schemas/
    sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
    echo -e "\e[32m$PKG_COUNT.\t\e[34m$D2P_UUID\e[32m successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
    let "PKG_COUNT=$PKG_COUNT+1";

    echo -e "\e[32m - install_gnome_dash_to_panel() finished\n\e[0m";
    /usr/bin/logger 'install_gnome_dash_to_panel() finished' -t 'Customizing Debian';
}

install_gnome_caffeine() {
    echo -e "\e[32m - install_gnome_caffeine()\e[0m";
    /usr/bin/logger 'install_gnome_caffeine()' -t 'Customizing Debian';

    # Check that gnome.org is reachable
    TEST_URL="gnome.org";
    check_connectivity_http;

    TOOL_SOURCE="Gnome Extensions";
    TOOL_INSTALL="$GNOME_CAFFEINE_NAME";
    echo -e "\e[36m .... installing the $GNOME_CAFFEINE_NAME Gnome Extension\e[0m";
    # Requires log out then logon
    cd $SCRIPT_DIR;
    wget --user-agent="$USER_AGENT" "$EXTENSIONS_URL/$GNOME_CAFFEINE_NAME" > /dev/null 2>&1; 
    export CAF_UUID=$(unzip -c $SCRIPT_DIR/$GNOME_CAFFEINE_NAME metadata.json | grep uuid | cut -d \" -f4) > /dev/null 2>&1;
    echo -e "\e[36m .... Installing the Gnome Extension $CAF_UUID\e[0m";
    gnome-extensions install $SCRIPT_DIR/$GNOME_CAFFEINE_NAME > /dev/null 2>&1;
    sudo cp ~/.local/share/gnome-shell/extensions/$CAF_UUID/schemas/*.gschema.xml /usr/share/glib-2.0/schemas/
    sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
    echo -e "\e[32m$PKG_COUNT.\t\e[34m$CAF_UUID\e[32m successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
    let "PKG_COUNT=$PKG_COUNT+1";
 
    echo -e "\e[32m - install_gnome_caffeine() finished\n\e[0m";
    /usr/bin/logger 'install_gnome_caffeine() finished' -t 'Customizing Debian';
}

enable_gnome_extensions() {
    echo -e "\e[32m - enable_gnome_extensions()\e[0m";
    /usr/bin/logger 'enable_gnome_extensions()' -t 'Customizing Debian';

    TOOL_SOURCE="Autostart";
    TOOL_INSTALL="Enable Gnome Extensions at next logon for user: - $USER -";    
    mkdir -p ~/.config/autostart
    cat << ___EOF___ > ~/.config/autostart/gnome-extensions.desktop
[Desktop Entry]
Type=Application
Name=GNOME Extensions Setup
Exec=$SCRIPT_DIR/gnome-extensions.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
___EOF___
    sudo chmod 755 $SCRIPT_DIR/gnome-extensions.sh > /dev/null 2>&1;
    echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m successfully installed as autostart\e[0m" | tee -a $SCRIPT_DIR/features.log;
    let "PKG_COUNT=$PKG_COUNT+1";

    echo -e "\e[32m - enable_gnome_extensions() finished\n\e[0m";
    /usr/bin/logger 'enable_gnome_extensions() finished' -t 'Customizing Debian';
}

configure_nix() {
    echo -e "\e[32m - configure_nix()\e[0m";
    /usr/bin/logger 'configure_nix()' -t 'Customizing Debian';

    TEST_URL="debian.org";
    check_connectivity_ping;

    # curl, git and wget must always be there
    TOOL_INSTALL="cURL, git, and wget prerequisites for script";
    TOOL_SOURCE="Debian Repository";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install curl wget git > /dev/null 2>&1;
    check_status_install;

    configure_grub;

    echo -e "\e[36m .... Configuring Linux changes\e[0m";
    # NTFS and EXFAT Support
    install_ntfs;

    # Serial and USB ports
    if [ "$CONFIGURE_SERIAL" == "Always" ]; then
        configure_serial_access;            
    fi
    echo -e "\e[32m - configure_nix() finished\n\e[0m";
    /usr/bin/logger 'configure_nix() finished' -t 'Customizing Debian';
}

configure_sudo() {
    echo -e "\e[32m - configure_sudo()\e[0m";
    /usr/bin/logger 'configure_sudo()' -t 'Customizing Debian';
    
    echo -e "\e[36m .... Adding user: - $USER - to group $SUDOGROUP\e[0m";
    echo -e "\e[35m .... You must provide the root password, then logout and rerun script";
    echo -e "\e[35m$(su - root -c "/sbin/usermod -aG $SUDOGROUP $USER")\e[0m"
    echo -e "\e[35m$("/usr/bin/newgrp $SUDOGROUP")\e[0m"
        
    echo -e "\e[32m - configure_sudo() finished\e[0m";
    /usr/bin/logger 'configure_sudo() finished' -t 'Customizing Debian';
}

configure_apt_repositories() {
    echo -e "\e[32m - configure_apt_repositories()\e[0m";
    /usr/bin/logger 'configure_apt_respositories()' -t 'Customizing Debian';

    TOOL_INSTALL="apt repositories contrib, non-free, and non-free-firmware";
    TOOL_SOURCE="Debian Repository";
    
    export NON_FREE=$(grep -i "$TOOL_INSTALL" /etc/apt/sources.list)
    if [ -n "$NON_FREE" ]; then
        echo -e "\e[1;36m .... apt repositories contrib, non-free, and non-free-firmware already configured\e[0m";
        check_status_install;
    else
        echo -e "\e[36m .... adding contrib, non-free, and non-free-firmware repositories to sources.list\e[0m";
        sudo sed -ie "s/main/main contrib non-free non-free-firmware/" /etc/apt/sources.list
        sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1;
        check_status_install
        echo "#$TOOL_INSTALL" | sudo tee -a /etc/apt/sources.list > /dev/null 2>&1;
    fi

    echo -e "\e[32m - configure_apt_repositories() finished\n\e[0m";
    /usr/bin/logger 'configure_apt_respositories() finished' -t 'Customizing Debian';
}

configure_microsoft_apt_repository() {
    echo -e "\e[32m - configure_microsoft_apt_repository()\e[0m";
    /usr/bin/logger 'configure_microsoft_apt_respository()' -t 'Customizing Debian';

    # Check that microsoft.com is reachable
    TEST_URL="microsoft.com";
    check_connectivity_http;

    TOOL_INSTALL="Microsoft Linux Repo";
    TOOL_SOURCE="Microsoft Repo .deb package";
    cd $SCRIPT_DIR;
    echo -e "\e[36m .... adding packages-microsoft-prod.deb to sources.list\e[0m";
    # Download the Microsoft repository GPG keys
    echo -e "\e[36m .... Download the Microsoft repository GPG keys\e[0m";
    wget --user-agent="$USER_AGENT" -q https://packages.microsoft.com/config/debian/$VER/packages-microsoft-prod.deb -O $SCRIPT_DIR/ms.deb
    # Register the Microsoft repository GPG keys
    echo -e "\e[36m .... Register the Microsoft repository GPG keys\e[0m";
    sudo dpkg -i ms.deb  > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="Update Microsoft Repository information locally";
    # Update the list of packages after we added packages.microsoft.com
    sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m - configure_microsoft_apt_repository() finished\n\e[0m";
    /usr/bin/logger 'configure_microsoft_apt_respository() finished' -t 'Customizing Debian';
}

configure_serial_access() {
    echo -e "\e[32m - configure_serial_access()\e[0m";
    /usr/bin/logger 'configure_serial_access()' -t 'Customizing Debian';
   
    if id -nG "$USER" | grep -q "$SERIALGROUP"; then
        echo -e "\e[32m - $USER already  belongs to group: $SERIALGROUP, nothing to do\e[0m"
    else
        echo -e "\e[36m .... Adding User: - $USER - to group $SERIALGROUP";
        echo -e "\e[35m .... $(sudo /sbin/usermod -aG $SERIALGROUP $USER)\e[0m"
    fi

    # USB (plugdev)
    if id -nG "$USER" | grep -q "$USBGROUP"; then
        echo -e "\e[32m - $USER already  belongs to group: $USBGROUP, nothing to do\e[0m"
    else
        echo -e "\e[36m .... Adding User: - $USER - to group $USBGROUP";
        echo -e "\e[35m .... $(sudo /sbin/usermod -aG $USBGROUP $USER)\e[0m"
    fi

    echo -e "\e[32m - configure_serial_access() finished\n\e[0m";
    /usr/bin/logger 'configure_serial_access() finished' -t 'Customizing Debian';
}

install_pwsh() {
    echo -e "\e[32m - install_pwsh()\e[0m";
    /usr/bin/logger 'install_pwsh()' -t 'Customizing Debian';

    # Check that microsoft.com is reachable
    TEST_URL="microsoft.com";
    check_connectivity_http;

    TOOL_SOURCE="Microsoft Repo";
    # Install PowerShell
    TOOL_INSTALL="pwsh";
    echo -e "\e[36m .... Installing Powershell\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install powershell > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m - install_pwsh() finished\n\e[0m";
    /usr/bin/logger 'install_pwsh() finished' -t 'Customizing Debian';
}

configure_kb_shortcuts() {
    echo -e "\e[32m - configure_kb_shortcuts()\e[0m";
    /usr/bin/logger 'configure_kb_shortcuts()' -t 'Customizing Debian';

    TOOL_INSTALL="Keyboard Shortcuts";
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
    echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m successfully installed with gsettings\e[0m" | tee -a $SCRIPT_DIR/features.log;
    let "PKG_COUNT=$PKG_COUNT+1";

    echo -e "\e[32m - configure_kb_shortcuts() finshed\e[0m";
    /usr/bin/logger 'configure_kb_shortcuts() finished' -t 'Customizing Debian';
}

configure_min_max_buttons() {
    echo -e "\e[32m - configure_min_max_buttons()\e[0m";
    /usr/bin/logger 'configure_min_max_buttons()' -t 'Customizing Debian';

    TOOL_INSTALL="Minimize and Maximize Buttons";
    echo -e "\e[36m .... Configuring GNOME Windows Manager to show minimize and maximize buttons\e[0m";
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
    echo -e "\e[32m$PKG_COUNT.\t\e[34m$TOOL_INSTALL\e[32m successfully installed with gsettings\e[0m" | tee -a $SCRIPT_DIR/features.log;
    let "PKG_COUNT=$PKG_COUNT+1";

    echo -e "\e[32m - configure_min_max_buttons() finished\n\e[0m";
    /usr/bin/logger 'configure_min_max_buttons() finished' -t 'Customizing Debian';
}

install_golang() {
    echo -e "\e[32m - install_golang()\e[0m";
    /usr/bin/logger 'install_golang()' -t 'Customizing Debian';

    # Check that go.dev is reachable
    TEST_URL="go.dev";
    check_connectivity_http;

    cd $SCRIPT_DIR;
    TOOL_INSTALL="go"
    echo -e "\e[1;36m .... Downloading golang $GO_URL\e[0m";
    sudo mkdir -p /usr/local/ > /dev/null 2>&1;
    export GO_LATEST="$(curl --user-agent $USER_AGENT --silent $GO_URL | head -n1)" > /dev/null 2>&1;
    TOOL_SOURCE="$GO_LATEST linux-amd64 tarball";
    export GO_DOWNLOAD="https://go.dev/dl/$GO_LATEST.linux-amd64.tar.gz" > /dev/null 2>&1;
    wget --user-agent="$USER_AGENT" -q "$GO_DOWNLOAD" -O ./go.tar.gz > /dev/null 2>&1;
    echo -e "\e[1;36m .... Removing previous install of golang\e[0m";
    /usr/bin/logger 'Removing previous install of golang' -t 'Customizing Debian';
    sudo rm -rf /usr/local/go > /dev/null 2>&1;
    echo -e "\e[1;36m .... Opening and extracting golang tarball\e[0m";
    /usr/bin/logger 'Open and extract the golang tarball' -t 'Customizing Debian';
    sudo tar -C /usr/local -xzf go.tar.gz > /dev/null 2>&1;

    if test -f "/etc/profile.d/go_lang.sh"; then
        echo -e "\e[1;36m .... golang path already configured\e[0m";        
    else
        echo -e "\e[1;36m .... Configuring golang path\e[0m";        
        echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go_lang.sh > /dev/null 2>&1;
        sudo chmod 644 /etc/profile.d/go_lang.sh
    fi
    PATH=$PATH:/usr/local/go/bin
    check_install;

    echo -e "\e[36m .... Installed $(/usr/local/go/bin/go version)\n\e[0m"
    /usr/bin/logger "Installed $(/usr/local/go/bin/go version)" -t 'Customizing Debian';
}

install_docker() {
    echo -e "\e[32m - install_docker()\e[0m";
    /usr/bin/logger 'install_docker()' -t 'Customizing Debian';

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="docker";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install docker.io docker-compose > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m - install_docker() finished\n\e[0m";
    /usr/bin/logger 'install_docker() finished' -t 'Customizing Debian';
}

install_ytdlp() {
    echo -e "\e[32m - install_ytdlp()\n\e[0m";
    /usr/bin/logger 'install_ytdlp()' -t 'Customizing Debian';

    TOOL_SOURCE="PIP Virtual Environment";
    TOOL_INSTALL="yt-dlp";
    VENV_NAME=".venv";
    config_venv;
    TOOL_INSTALL="yt-dlp";
    TOOL_SOURCE="PIP Repository";
    pip install yt-dlp > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m - install_ytdlp() finished\n\e[0m";
    /usr/bin/logger 'install_ytdlp() finished' -t 'Customizing Debian';
}

show_errors() {
    # Show any errors logged in features.log
    COUNT_FEATURE_ERRORS=$(grep "ERROR:" $SCRIPT_DIR/features.log | wc -l) > /dev/null 2>&1;
    FEATURE_ERRORS=$(grep "ERROR:" $SCRIPT_DIR/features.log) > /dev/null 2>&1;
    # PKG_COUNT will already have counted up for the next package, so detract 1
    let "PKG_COUNT=$PKG_COUNT-1";
    if [ -n $FEATURE_ERRORS ]; then
        echo -e "\e[32mNo errors during install. $PKG_COUNT features installed\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "No errors during install. $PKG_COUNT features installed" -t 'Customizing Debian';
    else
        echo -e "\e[31m$COUNT_FEATURE_ERRORS of $PKG_COUNT features errored out during installation\e[0m";
        echo -e "\e[31mThese features failed installation:\r\n $FEATURE_ERRORS\e[0m";
        /usr/bin/logger "\e[31m$COUNT_FEATURE_ERRORS of $PKG_COUNT features errored out during installation\e[0m" -t 'Customizing Debian';
    fi
}

cleanup() {
    echo -e "\e[32m - cleanup()\e[0m";
    /usr/bin/logger 'cleanup()' -t 'Customizing Debian';

    TOOL_SOURCE="Linux";
    TOOL_INSTALL="Cleanup";
    rm $SCRIPT_DIR/*.zip > /dev/null 2>&1;
    rm $SCRIPT_DIR/*.gz > /dev/null 2>&1;
    rm $SCRIPT_DIR/*.deb > /dev/null 2>&1;
    sudo apt -y autoremove --purge > /dev/null 2>&1;
    check_status_install;
    sudo apt autoclean > /dev/null 2>&1;

    # update flatpaks
    TOOL_SOURCE="Flatpak";
    TOOL_INSTALL="updates";
    flatpak --assumeyes update > /dev/null 2>&1;
    check_status_install;

    sync;

    echo -e "\e[32m - cleanup() finished\e[0m";
    /usr/bin/logger 'cleanup() finished' -t 'Customizing Debian';
}

#################################################################################################################
## Main Routine                                                                                                 #
#################################################################################################################
main() {
    /usr/bin/logger 'main() routine starting' -t 'Customizing Debian';

    # Show intro message
    do_intro;

    # Dir where script is running
    export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    # Configure variables from .env-file
    configure_env;

    if id -nG "$USER" | grep -q "$SUDOGROUP"; then
        echo -e "\e[32m - $USER already  belongs to group: $SUDOGROUP, installation will continue using sudo\e[0m"
        # Ensuring that sudo group membership is active.
        # /usr/bin/newgrp $SUDOGROUP;
        # Get sudo password
        echo -e "\e[35m - Sudo password needed"
        echo -e "\e[35m - $(sudo echo .)\e[0m"

        # Separate window for features.log
        open_featureslog;
        
        # Check internet access
        TEST_URL="debian.org";
        check_connectivity_ping;

        # Configure repos and install updates as the first thing
        # APT Repositories
        if [ "$APT_CONFIGURE" == "Yes" ]; then
            configure_apt_repositories;
        fi

        # Install updates from repositories
        if [ "$UPDATES_INSTALL" == "Always" ]; then
            install_updates;
        fi

        # Core NIX configuration
        if [ "$NIX_CONFIGURE" == "Always" ]; then
          configure_nix;
        fi

        # Gnome Keyboard Shortcuts
        if [ "$KB_SHORTCUTS" == "Yes" ]; then
            configure_kb_shortcuts;
        fi

        # Gnome Extensions
        # Gnome Extension Dash to Panel
        if [ "$GNOME_DASH_TO_PANEL" == "Yes" ]; then
            install_gnome_dash_to_panel;
        fi
        # Gnome Extension Caffeine
        if [ "$GNOME_CAFFEINE" == "Yes" ]; then
            install_gnome_caffeine;
        fi

        # Gnome show minimize and maximize buttons
        if [ "$MM_BUTTONS_CONFIGURE" == "Yes" ]; then
            configure_min_max_buttons;
        fi

        enable_gnome_extensions;

        # Flatpak
        if [ "$FLATPAK_UTILS" == "Always" ]; then
            install_flatpak;
            install_utils_flatpak;
        fi

        # Debian APT packages
        if [ "$APT_UTILS" == "Always" ]; then
            install_utils_apt;
        fi

       # Install HWHack Tools
        if [ "$HWHACKTOOLS_INSTALL" == "Yes" ]; then
            install_hwhacktools;
        fi

       # Install Reverse Engineering Tools
        if [ "$REVERSETOOLS_INSTALL" == "Yes" ]; then
            install_reversetools;
        fi

        # GOLANG
        if [ "$GO_INSTALL" == "Yes" ]; then
            install_golang;            
        fi

        if [ "$PULSEVIEW_INSTALL" == "Yes" ]; then
            install_pulseview;
        fi

        # Virtualization
        if [ "$VIRT_INSTALL" == "Yes" ]; then
            install_virtualization;
        fi

        # Docker Installation
        if [ "$DOCKER_INSTALL" == "Yes" ]; then
            install_docker;
        fi

        # HASHCAT installation
        # Note: depends on devtools being installed
        if [ "$HASHCAT_INSTALL" == "Yes" ]; then
            install_hashcat;
        fi
    
        # Microsoft Debian Packages repo and PowerShell
        if [ "$MICROSOFT_APT" == "Yes" ]; then
            configure_microsoft_apt_repository;

            if [ "$PWSH_INSTALL" == "Yes" ]; then
                install_pwsh;
            fi
        fi

        # final cleanup
        cleanup;
        show_errors;

        # Show finishing message
        do_outro;
        
    # Cannot sudo
    else
        echo -e "\e[1;36m$USER does not belong to group $SUDOGROUP, please provide root password\e[0m"
        configure_sudo;
        echo -e "\e[1;31mNow rerun this script\e[0m"
    fi

    /usr/bin/logger 'main() finished' -t 'Customizing Debian';
    read -p "Do You want to reboot now? (y/n)" DO_REBOOT;
    export DO_IT_NOW=$(echo $DO_REBOOT | tr a-z A-Z);
    if [ "$DO_IT_NOW" == "Y" ]; then
        sync;
        systemctl reboot;
    else
         echo -e "\e[1;31mYou should reboot soon, or at least logout to enable GNOME Extensions\e[0m"
    fi
}

main

exit 0
