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
    echo -e "\e[1;35mInstall Backports? $BACKPORTS_INSTALL\e[0m"
    echo -e "\e[1;35mInstall Requirements for Pulseview? $PULSEVIEW_INSTALL\e[0m"
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
    /usr/bin/logger "Operating System: $OS Version: $VER: $CODENAME" -t 'Customizing Debian';

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
    sudo apt-get -qq -y install ntfs-3g > /dev/null 2>&1;
    sudo apt-get -qq -y install exfat-fuse exfatprogs > /dev/null 2>&1;
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
        echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
        sudo apt-get -y -qq install wireshark > /dev/null 2>&1;
        sudo usermod -a -G wireshark $USERNAME > /dev/null 2>&1;
        sudo apt-get -y -qq install ipcalc-ng tcpdump nmap ncat ngrep ethtool aircrack-ng whois dnsutils > /dev/null 2>&1;
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
        sudo apt-get -y -qq install screen > /dev/null 2>&1;
    fi

    # USERTOOLS_INSTALL
    if [ "$USERTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing User tools from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing user utils and other tools\e[0m";
        sudo apt-get -y -qq install curl transmission-gtk vlc ffmpeg libavcodec-extra default-jdk sshpass rclone rclone-browser figlet lolcat cowsay sl cmatrix > /dev/null 2>&1;
    fi

    # DEVTOOLS_INSTALL
    if [ "$DEVTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Development tools from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing development tools\e[0m";
        sudo apt-get -y -qq install git devscripts build-essential gnupg2 dirmngr --install-recommends > /dev/null 2>&1;
        # Some additional helpful tools
        sudo apt-get -y -qq install gawk xxd vbindiff --install-recommends > /dev/null 2>&1;
        # Required to build Proxmark and others
        sudo apt-get -qq -y install --install-recommends ca-certificates pkg-config libreadline-dev gcc-arm-none-eabi libnewlib-dev qtbase5-dev libbz2-dev liblz4-dev libbluetooth-dev libssl-dev cmake > /dev/null 2>&1;
    fi
    
    # PYTHON_INSTALL
    if [ "$PYTHON_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Python stuff from Debian repository ' -t 'Customizing Debian';
        echo -e "\e[36m .... Installing Python tools\e[0m";   
        sudo apt-get -y -qq install python3 python3-pip python3-setuptools python3-gnupg python3-venv libpython3-dev > /dev/null 2>&1;
    fi

    echo -e "\e[32m - install_utils_apt() finished\e[0m";
    /usr/bin/logger 'install_utils_apt() finished' -t 'Customizing Debian';
    
    # Trixie backports
    if [ "$BACKPORTS_INSTALL" == "Yes" ]; then
        sudo tee /etc/apt/sources.list.d/debian-backports.sources << __EOF__
Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: trixie-backports
Components: main
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
__EOF__
    sync;
    sudo apt update > /dev/null 2>&1;
    fi
    
    # HASHCAT installation
    # Note: depends on devtools being installed
    if [ "$HASHCAT_INSTALL" == "Yes" ]; then
        sudo apt-get -qq -y install libbz2-dev libssl-dev libncurses5-dev libffi-dev libreadline-dev libsqlite3-dev liblzma-dev > /dev/null 2>&1;
        curl https://pyenv.run | bash > /dev/null 2>&1;
        mkdir -p ~/git > /dev/null 2>&1;
        cd ~/git/
        git clone https://github.com/hashcat/hashcat.git > /dev/null 2>&1;
        cd hashcat
        make clean && make > /dev/null 2>&1;
        sudo make install > /dev/null 2>&1;
        sync;
        cd ~
    fi
}
install_pulseview() {
    echo -e "\e[32m - install_pulseview()\e[0m";
    /usr/bin/logger 'install_pulseview()' -t 'Customizing Debian';

    # Installing Debian Package
    #sudo apt-get -y -qq install pulseview > /dev/null 2>&1;
   
    # Installing prerequisites
    sudo apt-get -qq -y install autoconf autoconf-archive automake sdcc libtool libboost-all-dev asciidoctor libzip-dev ruby-dev > /dev/null 2>&1;
    sudo apt-get -qq -y install pkg-config libglib2.0-dev libglib2.0-dev libzip5 libtirpc-dev libserialport0 libvisa0 libvisa-dev \
        libusb-1.0-0 libusb-1.0-0-dev libhidapi-hidraw0 libhidapi-libusb0 libftdi1-dev python3-pyvisa-py libieee1284-3-dev \
        libgio-2.0-dev libghc-nettle-dev check doxygen graphviz swig libglibmm-2.68-dev python-setuptools-doc python-gi-dev \
        python3-numpy python3-numpy-dev python3-doxypypy ruby openjdk-25-jdk > /dev/null 2>&1;
    sudo apt-get -qq -y install qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools qttools5-dev-tools qttools5-dev libqt5svg5-dev > /dev/null 2>&1;
    sudo apt-get -qq -y install gpib-user-tools python3-gpib libgpib0 libgpib-dev libhidapi-dev > /dev/null 2>&1;
    sudo apt-get -qq -y install rpcbind libtirpc3 libavahi-client-dev check > /dev/null 2>&1;
    
    cd $SOURCE_DIR;
    # Install fork of libsigrokdecode
    # Note: Depending on trixie backports
    git clone git://sigrok.org/libsigrokdecode > /dev/null 2>&1;
    cd libsigrokdecode > /dev/null 2>&1;
    ./autogen.sh > /dev/null 2>&1;
    ./configure > /dev/null 2>&1;
    make clean > /dev/null 2>&1;
    make > /dev/null 2>&1;
    sudo make install > /dev/null 2>&1;

    # Install fork of libsigrok with support for SiPEED SLogic 8 and 16
    cd $SOURCE_DIR;
    git clone -b slogic-dev https://github.com/sipeed/libsigrok > /dev/null 2>&1;
    #git clone git://sigrok.org/libsigrok > /dev/null 2>&1;
    cd libsigrok > /dev/null 2>&1;
    ./autogen.sh > /dev/null 2>&1;
    ./configure > /dev/null 2>&1;
    make clean > /dev/null 2>&1;
    make > /dev/null 2>&1;
    sudo make install > /dev/null 2>&1;

    # Install fork of libsigrok with support for SiPEED SLogic 8 and 16
    cd $SOURCE_DIR;
        git clone git://sigrok.org/sigrok-cli > /dev/null 2>&1;
    cd sigrok-cli > /dev/null 2>&1;
    ./autogen.sh > /dev/null 2>&1;
    ./configure > /dev/null 2>&1;
    make clean > /dev/null 2>&1;
    make > /dev/null 2>&1;
    sudo make install > /dev/null 2>&1;

    # Install fork of libsigrok with support for SiPEED SLogic 8 and 16
    cd $SOURCE_DIR;
    git clone git://sigrok.org/pulseview > /dev/null 2>&1;
    cd pulseview > /dev/null 2>&1;
    cmake .  > /dev/null 2>&1;
    #make clean > /dev/null 2>&1;
    make > /dev/null 2>&1;
    sudo make install > /dev/null 2>&1;
    sudo ldconfig;
    # Back home to where install script is running from
    cd $SCRIPT_DIR

    echo -e "\e[32m - install_pulseview() finished\e[0m";
    /usr/bin/logger 'install_pulseview() finished' -t 'Customizing Debian';
}


install_hwhacktools() {
    echo -e "\e[32m - install_hwhacktools()\e[0m";
    /usr/bin/logger 'install_hwhacktools()' -t 'Customizing Debian';
    ## Hardware Hacking Tools for Debian
    # Directory for source-code (declared in .env)
    mkdir -p $SOURCE_DIR; 

    #ST-LINK (STM microcontrollers)
    sudo apt-get -y -qq install stlink-tools > /dev/null 2>&1;
    /usr/bin/logger 'Installed st-link-tools' -t 'Customizing Debian';
    
    # flashrom
    sudo apt-get -y -qq install gcc meson ninja-build pkg-config python3-sphinx libcmocka-dev libpci-dev libusb-1.0-0-dev libftdi1-dev libjaylink-dev > /dev/null 2>&1;
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
    sync
    /usr/bin/logger 'Installed flashrom' -t 'Customizing Debian';

    # openOCD
    cd $SOURCE_DIR;
    sudo apt-get -y -qq install libtool pkg-config texinfo libusb-dev libusb-1.0-0-dev libftdi-dev autoconf automake make git libftdi* libhidapi-hidraw0 > /dev/null 2>&1;
    sudo ldconfig > /dev/null 2>&1;
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
    /usr/bin/logger 'Installed openOCD' -t 'Customizing Debian';

    # SNANDER
    cd $SOURCE_DIR;
    sudo apt-get -y -qq install mingw-w64 gcc-mingw-w64-x86-64 libusb-1.0-0-dev > /dev/null 2>&1;
    sudo ldconfig > /dev/null 2>&1;
    sudo mkdir -p /usr/bin > /dev/null 2>&1;
    git clone https://github.com/martinboller/SNANDer > /dev/null 2>&1;
    cd SNANDer > /dev/null 2>&1;
    ./build-for-linux.sh > /dev/null 2>&1;
    sync;
    sudo cp ./build/snander /usr/bin/ > /dev/null 2>&1;
    /usr/bin/logger 'Installed snander' -t 'Customizing Debian';

    # ufprog
    cd $SOURCE_DIR;
    sudo apt-get -y -qq install libjson-c-dev libhidapi-dev libusb-dev libusb-1.0-0-dev > /dev/null 2>&1;
    git clone https://github.com/whid-injector/ufprog > /dev/null 2>&1;
    cd ufprog > /dev/null 2>&1;
    cmake -DCMAKE_BUILD_TYPE=None -DBUILD_PORTABLE=OFF -DCMAKE_INSTALL_PREFIX=/usr -B build > /dev/null 2>&1;
    cd build > /dev/null 2>&1;
    make > /dev/null 2>&1;
    sudo make install > /dev/null 2>&1;
    sudo cp -r /usr/share/ufprog/ /usr/lib/ > /dev/null 2>&1;
    /usr/bin/logger 'Installed ufprog' -t 'Customizing Debian';

    # BUSSide
    cd $SOURCE_DIR;
    git clone https://github.com/martinboller/BUSSide.git > /dev/null 2>&1;
    sudo apt-get -y -qq install esptool > /dev/null 2>&1;
    python3 -m venv ~/.BUSSide > /dev/null 2>&1;
    source ~/.BUSSide/bin/activate > /dev/null 2>&1;
    cd ./BUSSide/Client > /dev/null 2>&1;
    pip install -r requirements.txt > /dev/null 2>&1;
    
    cd $SOURCE_DIR;
    git clone https://github.com/martinboller/sertack.git > /dev/null 2>&1;
    sudo apt-get -y -qq install python3-serial > /dev/null 2>&1;

    # udev stuff to make devices work
    cd ~
    sudo ldconfig;
    sudo cp $SCRIPT_DIR/files/*.rules /etc/udev/rules.d/ > /dev/null 2>&1;
    sudo udevadm control --reload > /dev/null 2>&1;
    echo -e "\e[32m - install_hwhacktools() finished\e[0m";
    /usr/bin/logger 'install_hwhacktools() finished' -t 'Customizing Debian';
}

install_flatpak() {
    echo -e "\e[32m - install_flatpak()\e[0m";
    /usr/bin/logger 'install_flatpak()' -t 'Customizing Debian';

    echo -e "\e[36m .... Installing flatpak and gnome software plugin\e[0m";
    sudo apt-get -qq -y install flatpak gnome-software-plugin-flatpak > /dev/null 2>&1;
    echo -e "\e[36m .... Adding flathub repository\e[0m";
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1;
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
        echo -e "\e[36m .... installing Ghidra\e[0m";
        flatpak --assumeyes install org.ghidra_sre.Ghidra > /dev/null 2>&1;
        echo -e "\e[36m .... installing Arduino IDE v2\e[0m";
        flatpak --assumeyes install cc.arduino.IDE2 > /dev/null 2>&1;
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
        echo -e "\e[36m .... installing Remmina\e[0m";
        flatpak --assumeyes install org.remmina.Remmina > /dev/null 2>&1;
        echo -e "\e[36m .... installing Anki\e[0m";
        flatpak --assumeyes install net.ankiweb.Anki > /dev/null 2>&1;
    fi
    
    # FP_ELECTRONICSTOOLS_INSTALL
    if [ "$FP_ELECTRONICSTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak Electronics Tools' -t 'Customizing Debian';
        echo -e "\e[36m .... installing Electronic Circuit Simulator\e[0m";
        flatpak --assumeyes install com.simulide.simulide > /dev/null 2>&1;
    fi

    # FP_3DTOOLS_INSTALL
    if [ "$FP_3DTOOLS_INSTALL" == "Yes" ]; then
        /usr/bin/logger 'installing Flatpak 3D Tools' -t 'Customizing Debian';
        echo -e "\e[36m .... installing openSCAD\e[0m";
        flatpak --assumeyes install org.openscad.OpenSCAD > /dev/null 2>&1;
        echo -e "\e[36m .... installing Fast STL Viewer\e[0m";
        flatpak --assumeyes install io.github.wdaniau.fstl > /dev/null 2>&1;
    fi


    echo -e "\e[32m - install_utils_flatpak() finished\e[0m";
    /usr/bin/logger 'install_utils_flatpak() finished' -t 'Customizing Debian';
}

install_gnome_dash_to_panel() {
    echo -e "\e[32m - install_gnome_dash_to_panel()\e[0m";
    /usr/bin/logger 'install_gnome_dash_to_panel()' -t 'Customizing Debian';

    echo -e "\e[36m .... installing the Dash-to-Panel Gnome Extension\e[0m";
    # Requires log out then logon
    sudo apt-get -y -qq install gnome-shell-extension-dash-to-panel > /dev/null 2>&1;
    DASH_UUID="$(gnome-extensions list | grep -i dash)"

    echo -e "\e[32m - install_gnome_dash_to_panel() finished\e[0m";
    /usr/bin/logger 'install_gnome_dash_to_panel() finished' -t 'Customizing Debian';
}

install_gnome_caffeine() {
    echo -e "\e[32m - install_gnome_caffeine()\e[0m";
    /usr/bin/logger 'install_gnome_caffeine()' -t 'Customizing Debian';

    echo -e "\e[36m .... installing the caffeine Gnome Extension\e[0m";
    # Requires log out then logon
    cd $SCRIPT_DIR;
    wget https://extensions.gnome.org/extension-data/caffeinepatapon.info.v60.shell-extension.zip > /dev/null 2>&1; 
    export CAF_UUID=$(unzip -c $SCRIPT_DIR/caffeinepatapon.info.v60.shell-extension.zip metadata.json | grep uuid | cut -d \" -f4) > /dev/null 2>&1;
    echo -e "\e[36m .... Installing the Dash-to-Panel Gnome Extension $CAF_UUID\e[0m";
    gnome-extensions install $SCRIPT_DIR/caffeinepatapon.info.v60.shell-extension.zip > /dev/null 2>&1;
     
    echo -e "\e[32m - install_gnome_caffeine() finished\e[0m";
    /usr/bin/logger 'install_gnome_caffeine() finished' -t 'Customizing Debian';
}

enable_gnome_extensions() {
    echo -e "\e[32m - enable_gnome_extensions()\e[0m";
    /usr/bin/logger 'enable_gnome_extensions()' -t 'Customizing Debian';
    
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

    echo -e "\e[32m - enable_gnome_extensions() finished\e[0m";
    /usr/bin/logger 'enable_gnome_extensions() finished' -t 'Customizing Debian';
    
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
    sudo apt-get -qq update > /dev/null 2>&1; 
    
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
    sudo apt-get -qq update > /dev/null 2>&1;

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
    sudo apt-get -qq -y install powershell > /dev/null 2>&1;

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

    cd $SCRIPT_DIR;
    echo -e "\e[1;36m .... Downloading golang $GO_URL\e[0m";
    echo -e "\e[1;36m .... Downloading golang $GO_URL\e[0m";
    mkdir -p /usr /local/ > /dev/null 2>&1;
    export GO_LATEST="$(curl $GO_URL | head -n1)" > /dev/null 2>&1;
    export GO_DOWNLOAD="https://go.dev/dl/$GO_LATEST.linux-amd64.tar.gz" > /dev/null 2>&1;
    wget -q "$GO_DOWNLOAD" -O ./go.tar.gz > /dev/null 2>&1;
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
        echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go_lang.sh  > /dev/null 2>&1;
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

    # Dir where script is running
    export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    # Configure variables from .env-file
    configure_env;

    if id -nG "$USERNAME" | grep -q "$SUDOGROUP"; then
        echo -e "\e[32m - $USERNAME already  belongs to group: $SUDOGROUP, installation will continue using sudo\e[0m"
        # Ensuring that sudo group membership is active.
        # /usr/bin/newgrp $SUDOGROUP;
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

        if [ "$GNOME_SETTINGS" == "Yes" ]; then
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

       # Install HWHack Tools
        if [ "$HWHACKTOOLS_INSTALL" == "Yes" ]; then
            install_hwhacktools;
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

        if [ "$PULSEVIEW_INSTALL" == "Yes" ]; then
            install_pulseview;
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
