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
    echo -e '\e[32m\t   ___          _                '  _     _
    echo -e '\e[32m\t / ___|   _ ___| |_ ___  _ __ ___ (_)___(_)_ __   __ _  '
    echo -e '\e[32m\t| |  | | | / __| __/ _ \| ´_ ` _ \| |_  / | ´_ \ / _` | '
    echo -e '\e[32m\t| |__| |_| \__ \ || (_) | | | | | | |/ /| | | | | (_| | '
    echo -e '\e[32m\t \____\__,_|___/\__\___/|_| |_| |_|_/___|_|_| |_|\__, | '
    echo -e '\e[32m\t|                                                |___/  '
    echo -e
    /usr/bin/logger 'do_intro() finished' -t 'Customizing Debian';
}

do_outro() {
    /usr/bin/logger 'do_outro()' -t 'Customizing Debian';
    echo -e "\e[32m\n";
    echo -e "\e[32m\t-----------------------------------------------------";
    echo -e "\e[33m\t\t Installed Configuration: \e[35m$PRESET_SELECTED\e[0m";
    echo -e "\e[32m\t-----------------------------------------------------";
    echo -e "\e[32m\n";
    echo -e "\e[32m\n";
    echo -e '\e[32m\t  ____          _                  _          _   _              '
    echo -e '\e[32m\t / ___|   _ ___| |_ ___  _ __ ___ (_)______ _| |_(_) ___  _ __   '
    echo -e '\e[32m\t| |  | | | / __| __/ _ \| ´_ ` _ \| |_  / _` | __| |/ _ \| ´_ \  '
    echo -e '\e[32m\t| |__| |_| \__ \ || (_) | | | | | | |/ / (_| | |_| | (_) | | | | '
    echo -e '\e[32m\t \____\__,_|___/\__\___/|_|_|_| |_|_/___\__,_|\__|_|\___/|_| |_| '
    echo -e '\e[32m\t             |  ___(_)_ __ (_)___| |__   ___  __| |              '
    echo -e '\e[32m\t             | |_  | | ´_ \| / __| ´_ \ / _ \/ _` |              ' 
    echo -e '\e[32m\t             |  _| | | | | | \__ \ | | |  __/ (_| |              '
    echo -e '\e[32m\t             |_|   |_|_| |_|_|___/_| |_|\___|\__,_|              \e[0m'
    echo -e
    /usr/bin/logger 'do_outro() finished' -t 'Customizing Debian';
}

configure_env() {
    echo -e "\e[35m[*] configure_env()\e[0m";
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

    echo -e "\e[35m-------------------------------------------------------------------\e[0m"
    echo -e "\e[35m\tenv file version $ENV_VERSION\e[0m"
    echo -e
    show_features_enabled;
    echo -e
    echo -e "\e[35m\tGNOME version: $GNOME_VERSION\e[0m"

    # OS Version freedesktop.org and systemd
    . /etc/os-release
    export OS=$NAME
    export VER=$VERSION_ID
    export CODENAME=$VERSION_CODENAME
    echo -e "\e[35m\tOperating System: $OS Version: $VER: $CODENAME\e[0m";
    echo -e "\e[35m-------------------------------------------------------------------\e[0m"
    echo -e
    /usr/bin/logger "Operating System: $OS Version: $VER: $CODENAME" -t 'Customizing Debian';

    if [ "$VER" == "$DEBIAN_SUPPORTED" ]; then
        echo -e "\e[32m[√]\tRunning Debian $VER codename $CODENAME. All good to go\e[0m"
    else
        echo -e "\e[31m[-]\tNOT running Debian $DEBIAN_SUPPORTED, but $OS, $VER codename $CODENAME. Script shall exit\e[0m"
        exit 1;
    fi

    mkdir -p $GIT_HOME;
    mkdir -p $SOURCE_DIR;
    mkdir -p $RE_DIR;

    echo -e "\e[35m[+] configure_env() finished\n\e[0m";
    /usr/bin/logger 'configure_env() finished' -t 'Customizing Debian';
}

configure_venv() {
    #echo -e "\e[35m[*]\t └─ configure_venv()\e[0m";
    /usr/bin/logger 'configure_venv()' -t 'Customizing Debian';

    TOOL_INSTALL="Python VENV $VENV_NAME for $TOOL_INSTALL";
    TOOL_SOURCE="Python";

    if [ -d "$VENV_NAME/bin" ] ; then
        echo -e "\e[32m[+]\t$PKG_COUNT.\t$TOOL_INSTALL already installed from $TOOL_SOURCE\e[0m"   
        check_status_install;
    else
        python3 -m venv $VENV_NAME #> /dev/null 2>&1;
        check_status_install;
    fi

    export PATH="$HOME/$VENV_NAME/bin:$PATH"
    # activate Virtual Env
    TOOL_INSTALL="Activated Python VENV $VENV_NAME";
    TOOL_SOURCE="Python";
    source $VENV_NAME/bin/activate

    #echo -e "\e[35m[+]\t └─ configure_venv() finished\e[0m";
    /usr/bin/logger 'configure_venv() finished' -t 'Customizing Debian';
}

configure_primary_venv_path() {
    echo -e "\e[35m[*] configure_primary_venv_path()\e[0m";
    /usr/bin/logger 'configure_primary_venv_path()' -t 'Customizing Debian';

    # Create path to the core virtual environment (and no other to avoid confusion)
    echo -e "\e[35m[*]\t └─ Checking VENV path for primary Python VENV\e[0m";
    export VENV_PATH=$(grep ".venv/bin" ~/.profile)
    if [ -n "$VENV_PATH" ]; then
        echo -e "\e[35m[*]\t └─ VENV path already configured\e[0m";
    else
        echo -e "\e[35m[*]\t └─ Adding VENV path to $HOME/.profile\e[0m";
        cat << ___EOF___ >> ~/.profile

# set PATH so it includes user's primary private virtual environment/bin if it exists
if [ -d "\$HOME/.venv/bin" ] ; then
    PATH="\$HOME/.venv/bin:\$PATH"
fi
___EOF___
    fi

    echo -e "\e[35m[*] configure_primary_venv_path() finished\e[0m";
    /usr/bin/logger 'configure_primary_venv_path() finished' -t 'Customizing Debian';
}

configure_grub() {
    echo -e "\e[35m[*] configure_grub()\e[0m";
    /usr/bin/logger 'configure_grub()' -t 'Customizing Debian';

    # change grub timeout
    TOOL_SOURCE="Grand Unified Bootloader";

    if [ $(grep "GRUB_TIMEOUT=$GRUB_TIMEOUT" /etc/default/grub) ]; then 
        TOOL_INSTALL="GRUB Timeout already set to $GRUB_TIMEOUT. Nothing to do.";
        check_status_install;
    else
        TOOL_INSTALL="GRUB_TIMEOUT=$GRUB_TIMEOUT";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=$GRUB_TIMEOUT/" /etc/default/grub
        sudo update-grub > /dev/null 2>&1;
        check_status_install;
    fi

    echo -e "\e[32m[+] configure_grub() finished\n\e[0m";
    /usr/bin/logger 'configure_grub() finished' -t 'Customizing Debian';
}

check_connectivity_ping() {
    # Checking that we can reach $TEST_URL over icmp
    until ping -c 1 -W 2 $TEST_URL > /dev/null 2>&1; do
        echo -e "\e[31m[-]\t Waiting for connectivity to $TEST_URL...\e[0m";
        sleep 5;
    done
    echo -e "\e[32m[+]\t[√] ICMP access to $TEST_URL. Continuing installation...\e[0m";
}

check_connectivity_http() {
    # Checking that we can reach $TEST_URL over HTTP
    until curl --user-agent $USER_AGENT --silent --head --request GET https://$TEST_URL > /dev/null 2>&1; do
        echo -e "\e[31m[-]\t Waiting for network access to $TEST_URL...\e[0m";
        sleep 5;
    done
    echo -e "\e[32m[+]\t[√] HTTPS access to $TEST_URL\e[0m"
}

check_already_installed() {
    # check if already installed
    TOOL_FOUND=$(which $TOOL_ELF) > /dev/null 2>&1;
    if [ -n "$TOOL_FOUND" ]; then
        TOOL_INSTALLED=True;
        echo -e "\e[32m\t$PKG_COUNT.\t[+] $TOOL_INSTALL successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "$TOOL_ELF successfully installed" -t 'Customizing Debian';
        let "PKG_COUNT=$PKG_COUNT+1"
    else
        TOOL_INSTALLED=False;
    fi
    sudo echo > /dev/null 2>&1;
}

