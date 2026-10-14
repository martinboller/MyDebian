# myDebian
Configuring Gnome Desktop and installing different sets of applications on Debian 13 Trixie.
Application categories are:
- GNOME Desktop
- Virtualization
- Forensics and Networking
- Hacking & Reverse Engineering
- Hardware Hacking
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
### Hardware Hacking & Embedded Tools
- **Signal Analysis & Logic Probing**: PulseView (compiled/installed from source via backports).
- **Flash & EEPROM Programming**: flashrom, ufsprog.
- **Microcontroller & Debug Interfaces**: openocd, stlink-tools, esptool.
- **Embedded & Serial Utilities**: snander, serial port permissions configuration.
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

---

## 🔌 Hardware Hacking & Embedded Toolchain

The environment features tools tailored for hardware reverse engineering, embedded systems debugging, microcontroller flashing, and logic analysis. 

### Included Tooling & Capabilities
* **Logic Analysis**: **PulseView** (built from source leveraging Debian backports) for visual protocol decoding (SPI, I2C, UART) via logic analyzers.
* **Flash & Firmware Manipulation, On-Chip Debugging & Programming**: 
  * `flashrom` for reading, writing, erasing, and verifying flash chips (SPI/BIOS/EEPROM).
  * `ufsprog` for UFS storage interface operations (ufsnandprog, ufsnandtest, ufsnorprog, ufsnortest). 
  * `openocd` (Open On-Chip Debugger) supporting JTAG/SWD debugging.
  * `stlink-tools` for flashing and interacting with STM32 microcontrollers.
  * `esptool` for flashing Espressif ESP32-series chips (such as ESP32-S3 devices).
  * `snander` Serial Nor/nAND/Eeprom programmeR 
  * `sertack` A Python utility for embedded device security auditing, firmware extraction, and hardware debugging.
* **Serial Port Access**: Automated user group configuration granting non-root access to serial ports.
 
### Supported Boards & Hardware Interfaces
The environment and underlying tool configurations provide support for a variety of target boards and debug probes:
* **WHIDBoard**: The ultimate tool-suite for Hardware Hackers. It is designed to act as the perfect Swiss-Army-Knife for hacking any (I)IoT & Embedded devices. Thanks to its core controller (a.k.a. BRUSCHETTAPRO) it can support the interaction with multiple protocols (i.e. UART, SPI, I2C, JTAG & SWD) as well as different Logic Levels (i.e. 1.8V, 2.5V, 3.3V and the VREF of the target itself).
* **Bruschetta Board**: Multi-Protocol Swiss-Army-Knife.
* **BUSSide**: An automated tool for hardware hacking. Using a modernized fork of the original BUSSide project developed by Silvio Cesare
* **SEGGER J-Link**: High-speed JTAG/SWD debugging and flash programming.
* **ST-LINK (V2/V3)**: Native flashing and debugging support for STM32 microcontrollers via `stlink-tools` and OpenOCD.
* **Microcontrollers & SoC Modules**: Espressif ESP32 families (including ESP32-S3), STM32 series, and generic SPI flash memories.

## 🔍 Reverse Engineering & Binary Analysis

To complement the physical hardware toolchain core utilities for software-level reverse engineering, firmware unpacking, and binary comparisons are installed too.

### Reversing
* **Disassembly & Decompilation**: 
  *  **Ghidra** software reverse engineering suite for analyzing compiled binaries across multiple architectures.
* **Firmware Extraction & Analysis**: 
  * `binwalk` for searching binary images for embedded files and executable code.
  * `flashfinder` for locating specific patterns or components within flash dumps.
  * **Fuzzy Hashing**: `binwally` for directory and file fuzzy hashing, structural binary comparison, and identifying similarities across firmware revisions or compiled binaries.

---

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
$su root -c /sbin/adduser$USER sudo
(reboot if you weren't already in that group)

**Then run the shell script**
$ ./customize.sh