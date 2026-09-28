# myDebian
Configuring Gnome Desktop and installing different sets of applications on Debian 13 Trixie.
Application categories are:
- GNOME Desktop
- Virtualization
- Forensics and Networking
- Hacking & Reverse Engineering
- Development
- User Tools (Productivity)
- Microsoft Integration

But have a look by starting installmenu.py on the command line.

## Categories
### Base System & Nix Infrastructure
- **Core Retrieval & Versioning Utilities**: curl, wget, git (configured during configure_nix)
- Package Management 
### Infrastructure
- trixie-backports repository configurations and APT index updates (install_backports).
### System Utilities (SYSTOOLS_INSTALL)
- **Archive & Extraction Utilities**: unzip, zip, p7zip-full, tar (required prior to GNOME extension extraction).
- **System - Diagnostics & Desktop Management**: rsync, tree, htop, dconf-cli, gsettings-desktop-schemas.
- **Development Tools (install_devtools)**: Build Tools & Compilers: build-essential, gcc, g++, make, cmake.
- **Language Runtimes & Packaging**: python3, python3-pip, python3-venv.
### Network Diagnostics & Security (install_networktools)
- Packet Analysis & Diagnostics: iputils-ping, net-tools, dnsutils, traceroute, nmap, wireshark, tcpdump, ncat.
### Microsoft Integration (PWSH_INSTALL / MICROSOFT_APT)
- APT Sources: Microsoft GPG keyring and repository source definitions (packages.microsoft.com).
- Automated Shell Envs: PowerShell (pwsh).
### Desktop Environment & GNOME Extensions
- **GNOME Extensions**
  - Dash to Panel: dash-to-panel@jderose9.github.com (extracted via unzip from extension source).
  - Caffeine: caffeine@patapon.info (extracted via unzip from extension source).
- **Shell Customizations**
  - Dynamic Panel Length Configuration (GNOME_PANEL_LENGTH_DYNAMIC).
  - Startup Overview Hider (GNOME_HIDE_OVERVIEW).
- **Keyboard Customizations**
  - Multimedia Hotkeys & - Keyboard Binds (MM_BUTTONS_CONFIGURE, KB_SHORTCUTS).
  - Compose Key Mapping (MENU_IS_COMPOSE).

### Design principles:
  - Controlled by .env file that can now be managed through installmenu.py
  - Installs and configures flatpak + the Debian contrib and non-free repositories
  - Installs some flatpak utils, including BitWarden and VSCodium
  - Installs some Networking, Forensics, Development, and System utilities
  - Install Hardware Hacking Tools
  - Configures GNOME to my liking, adding 2 extensions


## Latest changes ##

### 2026-09-19
- Install Menu Python simplified
- Checks connectivity with ping (icmp) first, then https with cURL.
- More logging in features.log
- STM32CubeMX installation
- JupyterLab
- And more

### 2026-09-13
- Installing pulseview from source
- Installing tools for Hardware Hacking (snander, flashrom, ufsprog, openocd, and stlink-tools and esp32tool)
- Installing tools for Reverse Engineering (Ghidra, binwalk, binwally, flashfinder)
- additional checking of installation success or failure
- Python menu tool to configure .env file easily (turn features on/off)
- enumerating installed features on first screen

### 2026-08-06
- Wireshark installs silently.
- Added requirements for Pulseview, which require Trixie backports.
- Builds and installs latest version of hashcat directly from github.
- Also added cmatrix, sl, figlet, lolcat, and cowsay just for the fun of it.
- All of the above set to "Yes" in .env file, don't forget to adjust to your references!

### 2026-01-04
 - Installing NTFS support

### 2024-01-03 - Go and Serial Ports ###
 - Installing golang
 - Configure access to serial port
 - sudo password message.

### 2024-01-02 - Dash to panel ###
 - Installing the Dash-to-Panel Gnome Extension
 - Adding minimize and maximize buttons to windows
 - Can install Powershell (default No in .env for libre reasons)
 - Added granularity in selection of categories of packages installed
 - **Note**: Microsoft Packages Repo for Debian does not contain Powershell, see MICROSOFT_APT_WORKAROUND in .env and shell script
 
### 2024-01-01 - Initial version ###
- Adds the currently logged on user to the sudo group (if necessary)
- Installing Flatpak, Gnome Software Flatpak plugin, and adds flathub repository.
- Installs flatpaks: VS-Codium; BitWarden; Calibre; UngoogledChromium; UngoogledChromium-Codecs; Mattermost; Discord; FluentReader; Signal.
- Several Debian APT-packages in the following categories: Network Tools, Forensics Tools, Systems Tools, and User Tools.
- Adds the contrib, non-free, and firmware-non-free debian repositories.
- Keyboard shortcuts for gnome-terminal (Super + t) and gnome-disks (Super + d)


### Usage
**Clone the repo**
$ git clone https://github.com/martinboller/myDebian.git

**cd into the directory**
$ cd myDebian/

**Edit .env and select what to install/configure**
$ python3 installmenu.py
$ vi .env

**Make sure You're in the sudo group**
The script should do it for you, but..
$ su root -c /sbin/adduser $USER sudo
(reboot if you weren't already in that group)

**Then run the shell script**
$ ./customize.sh
