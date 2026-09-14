# myDebian
Install some basics on Debian 12 and 13

### Design principles:
  - Controlled by .env file that can now be managed through installmenu.py
  - Installs and configures flatpak + the Debian contrib and non-free repositories
  - Installs some flatpak utils, including BitWarden and VSCodium
  - Installs some Networking, Forensics, Development, and System utilities
  - Install Hardware Hacking Tools
  - Configures GNOME to my liking, adding 2 extensions

## Latest changes ##

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
