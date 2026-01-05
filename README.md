# myBookworm
Install some basics on Debian 12 and 13

### Design principles:
  - Controlled by .env file
  - Installs and configures flatpak + the Debian contrib and non-free repositories
  - Installs some flatpak utils, including BitWarden and VSCodium
  - Installs some Networking, Forensics, Development, and System utilities

## Latest changes ##
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
 - **Note**: Microsoft Packages Repo for Bookworm does not contain Powershell, see MICROSOFT_APT_WORKAROUND in .env and shell script
 
### 2024-01-01 - Initial version ###
- Adds the currently logged on user to the sudo group (if necessary)
- Installing Flatpak, Gnome Software Flatpak plugin, and adds flathub repository.
- Installs flatpaks: VS-Codium; BitWarden; Calibre; UngoogledChromium; UngoogledChromium-Codecs; Mattermost; Discord; FluentReader; Signal.
- Several Debian APT-packages in the following categories: Network Tools, Forensics Tools, Systems Tools, and User Tools.
- Adds the contrib, non-free, and firmware-non-free debian repositories.
- Keyboard shortcuts for gnome-terminal (Super + t) and gnome-disks (Super + d)


### Usage
**Clone the repo**
$ git clone https://github.com/martinboller/myBookworm.git

**cd into the directory**
$ cd /myBookworm/

**Edit .env and select what to install/configure**
$ vi .env

**Then run the shell script**
$ ./customize.sh