check_install() {
    which $TOOL_INSTALL > /dev/null 2>&1;
    if [ "$?" == 0 ]; then
        echo -e "\e[32m$PKG_COUNT.\t[+] $TOOL_INSTALL successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "$TOOL_INSTALL successfully installed from $TOOL_SOURCE" -t 'Customizing Debian';
    else
        echo -e "\e[31m$PKG_COUNT.\t[-] ERROR: $TOOL_INSTALL not installed correctly\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "\e[31m------- ERROR: $TOOL_INSTALL not installed -------\e[0m" -t 'Customizing Debian';
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}

check_status_install() {
    if [ "$?" == 0 ]; then
        /usr/bin/logger "$TOOL_INSTALL successfully installed from $TOOL_SOURCE" -t 'Customizing Debian';
        echo -e "\e[32m$PKG_COUNT.\t[+] $TOOL_INSTALL successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
     else
        echo -e "\e[31m$PKG_COUNT.\t[-] ERROR: $TOOL_INSTALL not installed correctly\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "\e[31m------- ERROR: $TOOL_INSTALL not installed -------\e[0m" -t 'Customizing Debian';
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}

check_fp_install() {
    FP_INSTALL=$(flatpak list | grep -i $TOOL_INSTALL | awk '{print $1}');
    if [ -n "$FP_INSTALL" ]; then
        echo -e "\e[32m$PKG_COUNT.\t[+] $TOOL_INSTALL successfully installed from flatpak repository\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "$TOOL_INSTALL successfully installed" -t 'Customizing Debian';
    else
        echo -e "\e[31m$PKG_COUNT.\t[-] ERROR: $TOOL_INSTALL not installed correctly\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "\e[31m------- ERROR: $TOOL_INSTALL not installed -------\e[0m" -t 'Customizing Debian';
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}

check_ldd_install() {
    # check libraries for TOOL_ELF are installed
    LDD_TOOL=$(which $TOOL_ELF | xargs ldd | grep $TOOL_INSTALL) > /dev/null 2>&1;
    if [ -n "$LDD_TOOL" ]; then
        echo -e "\e[32m$PKG_COUNT.\t[+] $TOOL_INSTALL successfully installed from $TOOL_SOURCE\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "$TOOL_INSTALL successfully installed" -t 'Customizing Debian';
    else
        echo -e "\e[31m$PKG_COUNT.\t[-] ERROR: $TOOL_INSTALL not installed correctly\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "\e[31m------- ERROR: $TOOL_INSTALL not installed -------\e[0m" -t 'Customizing Debian';
    fi
    let "PKG_COUNT=$PKG_COUNT+1"
    sudo echo > /dev/null 2>&1;
}

install_updates() {
    echo -e "\e[35m[*] install_updates()\e[0m";
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

    cd $SCRIPT_DIR;

    echo -e "\e[32m[+] install_updates() finished\n\e[0m";
    /usr/bin/logger 'install_updates() finished' -t 'Customizing Debian';
}

show_features_enabled() {
    echo -e "\e[35m  ### Installing the following Features ###"
    while IFS='=' read -r key value; do
        # Remove leading/trailing spaces and quotes from key and value
        key=$(echo "$key" | tr -d ' ')
        value=$(echo "$value" | tr -d ' "' | cut -d'#' -f1)

            if [ "$value" = "Yes" ]; then
                echo -e "\e[35m\t++ $key\e[0m"
            fi
    done < $SCRIPT_DIR/.env;
    echo -e "\e[35m\n\t++ Based on the preset: \e[36m$PRESET_SELECTED\n\e[0m"
}

open_featureslog() {
    touch $SCRIPT_DIR/features.log;
    # Start new terminal window tailing features.log
    x-terminal-emulator -e bash -c "tail -f $SCRIPT_DIR/features.log" &
}

install_proprietary_filesystems() {
    echo -e "\e[35m[*] install_proprietary_filesystems()\e[0m";
    /usr/bin/logger 'install_proprietary_filesystems()' -t 'Customizing Debian';
    
    TEST_URL="debian.org";
    check_connectivity_http;
    TOOL_SOURCE="Debian Repository";
    export DEBIAN_FRONTEND=noninteractive;
    TOOL_INSTALL="ntfs-3g";
    echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ntfs-3g > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="exfat";
    echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install exfat-fuse exfatprogs > /dev/null 2>&1;
    check_status_install;

    cd $SCRIPT_DIR;
    
    echo -e "\e[32m[+] install_proprietary_filesystems() finished\n\e[0m";
    /usr/bin/logger 'install_proprietary_filesystems() finished' -t 'Customizing Debian';
}

install_utils_apt() {
    echo -e "\e[35m[*] install_utils_apt()\e[0m";
    /usr/bin/logger 'install_utils_apt()' -t 'Customizing Debian';

    export DEBIAN_FRONTEND=noninteractive;
    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Selected software features";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL from $TOOL_SOURCE\n\e[0m";

    # Trixie backports
    if [ "$BACKPORTS_INSTALL" == "Yes" ]; then
        install_backports;
    fi

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
        auto_activate_venv;
    fi

    # DEVTOOLS_INSTALL
    if [ "$DEVTOOLS_INSTALL" == "Yes" ]; then
        install_devtools;
    fi

    echo -e "\e[32m[+] install_utils_apt() finished\n\e[0m";
    /usr/bin/logger 'install_utils_apt() finished' -t 'Customizing Debian';
}

install_hashcat() {
    /usr/bin/logger 'installing hashcat' -t 'Customizing Debian';
    echo -e "\e[35m[*] install_hashcat()\e[0m";

    TOOL_SOURCE="Source";
    TOOL_INSTALL="hashcat";
    TOOL_ELF="hashcat";
    check_already_installed;

    if [ $TOOL_INSTALLED == False ]; then
        # Check that github is reachable
        TEST_URL="github.com";
        check_connectivity_http;

        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="hashcat prerequisites";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";   
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libpocl-dev libbz2-dev libssl-dev libncurses5-dev libffi-dev libreadline-dev libsqlite3-dev \
            liblzma-dev > /dev/null 2>&1;
        check_status_install;
        
        # install VENV for hashcat
        TOOL_INSTALL="hashcat Virtual Environment";
        TOOL_SOURCE="Python VENV";
        # echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";   
        VENV_NAME=~/.hashcat_venv;
        configure_venv;

        TOOL_INSTALL="hashcat PIP Requirements";
        TOOL_SOURCE="PIP Repository";
        pip install pyescrypt > /dev/null 2>&1;
        check_status_install;

        TOOL_SOURCE="Source";
        TOOL_INSTALL="hashcat";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";   
        cd $SOURCE_DIR;
        #git clone https://github.com/hashcat/hashcat.git > /dev/null 2>&1;
        wget https://github.com/hashcat/hashcat/archive/refs/tags/v$HASHCAT_RELEASE.tar.gz > /dev/null 2>&1;
        tar -xzf v$HASHCAT_RELEASE.tar.gz > /dev/null 2>&1;
        cd hashcat-$HASHCAT_RELEASE/
        make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        check_install;
        cd $SOURCE_DIR;
        rm v$HASHCAT_RELEASE.tar.gz > /dev/null 2>&1;
        cd $SCRIPT_DIR;
    fi

    TOOL_INSTALL="Hashcat $(hashcat --version)";
    check_status_install;
 
    echo -e "\e[32m[+] install_hashcat() finished\n\e[0m";
    /usr/bin/logger "installing hashcat finished" -t 'Customizing Debian';
}

install_backports() {
    /usr/bin/logger 'installing Debian backports repository ' -t 'Customizing Debian';
    echo -e "\e[35m[*] install_backports()\e[0m";
    
    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Trixie backports";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";   
    if [ -f /etc/apt/sources.list.d/debian-backports.sources ]; then
        echo -e "\e[35m[*]\tbackports already configured\n\e[0m";
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
    sudo apt update > /dev/null 2>&1;
    check_status_install;
    fi

    cd $SCRIPT_DIR;

    echo -e "\e[32m[+] install_backports() finished\n\e[0m";
    /usr/bin/logger 'installing Debian backports repository finished' -t 'Customizing Debian';
}

install_pythontools() {
    /usr/bin/logger 'installing Python stuff from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[35m[*] install_pythontools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="python-dotenv";
    echo -e "\e[35m[*]\t └─ Installing Python tools\e[0m";   
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python3 python3-pip python3-setuptools python3-gnupg python3-venv \
        libpython3-dev > /dev/null 2>&1;
    check_status_install;
    VENV_NAME=~/.venv;
    configure_venv;
    configure_primary_venv_path;
    # back to script directory
    cd $SCRIPT_DIR;

    echo -e "\e[32m[+] install_pythontools() finished\n\e[0m";
    /usr/bin/logger 'installing Python tools from Debian repository finished' -t 'Customizing Debian';
}

install_networktools() {
    /usr/bin/logger 'installing Network tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[35m[*] install_networktools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    # Set tool source and what to install
    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Wireshark";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";    
    if [ $(which wireshark) ]; then
        echo -e "\e[35m[*]\t └─ Wireshark already installed\e[0m";
        check_status_install;
    else
        echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark > /dev/null 2>&1;
        check_status_install;
        sudo usermod -a -G wireshark $USER > /dev/null 2>&1;
    fi

    TOOL_INSTALL="Network Tools";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";    
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install iputils-arping iputils-tracepath arpwatch arpalert tcpdump nmap ncat ngrep ethtool aircrack-ng \
        whois dnsutils flent net-tools tshark termshark > /dev/null 2>&1;
    check_status_install;
    
    create_flent_desktop_file;

    TOOL_INSTALL="Network Engineering Tools";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";    
    echo 'iperf3  iperf3/start_daemon     boolean false' | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install tcpflow-nox ipcalc-ng arp-scan fping lldpd netsniff-ng iperf3 mtr-tiny socat frr python3-scapy dnsenum \
        dnsmap onesixtyone sslscan > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="Avahi (mDNS) Tools";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";    
    # Avahi Tools to verify test avahi (avoid mdns on corp)
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install avahi-utils mdns-scan > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="AirCrack-ng Tools";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";    
    # Aircrack Tools to test wireless
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install aircrack-ng airgraph-ng mdk4 wifite > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="Bettercap Tools";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";    
    # bettercap Tools
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install bettercap > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="TCPFLOW No X Dependencies";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";    
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install tcpflow-nox > /dev/null 2>&1;
    check_status_install;

    cd $SCRIPT_DIR;

    echo -e "\e[32m[+] install_networktools() finished\n\e[0m";
    /usr/bin/logger 'installing Network tools from Debian repository finished' -t 'Customizing Debian';
}

install_forensicstools() {
    /usr/bin/logger 'installing Forensics tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[35m[*] install_forensicstools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Wireshark";
    echo -e "\e[35m[*]\t └─ Installing Wireshark\e[0m";
    if [ $(which wireshark) ]; then
        echo -e "\e[35m[*]\t └─ Wireshark already installed\e[0m";
        check_status_install;
    else
        echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark > /dev/null 2>&1;
        check_status_install;
        sudo usermod -a -G wireshark $USER > /dev/null 2>&1;
    fi

    echo -e "\e[35m[*]\t └─ Installing forensics-all\e[0m";
    TOOL_INSTALL="Forensics Tools"    
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install forensics-all > /dev/null 2>&1;
    check_status_install;
    # hashcat install with forensics-all - but want to install from source
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y purge hashcat > /dev/null 2>&1;

    echo -e "\e[35m[*]\t └─ Installing forensics-extra\e[0m";
    TOOL_INSTALL="Forensics Extra Package"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install forensics-extra > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[35m[*]\t └─ Installing additional forensics tools\e[0m";
    TOOL_INSTALL="Additional Forensics Tools"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install testdisk geoip-bin geoip-database > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="autopsy";
    TOOL_SOURCE="Debian Repository";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo apt-get -y install autopsy sleuthkit > /dev/null 2>&1;
    
    cd $SCRIPT_DIR;

    echo -e "\e[32m[+] install_forensicstools() finished\n\e[0m";
    /usr/bin/logger 'installing Forensics tools from Debian repository finished' -t 'Customizing Debian';
}

install_systemtools() {
    /usr/bin/logger 'installing System tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[35m[*] install_systemtools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="System Tools";
    echo -e "\e[35m[*]\t └─ Installing system tools\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gparted wget nano p7zip p7zip-full unzip dconf-editor htop screen > /dev/null 2>&1;
    check_status_install;
    cd $SCRIPT_DIR;

    echo -e "\e[32m[+] install_systemtools() finished\n\e[0m";
    /usr/bin/logger 'installing System tools from Debian repository finished' -t 'Customizing Debian';
}

install_usertools() {
    /usr/bin/logger 'installing User tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[35m[*] install_usertools()\e[0m";

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="User Tools";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install transmission-gtk sshpass rclone rclone-browser \
        figlet lolcat cowsay sl cmatrix webp > /dev/null 2>&1;
    check_status_install;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Video and Codecs";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install vlc ffmpeg libavcodec-extra > /dev/null 2>&1;
    check_status_install;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Default JDK";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install default-jdk > /dev/null 2>&1;
    check_status_install;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Gnome Shell Extensions UI";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gnome-shell-extension-prefs dconf-editor > /dev/null 2>&1;
    check_status_install;

    cd $SCRIPT_DIR;
    
    echo -e "\e[32m[+] install_usertools() finished\n\e[0m";
    /usr/bin/logger 'installing User tools from Debian repository finished' -t 'Customizing Debian';
}

install_devtools() {
    /usr/bin/logger 'installing Development tools from Debian repository ' -t 'Customizing Debian';
    echo -e "\e[35m[*] Installing development tools\e[0m";
    
    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    echo -e "\e[35m[*]\t └─ Installing core development tools\e[0m";
    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="Core Development Tools"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install git devscripts build-essential gnupg2 dirmngr --install-recommends > /dev/null 2>&1;
    check_status_install;

    # Some additional helpful tools
    echo -e "\e[35m[*]\t └─ Installing additional development tools\e[0m";
    TOOL_INSTALL="Additional Development Tools"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gawk xxd vbindiff gdb gdb-multiarch ddd binutils strace ltrace --install-recommends > /dev/null 2>&1;
    # Required to build Proxmark and others
    check_status_install;
   
    # cmake and QT development tools
    echo -e "\e[35m[*]\t └─ Installing cmake and QT development tools\e[0m";
    TOOL_INSTALL="cmake and QT Development Tools"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install --install-recommends ca-certificates pkg-config libreadline-dev gcc-arm-none-eabi \
        libnewlib-dev qtbase5-dev libbz2-dev liblz4-dev libbluetooth-dev libssl-dev cmake > /dev/null 2>&1;
    check_status_install;

    # Back to script directory
    cd $SCRIPT_DIR;
    
    /usr/bin/logger 'installing Development tools from Debian repository finished' -t 'Customizing Debian';
    echo -e "\e[32m[+] Installing development tools finished\n\e[0m";
}

install_jupyterlab() {
    echo -e "\e[35m[*] install_jupyterlab()\e[0m";
    /usr/bin/logger 'install_jupyterlab()' -t 'Customizing Debian';
    
    # Check that PyPi is reachable
    TEST_URL="pypi.org";
    check_connectivity_http;

    TOOL_INSTALL="jupyterlab";
    # venv for jupyterlab
    VENV_NAME=~/.venv;
    configure_venv;

    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    TOOL_SOURCE="PIP Repository";
    TOOL_INSTALL="jupyterlab";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    pip install jupyterlab > /dev/null 2>&1;
    check_status_install;

    create_jupyter_desktop_file;

    echo -e "\e[32m[+] install_jupyterlab() finished\n\e[0m";
    /usr/bin/logger 'install_jupyterlab() finished' -t 'Customizing Debian';
}

install_pulseview() {
    echo -e "\e[35m[*] install_pulseview()\e[0m";
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
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="Sigrok Prerequisite Packages (i)";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        /usr/bin/logger 'installing pulseview Prerequisites' -t 'Customizing Debian';
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install autoconf autoconf-archive automake sdcc libtool libboost-all-dev asciidoctor \
            libzip-dev ruby-dev > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="Sigrok Prerequisite Packages (ii)";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install pkg-config libglib2.0-dev libglib2.0-dev libzip5 libtirpc-dev libserialport0 libvisa0 libvisa-dev \
            libusb-1.0-0 libusb-1.0-0-dev libhidapi-hidraw0 libhidapi-libusb0 libftdi1-dev python3-pyvisa-py libieee1284-3-dev \
            libgio-2.0-dev libghc-nettle-dev check doxygen graphviz swig libglibmm-2.68-dev python-setuptools-doc python-gi-dev \
            python3-numpy python3-numpy-dev python3-doxypypy ruby openjdk-25-jdk > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="Sigrok Prerequisite Packages (iii)";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools qttools5-dev-tools qttools5-dev \
            libqt5svg5-dev > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="Sigrok Prerequisite Packages (iv)";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gpib-user-tools python3-gpib libgpib0 libgpib-dev libhidapi-dev > /dev/null 2>&1;
        check_status_install;

        # These require Debian Backports
        TOOL_INSTALL="Sigrok Prerequisite Packages (v)";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install rpcbind libtirpc3 libavahi-client-dev check > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="Sigrok";
        VENV_NAME="$SOURCE_DIR/sigrok/venv";    
        configure_venv;
        # Python pip modules needed for libsigrok
        TOOL_INSTALL="Sigrok PIP Prerequisites";
        TOOL_SOURCE="PIP Repository";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        pip install setuptools numpy > /dev/null 2>&1;
        check_status_install;

        mkdir -p $SOURCE_DIR/sigrok;
        cd $SOURCE_DIR/sigrok/;
        # Install libsigrokdecode from source
        # Note: Depending on trixie backports
        TOOL_SOURCE="Source";
        TOOL_INSTALL="libsigrokdecode";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        /usr/bin/logger 'installing libsigrokdecode' -t 'Customizing Debian';
        git clone git://sigrok.org/libsigrokdecode > /dev/null 2>&1;
        cd libsigrokdecode > /dev/null 2>&1;
        ./autogen.sh > /dev/null 2>&1;
        ./configure > /dev/null 2>&1;
        #make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make -B install > /dev/null 2>&1;
        check_status_install;
        /usr/bin/logger "$TOOL_INSTALL successfully installed" -t 'Customizing Debian';
        sudo echo > /dev/null 2>&1;

        # Install fork of libsigrok with support for SiPEED SLogic 8 and 16
        TOOL_INSTALL="libsigrok"
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        /usr/bin/logger 'installing libsigrok' -t 'Customizing Debian';
        cd $SOURCE_DIR/sigrok/;
        git clone https://github.com/martinboller/libsigrok > /dev/null 2>&1;
        #git clone -b slogic-dev https://github.com/sipeed/libsigrok > /dev/null 2>&1;
        #git clone git://sigrok.org/libsigrok > /dev/null 2>&1;
        cd libsigrok > /dev/null 2>&1;
        ./autogen.sh > /dev/null 2>&1;
        ./configure > /dev/null 2>&1;
        #make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        check_status_install;
        sudo echo > /dev/null 2>&1;

        # Install sigrok-cli from source
        /usr/bin/logger 'installing sigrok-cli' -t 'Customizing Debian';
        cd $SOURCE_DIR/sigrok/;
        TOOL_INSTALL="sigrok-cli";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        git clone git://sigrok.org/sigrok-cli > /dev/null 2>&1;
        cd sigrok-cli > /dev/null 2>&1;
        ./autogen.sh > /dev/null 2>&1;
        ./configure > /dev/null 2>&1;
        #make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        TOOL_SOURCE="Source";
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
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        /usr/bin/logger 'installing sigrok-firmware-fx2lafw' -t 'Customizing Debian';
        cd $SOURCE_DIR/sigrok/;
        git clone git://sigrok.org/sigrok-firmware-fx2lafw > /dev/null 2>&1;
        cd sigrok-firmware-fx2lafw > /dev/null 2>&1;
        ./autogen.sh > /dev/null 2>&1;
        ./configure > /dev/null 2>&1;
        #make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        check_status_install;

        # Install pulseview from source
        /usr/bin/logger 'installing pulseview' -t 'Customizing Debian';
        cd $SOURCE_DIR/sigrok/;
        TOOL_INSTALL="pulseview"
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        git clone git://sigrok.org/pulseview > /dev/null 2>&1;
        cd pulseview > /dev/null 2>&1;
        cmake .  > /dev/null 2>&1;
        #make clean > /dev/null 2>&1;
        make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        check_install;
        sudo ldconfig;

        # Load udev rules
        TOOL_INSTALL="Load UDEV Rules";
        TOOL_SOURCE="Linux";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo udevadm control --reload > /dev/null 2>&1;
    fi

    # Back home to where install script is running from
    cd $SCRIPT_DIR

    echo -e "\e[32m[+] install_pulseview() finished\n\e[0m";
    /usr/bin/logger 'install_pulseview() finished' -t 'Customizing Debian';
}

install_hwhacktools() {
    echo -e "\e[35m[*] install_hwhacktools()\e[0m";
    /usr/bin/logger 'install_hwhacktools()' -t 'Customizing Debian';

    ## Hardware Hacking Tools for Debian. Note: require development tools
    # Directory for source-code (declared in .env)
    mkdir -p $SOURCE_DIR;
    cd $SOURCE_DIR;

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    #ST-LINK (STM microcontrollers)
    TOOL_INSTALL="ST Link Tools";
    TOOL_SOURCE="Debian Repository";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install stlink-tools > /dev/null 2>&1;
    check_status_install;
    /usr/bin/logger 'Installed st-link-tools' -t 'Customizing Debian';

    # ESP32 tool
    TOOL_INSTALL="ESP Tool";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install esptool > /dev/null 2>&1;
    check_status_install;

    # Check that GitHub is reachable
    TEST_URL="github.com";
    check_connectivity_http;

    TOOL_ELF="flashrom";
    check_already_installed;
    if [ $TOOL_INSTALLED == False ]; then
        # flashrom
        TOOL_INSTALL="flashrom Prerequisites";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gcc meson ninja-build pkg-config python3-sphinx libcmocka-dev libpci-dev libusb-1.0-0-dev \
            libftdi1-dev libjaylink-dev > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="flashrom";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        TOOL_SOURCE="Source";
        cd $SOURCE_DIR;
        git clone https://github.com/whid-injector/flashrom-whidboard > /dev/null 2>&1;
        cd $SOURCE_DIR/flashrom-whidboard/ > /dev/null 2>&1;
        sudo mkdir -p /usr/local/sbin > /dev/null 2>&1;
        meson setup builddir > /dev/null 2>&1;
        meson compile -C builddir > /dev/null 2>&1;
        meson test -C builddir > /dev/null 2>&1;
        sudo meson install -C builddir > /dev/null 2>&1;
        check_status_install;
        ## Flashrom install in /usr/local/sbin which is not in PATH by default
        sudo cp $SCRIPT_DIR/files/flashrom.sh /etc/profile.d/ > /dev/null 2>&1;
        export PATH=$PATH:/usr/local/sbin;

        /usr/bin/logger 'Installed flashrom' -t 'Customizing Debian';
    fi

    TOOL_ELF="openocd";
    check_already_installed;
        
    if [ $TOOL_INSTALLED == False ]; then
        # openOCD
        cd $SOURCE_DIR;
        TOOL_INSTALL="openocd Prerequisites";
        TOOL_SOURCE="Debian Repository";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libtool pkg-config texinfo libusb-dev libusb-1.0-0-dev libftdi-dev autoconf automake make \
            git libftdi* libhidapi-hidraw0 > /dev/null 2>&1;
        check_status_install;
        sudo ldconfig > /dev/null 2>&1;

        TOOL_INSTALL="openocd";
        TOOL_SOURCE="Source";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
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
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install mingw-w64 gcc-mingw-w64-x86-64 libusb-1.0-0-dev > /dev/null 2>&1;
        check_status_install;
        sudo ldconfig > /dev/null 2>&1;

        TOOL_INSTALL="snander";
        TOOL_SOURCE="Source";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo mkdir -p /usr/bin > /dev/null 2>&1;
        git clone https://github.com/martinboller/SNANDer > /dev/null 2>&1;
        cd SNANDer > /dev/null 2>&1;
        ./build-for-linux.sh > /dev/null 2>&1;
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
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libjson-c-dev libhidapi-dev libusb-dev libusb-1.0-0-dev > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="ufsnorprog";
        TOOL_SOURCE="Source";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
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
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        git clone https://github.com/martinboller/BUSSide.git > /dev/null 2>&1;
        check_status_install;

        # Python stuff for BUSSide
        cd ./BUSSide/Client > /dev/null 2>&1;
        TOOL_INSTALL="BUSSide"
        VENV_NAME="$SOURCE_DIR/BUSSide/Client/venv"
        configure_venv;
        #source ~/$VENV_NAME/bin/activate > /dev/null 2>&1;  
        TOOL_INSTALL="BUSSide PIP Requirements"
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        pip install pyserial click esptool > /dev/null 2>&1;
        check_status_install;
    fi

    # Serial U-BOOT tool (Python)
    TOOL_INSTALL="sertack"
    TOOL_SOURCE="Source";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL from $TOOL_SOURCE\e[0m";
    if [ -d $RE_DIR/$TOOL_INSTALL ]; then
        cd $SOURCE_DIR;
    else
        cd $SOURCE_DIR;
        git clone https://github.com/martinboller/sertack.git > /dev/null 2>&1;
        check_status_install;

        VENV_NAME="$SOURCE_DIR/$TOOL_INSTALL/venv"
        configure_venv;
        #source ~/$VENV_NAME/bin/activate > /dev/null 2>&1;
        TOOL_INSTALL="sertack"
        TOOL_SOURCE="sertack sertack PIP Requirements";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL from $TOOL_SOURCE\e[0m";
        pip install pyserial > /dev/null 2>&1;
        check_status_install;
    fi
    /usr/bin/logger 'Installed sertack' -t 'Customizing Debian';
    
    # udev stuff to make devices work
    cd ~
    sudo ldconfig;
    sudo cp $SCRIPT_DIR/files/*.rules /etc/udev/rules.d/ > /dev/null 2>&1;
    sudo udevadm control --reload > /dev/null 2>&1;
    cd $SCRIPT_DIR;

    echo -e "\e[32m[+] install_hwhacktools() finished\n\e[0m";
    /usr/bin/logger 'install_hwhacktools() finished' -t 'Customizing Debian';
}

install_reversetools() {
    echo -e "\e[35m[*] install_reversetools()\e[0m";
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
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        #git clone https://github.com/ReFirmLabs/binwalk.git
        # binwalk require cargo and some other packages which may not be installed depending on config
        PATH="$HOME/.cargo/bin:$PATH";
        echo -e "\e[35m[*]\t └─ Checking cargo path\e[0m";
        export CARGO_PATH=$(grep '.cargo/bin' ~/.profile)

        if [ -n "$CARGO_PATH" ]; then
            echo -e "\e[35m[*]\t └─ Cargo path already configured\e[0m";
        else
            echo -e "\e[35m[*]\t └─ Adding cargo path to $HOME/.profile\e[0m";
            cat << ___EOF___ >> ~/.profile
# set PATH so it includes user's private .cargo/bin if it exists
if [ -d "\$HOME/.cargo/bin" ] ; then
    PATH="\$HOME/.cargo/bin:\$PATH"
fi
___EOF___
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install cargo build-essential libfontconfig1-dev liblzma-dev > /dev/null 2>&1;
        check_status_install;
        # update rust and cargo to latest stable
        TOOL_INSTALL="Latest stable rust";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sync;
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install rustup > /dev/null 2>&1; 
        rustup default stable > /dev/null 2>&1;
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
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
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
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
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
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        git clone https://github.com/martinboller/binwally.git > /dev/null 2>&1;
        check_status_install;

        # Python stuff for binwally
        TOOL_INSTALL="binwally";
        VENV_NAME="$RE_DIR/$TOOL_INSTALL/venv";
        configure_venv;
        
        TOOL_INSTALL="binwally PIP Requirements";
        TOOL_SOURCE="PIP Repository";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        pip install -r $RE_DIR/binwally/requirements.txt > /dev/null 2>&1;
        check_status_install;
    fi

    TOOL_INSTALL="DidierStevensSuite";
    TOOL_SOURCE="Source"
    if [ -d $RE_DIR/DidierStevensSuite ]; then
        cd $RE_DIR;
        check_status_install;
    else
        cd $RE_DIR;
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        git clone https://github.com/DidierStevens/DidierStevensSuite.git > /dev/null 2>&1;
        check_status_install;
        
        # Python stuff for DidierStevensSuite
        VENV_NAME="$RE_DIR/$TOOL_INSTALL/venv";
        configure_venv;

        TOOL_INSTALL="Didier Stevens Suite PIP Requirements";
        TOOL_SOURCE="PIP Repository";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        pip install -r $RE_DIR/DidierStevensSuite/requirements.txt > /dev/null 2>&1;
        check_status_install;
    fi   

    cd $SCRIPT_DIR;

    echo -e "\e[32m[+] install_reversetools() finished\n\e[0m";
    /usr/bin/logger 'install_reversetools() finished' -t 'Customizing Debian';
}

install_virtualization() {
    echo -e "\e[35m[*] install_virtualization()\e[0m";
    /usr/bin/logger 'install_virtualization()' -t 'Customizing Debian';

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;
    
    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="virsh";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-system-x86 libvirt-daemon-system libvirt-clients bridge-utils > /dev/null 2>&1;
    check_status_install;

    if [ "$QEMU_EMULATORS" == "Yes" ]; then
        # ARM
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="qemu emulator for 32-bit and 64-bit Arm CPUs";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-system-arm > /dev/null 2>&1;
        check_status_install;

        # PPC
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="qemu emulator for PowerPC machines";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-system-ppc > /dev/null 2>&1;
        check_status_install;

        # SPARC32
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="qemu emulator for Sparc32 Systems";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-system-sparc > /dev/null 2>&1;
        check_status_install;

        # RISC-V
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="qemu emulator for 32-bit and 64-bit RISC-V CPUs";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-system-riscv > /dev/null 2>&1;
        check_status_install;

        # s390x
        TOOL_SOURCE="Debian Repository";
        TOOL_INSTALL="qemu emulator for 64-bit IBM z/Architecture (s390x) mainframe systems";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install qemu-system-s390x > /dev/null 2>&1;
        check_status_install;
    fi
    
    # Configure user rights to kvm and libvirt
    sudo usermod -aG kvm $USER > /dev/null 2>&1;
    sudo usermod -aG libvirt $USER > /dev/null 2>&1;
    # enable libvirtd
    sudo systemctl enable --now libvirtd > /dev/null 2>&1;
    
    # Install Virtual Machine Manager. Manage Virtual machines outside of virsh
    TOOL_INSTALL="Virtual Machine Manager";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install virt-manager > /dev/null 2>&1;
    check_status_install;
    
    # Lightweight and quick way to manage simple virtual machines in Gnome
    TOOL_INSTALL="gnome-boxes";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install gnome-boxes > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m[+] install_virtualization() finished\n\e[0m";
    /usr/bin/logger 'install_virtualization() finished' -t 'Customizing Debian';
}

install_flatpak() {
    echo -e "\e[35m[*] install_flatpak()\e[0m";
    /usr/bin/logger 'install_flatpak()' -t 'Customizing Debian';

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_INSTALL="Flatpak Support"
    TOOL_SOURCE="Debian Repository";
    echo -e "\e[35m[*]\t └─ Installing flatpak and gnome software plugin\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install flatpak gnome-software-plugin-flatpak > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="flathub.org Repository";
    TOOL_SOURCE="Linux";
    echo -e "\e[35m[*]\t └─ Adding $TOOL_INSTALL\e[0m";
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m[+] install_flatpak() finished\n\e[0m";
    /usr/bin/logger 'install_flatpak() finished' -t 'Customizing Debian';
}

auto_activate_venv() {
    echo -e "\e[32m[+] auto_activate_venv()\n\e[0m";
    /usr/bin/logger 'auto_activate_venv()' -t 'Customizing Debian';

    # Shell config file for BASH
    shell_config_file=~/.bashrc;
    # Check if the script is already in the config file
    if grep -q "auto_activate_venv" "$shell_config_file"; then
        echo -e "\e[35m[*]\t └─ Auto-activation script already exists in $shell_config_file\e[0m"
        return
    else
        echo -e "\e[35m[*]\t └─ Adding auto-activation script to $shell_config_file\e[0m"
        cat >> "$shell_config_file" << '__EOF__'

# Auto activate virtual environment if in a project directory with a venv folder
function auto_activate_venv() {
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
    fi
}

# Trigger auto_activate_venv function on directory change
PROMPT_COMMAND="auto_activate_venv; $PROMPT_COMMAND"
__EOF__
    fi

    source $shell_config_file
    check_status_install;

    echo -e "\e[32m[+] auto_activate_venv() finished\n\e[0m";
    /usr/bin/logger 'auto_activate_venv() finished' -t 'Customizing Debian';
}

install_utils_flatpak() {
    echo -e "\e[35m[*] install_utils_flatpak()\e[0m";
    /usr/bin/logger 'install_utils_flatpak()' -t 'Customizing Debian';

    # Check that flathub.org is reachable
    TEST_URL="flathub.org";
    check_connectivity_http;

    # FP_DEVTOOLS_INSTALL
    if [ "$FP_DEVTOOLS_INSTALL" == "Yes" ]; then
        TOOL_INSTALL="vscodium";
        /usr/bin/logger 'installing Flatpak Devtools' -t 'Customizing Debian';
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.vscodium.codium > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="imhex";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL Hex Editor\e[0m";
        flatpak --assumeyes install net.werwolv.ImHex > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="bless";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL Hex Editor\e[0m";
        flatpak --assumeyes install com.github.afrantzis.Bless > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="ghidra";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install org.ghidra_sre.Ghidra > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="arduino.IDE2";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install cc.arduino.IDE2 > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="STM32CubeMX";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.st.STM32CubeMX > /dev/null 2>&1;
        check_fp_install;
    fi

    # FP_USERTOOLS_INSTALL
    if [ "$FP_USERTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak Usertools' -t 'Customizing Debian';

        TOOL_INSTALL="bitwarden.desktop";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.bitwarden.desktop > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="calibre";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.calibre_ebook.calibre > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="ungoogled_chromium";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install io.github.ungoogled_software.ungoogled_chromium > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="codecs";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.github.Eloston.UngoogledChromium.Codecs > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="mattermost";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.mattermost.Desktop > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="discord";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.discordapp.Discord > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="newsflash";
        echo -e "\e[35m[*]\t └─ installing RSS Reader $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install io.gitlab.news_flash.NewsFlash > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="signal";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL Desktop\e[0m";
        flatpak --assumeyes install org.signal.Signal > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="authenticator";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.belmoussaoui.Authenticator > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="zoom";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install us.zoom.Zoom > /dev/null 2>&1;
        check_fp_install;

        TOOL_INSTALL="remmina";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install org.remmina.Remmina > /dev/null 2>&1;
        check_fp_install;
        
        TOOL_INSTALL="anki";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install net.ankiweb.Anki > /dev/null 2>&1;
        check_fp_install;
        
        TOOL_INSTALL="draw.io";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.jgraph.drawio.desktop > /dev/null 2>&1;
        check_fp_install;
    fi
    
    # FP_ELECTRONICSTOOLS_INSTALL
    if [ "$FP_ELECTRONICSTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak Electronics Tools' -t 'Customizing Debian';

        TOOL_INSTALL="simulide";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install com.simulide.simulide > /dev/null 2>&1;
        check_fp_install;
    fi

    # FP_3DTOOLS_INSTALL
    if [ "$FP_3DTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak 3D Tools' -t 'Customizing Debian';
        
        TOOL_INSTALL="openscad";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install org.openscad.OpenSCAD > /dev/null 2>&1;
        check_fp_install;
        
        TOOL_INSTALL="wdaniau.fstl";
        echo -e "\e[35m[*]\t └─ installing $TOOL_INSTALL\e[0m";
        flatpak --assumeyes install io.github.wdaniau.fstl > /dev/null 2>&1;
        check_fp_install;
    fi

    echo -e "\e[32m[+] install_utils_flatpak() finished\n\e[0m";
    /usr/bin/logger 'install_utils_flatpak() finished' -t 'Customizing Debian';
}

install_gnome_extensions() {
    echo -e "\e[35m[*] install_gnome_extensions()\e[0m";
    /usr/bin/logger 'install_gnome_extensions()' -t 'Customizing Debian';

    # Default target directory to $SCRIPT_DIR or the current script's path
    local target_dir="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
    echo -e "\e[35m[*]\t └─ Processing GNOME extensions...\e[0m"

    TEST_URL="gnome.org";
    check_connectivity_http;

    cd $SCRIPT_DIR;
    # Ensure required tools are available
    if ! command -v unzip >/dev/null 2>&1; then
        echo -e "\e[31m[-]\tError: 'unzip' is required to process GNOME extensions.\e[0m"
        return 1
    fi

    # Dynamically enumerate all variables starting with GNOME_EXTENSION_
    for var_name in ${!GNOME_EXTENSION_@}; do
        # Ignore metadata suffix variables during variable iteration
        if [[ "$var_name" =~ _(URL|ID|UUID)$ ]]; then
            continue
        fi

        local var_val="${!var_name}"

        # Strict check: Skip unless explicitly set to "Yes"
        if [ "$var_val" != "Yes" ]; then
            continue
        fi

        # Extract name payload (e.g., GNOME_EXTENSION_DASH_TO_PANEL -> DASH_TO_PANEL)
        local raw_name="${var_name#GNOME_EXTENSION_}"
        local slug
        slug=$(echo -e "$raw_name" | tr '[:upper:]' '[:lower:]')

        local zip_file="$target_dir/${slug}.zip"
        local alt_zip_file="$target_dir/${slug//_/-}.zip"

        # Check if local zip exists under either naming convention
        if [ -f "$alt_zip_file" ] && [ ! -f "$zip_file" ]; then
            zip_file="$alt_zip_file"
        fi

        # Download if zip file does not exist locally in $SCRIPT_DIR
        if [ ! -f "$zip_file" ]; then
            local url_var="GNOME_EXTENSION_${raw_name}_URL"
            local id_var="GNOME_EXTENSION_${raw_name}_ID"
            
            local download_url="${!url_var}"
            local ext_id="${!id_var}"

            # Determine download URL
            if [ -z "$download_url" ] && [ -n "$ext_id" ]; then
                download_url="https://extensions.gnome.org/download-extension/${ext_id}.shell-extension.zip"
            fi

            if [ -n "$download_url" ]; then
                echo -e "\e[35m[*]\t └─ Downloading $slug to $target_dir\e[0m"
                if command -v curl >/dev/null 2>&1; then
                    curl -sSL "$download_url" -o "$zip_file"
                elif command -v wget >/dev/null 2>&1; then
                    wget -q "$download_url" -O "$zip_file"
                fi
            fi
        fi

        # Verify zip file exists and is non-empty
        if [ ! -f "$zip_file" ] || [ ! -s "$zip_file" ]; then
            echo -e "\e[31m[-]\tERROR: $var_name is 'Yes', but no valid package found or downloaded at '$zip_file'\e[0m"
            [ -f "$zip_file" ] && rm -f "$zip_file"
            continue
        fi

        echo -e "\e[35m[*]\t └─ Installing GNOME Extension: $slug\e[0m"

        # Extract UUID directly from metadata.json inside the zip
        local uuid
        uuid=$(unzip -p "$zip_file" metadata.json 2>/dev/null | sed -n 's/.*"uuid":[[:space:]]*"\([^"]*\)".*/\1/p')

        # Install via gnome-extensions CLI
        if gnome-extensions install --force "$zip_file" >/dev/null 2>&1; then
            if [ -n "$uuid" ]; then
                gnome-extensions enable "$uuid" > /dev/null 2>&1
                echo -e "\e[32m$PKG_COUNT\t[+] Successfully enabled ($uuid)\e[0m" | tee -a $SCRIPT_DIR/features.log;
            else
                echo -e "\e[3s5m$PKG_COUNT\t[*] Installed (Warning: Could not extract UUID to auto-enable)\e[0m" | tee -a $SCRIPT_DIR/features.log;
            fi
        else
            echo -e "\e[31m$PKG_COUNT\t[-] Failed to install $slug\e[0m"
        fi
        # increase Package Count for every package installed
        let "PKG_COUNT=$PKG_COUNT+1";
    done
    # Compile schemas
    TOOL_INSTALL="GNOME Extension Schemas";
    TOOL_SOURCE="GNOME";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo cp ~/.local/share/gnome-shell/extensions/*/schemas/*.gschema.xml /usr/share/glib-2.0/schemas/
    sudo glib-compile-schemas /usr/share/glib-2.0/schemas/    
    check_status_install;
    # Add the autostart to enable the extensions at first logon.
    enable_gnome_extensions_autostart;
    
    echo -e "\e[32m[+] install_gnome_extensions() finished\n\e[0m";
    /usr/bin/logger 'install_gnome_extensions() finished' -t 'Customizing Debian';
}

enable_gnome_extensions_autostart() {
    echo -e "\e[35m[*] enable_gnome_extensions_autostart()\e[0m";
    /usr/bin/logger 'enable_gnome_extensions_autostart()' -t 'Customizing Debian';

    TOOL_SOURCE="Autostart";
    TOOL_INSTALL="Enable Gnome Extensions at next logon for user: $USER";    
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
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
    echo -e "\e[32m$PKG_COUNT.\t[+] $TOOL_INSTALL successfully installed as autostart\e[0m" | tee -a $SCRIPT_DIR/features.log;
    let "PKG_COUNT=$PKG_COUNT+1";

    echo -e "\e[32m[+] enable_gnome_extensions_autostart() finished\n\e[0m";
    /usr/bin/logger 'enable_gnome_extensions_autostart() finished' -t 'Customizing Debian';
}

configure_nix() {
    echo -e "\e[35m[*] configure_nix()\e[0m";
    /usr/bin/logger 'configure_nix()' -t 'Customizing Debian';

    TEST_URL="debian.org";
    check_connectivity_ping;

    # curl, git and wget must always be there
    TOOL_INSTALL="cURL, git, and wget prerequisites for script";
    TOOL_SOURCE="Debian Repository";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install curl wget git unzip > /dev/null 2>&1;
    check_status_install;

    configure_grub;

    # NTFS and EXFAT Support
    install_proprietary_filesystems;

    # Serial and USB ports
    if [ "$CONFIGURE_SERIAL" == "Always" ]; then
        configure_serial_access;            
    fi

    echo -e "\e[32m[+] configure_nix() finished\n\e[0m";
    /usr/bin/logger 'configure_nix() finished' -t 'Customizing Debian';
}

configure_sudo() {
    echo -e "\e[35m[*] configure_sudo()\e[0m";
    /usr/bin/logger 'configure_sudo()' -t 'Customizing Debian';
    
    echo -e "\e[35m[*]\t └─ Adding user: $USER to group $SUDOGROUP\e[0m";
    echo -e "\e[35m[*]\t └─ You must provide the root password, then logout and rerun script\e[0m";
    echo -e "\e[35m[*]\t └─ $(su - root -c "/sbin/usermod -aG $SUDOGROUP $USER")\e[0m"
    echo -e "\e[35m[*]\t └─ $("/usr/bin/newgrp $SUDOGROUP")\e[0m"
        
    echo -e "\e[32m[+] configure_sudo() finished\n\e[0m";
    /usr/bin/logger 'configure_sudo() finished' -t 'Customizing Debian';
}

configure_apt_repositories() {
    echo -e "\e[35m[*] configure_apt_repositories()\e[0m";
    /usr/bin/logger 'configure_apt_respositories()' -t 'Customizing Debian';

    TOOL_INSTALL="apt repositories contrib, non-free, and non-free-firmware";
    TOOL_SOURCE="Debian Repository";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    
    export NON_FREE=$(grep -i "$TOOL_INSTALL" /etc/apt/sources.list)
    if [ -n "$NON_FREE" ]; then
        echo -e "\e[35m[*]\t └─ apt repositories contrib, non-free, and non-free-firmware already configured\e[0m";
        check_status_install;
    else
        echo -e "\e[35m[*]\t └─ adding contrib, non-free, and non-free-firmware repositories to sources.list\e[0m";
        sudo sed -ie "s/main/main contrib non-free non-free-firmware/" /etc/apt/sources.list
        sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1;
        check_status_install
        echo "#$TOOL_INSTALL" | sudo tee -a /etc/apt/sources.list > /dev/null 2>&1;
    fi

    echo -e "\e[32m[+] configure_apt_repositories() finished\n\e[0m";
    /usr/bin/logger 'configure_apt_respositories() finished' -t 'Customizing Debian';
}

configure_microsoft_apt_repository() {
    echo -e "\e[35m[*] configure_microsoft_apt_repository()\e[0m";
    /usr/bin/logger 'configure_microsoft_apt_respository()' -t 'Customizing Debian';

    # Check that microsoft.com is reachable
    TEST_URL="microsoft.com";
    check_connectivity_http;

    TOOL_INSTALL="Microsoft Linux Repo";
    TOOL_SOURCE="Microsoft Repo .deb package";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    cd $SCRIPT_DIR;
    echo -e "\e[35m[*]\t └─ adding packages-microsoft-prod.deb to sources.list\e[0m";
    # Download the Microsoft repository GPG keys
    echo -e "\e[35m[*]\t └─ Download the Microsoft repository GPG keys\e[0m";
    wget --user-agent="$USER_AGENT" -q https://packages.microsoft.com/config/debian/$VER/packages-microsoft-prod.deb -O $SCRIPT_DIR/ms.deb
    # Register the Microsoft repository GPG keys
    echo -e "\e[35m[*]\t └─ Register the Microsoft repository GPG keys\e[0m";
    sudo dpkg -i ms.deb  > /dev/null 2>&1;
    check_status_install;

    TOOL_INSTALL="Update Microsoft Repository information locally";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    # Update the list of packages after we added packages.microsoft.com
    sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m[+] configure_microsoft_apt_repository() finished\n\e[0m";
    /usr/bin/logger 'configure_microsoft_apt_respository() finished' -t 'Customizing Debian';
}

configure_serial_access() {
    echo -e "\e[35m[*] configure_serial_access()\e[0m";
    /usr/bin/logger 'configure_serial_access()' -t 'Customizing Debian';

    TOOL_SOURCE="usermod";
    TOOL_INSTALL="Adding user to group $SERIALGROUP";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    if id -nG "$USER" | grep -q "$SERIALGROUP"; then
        echo -e "\e[35m[*]\t └─ $USER already belongs to group: $SERIALGROUP. Nothing to do\e[0m"
        check_status_install;
    else
        TOOL_SOURCE="usermod";
        TOOL_INSTALL="Adding user to group $SERIALGROUP";
        sudo /sbin/usermod -aG $SERIALGROUP $USER > /dev/null 2>&1;
        check_status_install;
    fi

    # USB (plugdev)
    TOOL_INSTALL="Adding user to group $USBGROUP";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    if id -nG "$USER" | grep -q "$USBGROUP"; then
        echo -e "\e[35m[*]\t └─ $USER already belongs to group: $USBGROUP. Nothing to do\e[0m"
        check_status_install;
    else
        TOOL_SOURCE="usermod";
        TOOL_INSTALL="Adding user to group $USBGROUP";
        sudo /sbin/usermod -aG $USBGROUP $USER > /dev/null 2>&1;
        check_status_install;
    fi

    echo -e "\e[32m[+] configure_serial_access() finished\n\e[0m";
    /usr/bin/logger 'configure_serial_access() finished' -t 'Customizing Debian';
}

install_ms_powershell() {
    echo -e "\e[35m[*] c()\e[0m";
    /usr/bin/logger 'install_ms_powershell()' -t 'Customizing Debian';

    # Check that microsoft.com is reachable
    TEST_URL="microsoft.com";
    check_connectivity_http;

    TOOL_SOURCE="Microsoft Repo";
    # Install PowerShell
    TOOL_INSTALL="Microsoft PowerShell";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install powershell > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m[+] install_ms_powershell() finished\n\e[0m";
    /usr/bin/logger 'install_ms_powershell() finished' -t 'Customizing Debian';
}

configure_kb_shortcuts() {
    echo -e "\e[35m[*] configure_kb_shortcuts()\e[0m";
    /usr/bin/logger 'configure_kb_shortcuts()' -t 'Customizing Debian';

    TOOL_INSTALL="Keyboard Shortcuts";
    TOOL_SOURCE="gsettings";
    # Create custom keybindings myTerminal and myDisks
    echo -e "\e[35m[*]\t └─ Create custom keybindings\e[0m";
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myTerminal/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myDisks/']"
    check_status_install;

    TOOL_INSTALL="Custom key myTerminal";
    echo -e "\e[35m[*]\t └─ $TOOL_INSTALL\e[0m";
    # Provide a name for the custom key myTerminal
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myTerminal/ name 'Gnome-Term'
    check_status_install;

    TOOL_INSTALL="set keyboard combo to <Super> + t";    
    echo -e "\e[35m[*]\t └─ $TOOL_INSTALL\e[0m";
    # set keyboard combo to <Super> + t
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myTerminal/ binding '<super>t'
    check_status_install;

    TOOL_INSTALL="set gnome-terminal as command to run";
    echo -e "\e[35m[*]\t └─ $TOOL_INSTALL\e[0m";
    # set command to run
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myTerminal/ command '/usr/bin/gnome-terminal'
    check_status_install;

    TOOL_INSTALL="Custom key myDisks";
    echo -e "\e[35m[*]\t └─ $TOOL_INSTALL\e[0m";
    # Provide a name for the custom key myDisks
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myDisks/ name 'Gnome-Disks'
    check_status_install;

    TOOL_INSTALL="set keyboard combo to <Super> + d";
    echo -e "\e[35m[*]\t └─ $TOOL_INSTALL\e[0m";
    # set keyboard combo to <Super> + d
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myDisks/ binding '<super>d'
    check_status_install;

    TOOL_INSTALL="set gnome-disks as command to run";
    echo -e "\e[35m[*]\t └─ $TOOL_INSTALL\e[0m";
    # set command to run
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/myDisks/ command '/usr/bin/gnome-disks'
    check_status_install;

    if [ "$MENU_IS_COMPOSE" == "Yes" ]; then
        # configure menu key as compose
        TOOL_INSTALL="Menu Key is Compose Key";
        echo -e "\e[35m[*]\t └─ $TOOL_INSTALL\e[0m";
        gsettings set org.gnome.desktop.input-sources xkb-options "['menu:ctrl_shift_U', 'compose:menu']"
        check_status_install;
    fi
    
    echo -e "\e[32m[+] configure_kb_shortcuts() finished\n\e[0m";
    /usr/bin/logger 'configure_kb_shortcuts() finished' -t 'Customizing Debian';
}

configure_min_max_buttons() {
    echo -e "\e[35m[*] configure_min_max_buttons()\e[0m";
    /usr/bin/logger 'configure_min_max_buttons()' -t 'Customizing Debian';

    TOOL_INSTALL="Minimize and Maximize Buttons";
    echo -e "\e[35m[*]\t └─ Configuring GNOME Windows Manager to show minimize and maximize buttons\e[0m";
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
    check_status_install;

    echo -e "\e[32m[+] configure_min_max_buttons() finished\n\e[0m";
    /usr/bin/logger 'configure_min_max_buttons() finished' -t 'Customizing Debian';
}

install_golang() {
    echo -e "\e[35m[*] install_golang()\e[0m";
    /usr/bin/logger 'install_golang()' -t 'Customizing Debian';

    # Check that go.dev is reachable
    TEST_URL="go.dev";
    check_connectivity_http;

    cd $SCRIPT_DIR;
    TOOL_INSTALL="go"
    echo -e "\e[35m[*]\t └─ Downloading golang $GO_URL\e[0m";
    sudo mkdir -p /usr/local/ > /dev/null 2>&1;
    export GO_LATEST="$(curl --user-agent $USER_AGENT --silent $GO_URL | head -n1)" > /dev/null 2>&1;
    TOOL_SOURCE="$GO_LATEST linux-amd64 tarball";
    export GO_DOWNLOAD="https://go.dev/dl/$GO_LATEST.linux-amd64.tar.gz" > /dev/null 2>&1;
    wget --user-agent="$USER_AGENT" -q "$GO_DOWNLOAD" -O ./go.tar.gz > /dev/null 2>&1;
    echo -e "\e[35m[*]\t └─ Removing previous install of golang\e[0m";
    /usr/bin/logger 'Removing previous install of golang' -t 'Customizing Debian';
    sudo rm -rf /usr/local/go > /dev/null 2>&1;
    echo -e "\e[35m[*]\t └─ Opening and extracting golang tarball\e[0m";
    /usr/bin/logger 'Open and extract the golang tarball' -t 'Customizing Debian';
    sudo tar -C /usr/local -xzf go.tar.gz > /dev/null 2>&1;

    if test -f "/etc/profile.d/go_lang.sh"; then
        echo -e "\e[35m[*]\t └─ golang path already configured\e[0m";        
    else
        echo -e "\e[35m[*]\t └─ Configuring golang path\e[0m";        
        echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go_lang.sh > /dev/null 2>&1;
        sudo chmod 644 /etc/profile.d/go_lang.sh
    fi
    PATH=$PATH:/usr/local/go/bin
    check_install;

    echo -e "\e[32m[+] Installed $(/usr/local/go/bin/go version)\n\e[0m"
    /usr/bin/logger "Installed $(/usr/local/go/bin/go version)" -t 'Customizing Debian';
}

install_docker() {
    echo -e "\e[35m[*] install_docker()\e[0m";
    /usr/bin/logger 'install_docker()' -t 'Customizing Debian';

    # Check that debian.org is reachable
    TEST_URL="debian.org";
    check_connectivity_http;

    TOOL_SOURCE="Debian Repository";
    TOOL_INSTALL="docker";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install docker.io docker-compose > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m[+] install_docker() finished\n\e[0m";
    /usr/bin/logger 'install_docker() finished' -t 'Customizing Debian';
}

install_ytdlp() {
    echo -e "\e[35m[*] install_ytdlp()\n\e[0m";
    /usr/bin/logger 'install_ytdlp()' -t 'Customizing Debian';

    TOOL_INSTALL="yt-dlp";
    VENV_NAME=~/.venv;
    configure_venv;
    TOOL_INSTALL="yt-dlp";
    TOOL_SOURCE="PIP Repository";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    pip install yt-dlp > /dev/null 2>&1;
    check_status_install;

    echo -e "\e[32m[+] install_ytdlp() finished\n\e[0m";
    /usr/bin/logger 'install_ytdlp() finished' -t 'Customizing Debian';
}

install_volatility() {
    echo -e "\e[35m[*] install_volatility()\n\e[0m";
    /usr/bin/logger 'install_volatility()' -t 'Customizing Debian';

    if [ -d $RE_DIR/volatility3 ]; then
        TOOL_INSTALL="volatility3";
        TOOL_SOURCE="Source";
        cd $RE_DIR;
        check_status_install;
    else
        TOOL_INSTALL="volatility3";
        TOOL_SOURCE="Source";
        echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
        cd $RE_DIR;
        git clone https://github.com/volatilityfoundation/volatility3.git > /dev/null 2>&1;
        check_status_install;

        TOOL_INSTALL="volatility3";
        TOOL_SOURCE="Source";
        VENV_NAME=$RE_DIR/$TOOL_INSTALL/venv;
        configure_venv;

        cd volatility3;
        pip install -e ".[full]" > /dev/null 2>&1;
        check_status_install;
    fi

    echo -e "\e[35m[*] install_volatility() finished\n\e[0m";
    /usr/bin/logger 'install_volatility() finished' -t 'Customizing Debian';
}

create_jupyter_desktop_file() {
    echo -e "\e[35m[*] create_jupyter_desktop_file()\e[0m";
    /usr/bin/logger 'create_jupyter_desktop_file()' -t 'Customizing Debian';

    mkdir $HOME/.local/share/applications > /dev/null 2>&1;
    # icon
    mkdir $HOME/.local/share/icons > /dev/null 2>&1;
    cp $SCRIPT_DIR/files/jupyter-lab.png $HOME/.local/share/icons;

    cat << ___EOF___ >> ~/.local/share/applications/jupyter-lab.desktop
[Desktop Entry]
Type=Application
Name[en_GB]=Jupyter Lab
Name=Jupyter Lab
Comment[en_GB]=Start Jupyter Lab
Comment=Start and interact with Jupyter Lab from your browser
Keywords=Jupyter;Notebook;Lab
Exec=jupyter lab
# Translators: Do NOT translate or transliterate this text (this is an icon file name)!
Icon=$HOME/.local/share/icons/jupyter-lab.png
#org.gnome.Software
Terminal=false
Type=Application
StartupNotify=true
Categories=Jupyter;Lab;
___EOF___

    # Create unique desktop file and icon for jupyter
    sudo chmod 700 $HOME/.local/share/applications/jupyter-lab.desktop;
    sudo chown $USER $HOME/.local/share/applications/jupyter-lab.desktop;
    sudo chown $USER $HOME/.local/share/icons/jupyter-lab.png;

    echo -e "\e[35m[*] create_jupyter_desktop_file() finished\n\e[0m";
    /usr/bin/logger 'create_jupyter_desktop_file() finished' -t 'Customizing Debian';
}

create_flent_desktop_file() {
    echo -e "\e[35m[*] create_flent_desktop_file()\e[0m";
    /usr/bin/logger 'create_flent_desktop_file()' -t 'Customizing Debian';

    cat << ___EOF___ >> ~/.local/share/applications/flent.desktop
[Desktop Entry]
Type=Application
Name=Flent
Comment=The FLExible Network Tester
Exec=flent --gui %F
Icon=preferences-system-network
#applications-internet
Categories=Qt;Network;
Terminal=false
Keywords=network;bufferbloat;performance;testing;rrul;
MimeType=application/vnd.flent.data+json;application/vnd.flent.data.gzip;application/vnd.flent.data.bzip2;application/x-compressed-json;
___EOF___

    # Create unique desktop file for flent
    sudo chmod 700 $HOME/.local/share/applications/flent.desktop;

    echo -e "\e[35m[*] create_flent_desktop_file() finished\e[0m";
    /usr/bin/logger 'create_flent_desktop_file() finished' -t 'Customizing Debian';
}

show_errors() {
    # Show any errors logged in features.log
    # PKG_COUNT will already have counted up for the next package, so detract 1
    let "PKG_COUNT=$PKG_COUNT-1";
    COUNT_FEATURE_ERRORS=$(grep "ERROR:" $SCRIPT_DIR/features.log | wc -l) > /dev/null 2>&1;
    FEATURE_ERRORS=$(grep "ERROR:" $SCRIPT_DIR/features.log) > /dev/null 2>&1;
    if [[ $FEATURE_ERRORS ]]; then
        echo -e "\e[31m[-]\t$COUNT_FEATURE_ERRORS of $PKG_COUNT features errored out during installation\e[0m";
        echo -e "\e[31m[-]\tThese features failed installation:\r\n $FEATURE_ERRORS\e[0m";
        /usr/bin/logger "\e[31m$COUNT_FEATURE_ERRORS of $PKG_COUNT features errored out during installation\e[0m" -t 'Customizing Debian';        
    else
        echo -e "\e[32m[+]\tNo errors during install. $PKG_COUNT features installed\e[0m" | tee -a $SCRIPT_DIR/features.log;
        /usr/bin/logger "No errors during install. $PKG_COUNT features installed" -t 'Customizing Debian';
    fi
    echo -e "\e[35m\n[*]Finished installation of the preset: $PRESET_SELECTED\n\e[0m" | tee -a $SCRIPT_DIR/features.log; 
}

cleanup() {
    echo -e "\e[35m[*] cleanup()\e[0m";
    /usr/bin/logger 'cleanup()' -t 'Customizing Debian';

    # update flatpaks
    TOOL_SOURCE="Flatpak";
    TOOL_INSTALL="updates";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL for $TOOL_SOURCE\e[0m";
    flatpak --assumeyes update > /dev/null 2>&1;
    check_status_install;

    TOOL_SOURCE="Linux";
    TOOL_INSTALL="Cleanup";
    echo -e "\e[35m[*]\t └─ Installing $TOOL_INSTALL\e[0m";
    rm $SCRIPT_DIR/*.zip > /dev/null 2>&1;
    rm $SCRIPT_DIR/*.gz > /dev/null 2>&1;
    rm $SCRIPT_DIR/*.deb > /dev/null 2>&1;
    sudo apt -y autoremove --purge > /dev/null 2>&1;
    check_status_install;
    sudo apt autoclean > /dev/null 2>&1;

    echo -e "\e[32m[+] cleanup() finished\n\e[0m";
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
        echo -e "\e[32m[+]\t$USER already belongs to group: $SUDOGROUP, installation will continue using sudo\e[0m"
        # Ensuring that sudo group membership is active.
        # /usr/bin/newgrp $SUDOGROUP;
        # Get sudo password
        echo -e "\e[35m[*] Sudo password needed"
        echo -e "$(sudo echo)\e[0m"

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

        install_gnome_extensions;

        # Gnome show minimize and maximize buttons
        if [ "$MM_BUTTONS_CONFIGURE" == "Yes" ]; then
            configure_min_max_buttons;
        fi

        #enable_gnome_extensions_autostart;

        # Flatpak
        if [ "$FLATPAK_UTILS" == "Always" ]; then
            install_flatpak;
            install_utils_flatpak;
        fi

        # Debian APT packages
        if [ "$APT_UTILS" == "Always" ]; then
            install_utils_apt;
        fi

        # Install YT-DLP
        if [ "$YTDLP_INSTALL" == "Yes" ]; then
            install_ytdlp;
        fi

        # Install Jupyterlab
        if [ "$JUPYTER_INSTALL" == "Yes" ]; then
            install_jupyterlab;
        fi

        # Install Volatility Memory Forensics V3
        if [ "$VOLATILITY_INSTALL" == "Yes" ]; then
            install_volatility;
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
    
        # Microsoft Debian Packages repo
        if [ "$MICROSOFT_APT" == "Yes" ]; then
            configure_microsoft_apt_repository;
        fi

        # Microsoft PowerShell for Linux
        if [ "$PWSH_INSTALL" == "Yes" ]; then
            configure_microsoft_apt_repository;
            install_ms_powershell;
        fi

        # final cleanup
        cleanup;
        show_errors;

        # Show finishing message
        do_outro;
        
    # Cannot sudo
    else
        echo -e "\e[31m[-]\t$USER does not belong to group$SUDOGROUP, please provide root password\e[0m"
        configure_sudo;
        echo -e "\e[31m[-]\tNow rerun this script\e[0m"
    fi

    /usr/bin/logger 'main() finished' -t 'Customizing Debian';
    read -p "Do You want to reboot now? (y/n)" DO_REBOOT;
    printf -v DO_IT_NOW "%.1s" "${DO_REBOOT^^}"
    if [ "$DO_IT_NOW" == "Y" ]; then
        sync;
        systemctl reboot;
    else
        echo -e "\e[31m[-]\tYou should reboot soon, or at least logout/login to enable GNOME Extensions\e[0m"
    fi
}

main

exit 0