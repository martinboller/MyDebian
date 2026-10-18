# myDebian

Automated setup script and configuration environment for **Debian 13 (Trixie)**, tailored for **Hardware Hacking**, **Reverse Engineering**, and custom **GNOME Desktop** setups. However, you can also select a `productivity` preset that gives you a Debian install catered for day-to-day productivity without any of the scary hacking or reverse engingeering tools.
Control your installation profile interactively via `installmenu.py` which manages dependencies correctly. If you want to change tool versions and don't like the defaults the .env-file can be edited manually with vi or nano.

---

## ❤️ Thanks

A heartfelt thank you to:

* ***Luca Bongiorni*** - for your incredible hardware hacking innovation, brilliant tooling support, and pushing the boundaries of what's possible.
* ***Søren Egede Knudsen*** - for your invaluable cybersecurity expertise, steady guidance, and great collaboration along the way.
* ***Michael Vingaard*** -for your deep OT/ICS security insights, collaboration, and building top-tier training environments.

To everyone that I've forgotten, **SORRY**

## 🔌 Hardware Hacking & Embedded Toolchain

The environment features specialized tools tailored for hardware reverse engineering, embedded systems debugging, microcontroller flashing, and logic analysis.

### Included Tooling & Capabilities
* **Logic Analysis**:
  * **[PulseView](https://sigrok.org/wiki/PulseView)** (built from source leveraging Debian backports) for visual protocol decoding (SPI, I2C, UART) via logic analyzers. Also supports the [Sipeed SLogic 8u2 and 16u3 Logic Analyzers](https://wiki.sipeed.com/hardware/en/logic_analyzer/slogic16u3/Introduction.html).
* **Flash, Firmware, Debugging & Programming**: 
  * **[flashrom](https://www.flashrom.org/)** (custom [WHIDBoard fork](https://github.com/whid-injector/flashrom-whidboard)) for reading, writing, erasing, and verifying flash chips (SPI/BIOS/EEPROM).
  * **[ufprog](https://github.com/whid-injector/ufprog)** for UFS storage interface operations (`ufsnandprog`, `ufsnandtest`, `ufsnorprog`, `ufsnor-test`). 
  * **[OpenOCD](https://openocd.org/)** (Open On-Chip Debugger, via [openocd-linux fork](https://github.com/whid-injector/openocd-linux)) supporting JTAG/SWD debugging.
  * **[stlink-tools](https://github.com/stlink-org/stlink)** for flashing and interacting with STM32 microcontrollers.
  * **[esptool](https://github.com/espressif/esptool)** for flashing Espressif ESP32-series chips (such as ESP32-S3 devices).
  * **[SNANDer](https://github.com/martinboller/SNANDer)** (Serial Nor/NAND/EEPROM ProgrammeR).
  * **[sertack](https://github.com/martinboller/sertack)** for embedded device security auditing, firmware extraction, and hardware debugging.
  * **[Findus](https://github.com/MKesenheimer/fault-injection-library)** (Fault-Injection-Library) toolchain to perform fault-injection attacks on microcontrollers (supporting ChipWhisperer Pro, Husky, and Pico Glitcher).
* **Serial Port Access**: Automated user group configuration (`dialout`, `plugdev`) granting non-root access to serial and USB hardware interfaces.

### Supported Boards & Hardware Interfaces
* **[Bruschetta Board](https://github.com/whid-injector/BRUSCHETTA-board)**: The Multi-Protocol Board for Hardware Hackers (UART/JTAG/SPI/I2C)
* **[WHIDBoard](https://github.com/whid-injector/WHIDBOARD)**: The ultimate Swiss-Army-Knife for hacking IoT and embedded devices, supporting multi-protocol logic levels (1.8V, 2.5V, 3.3V, VREF).
* **[BUSSide](https://github.com/martinboller/BUSSide)**: Automated hardware hacking interface using a modernized fork of Silvio Cesare's original project.
* **SEGGER J-Link & ST-LINK (V2/V3)**: Native high-speed JTAG/SWD debugging and flash programming.
* **Microcontrollers & SoC**: Espressif ESP32 family, STM32 microcontrollers, and generic SPI flash memories.
* **[Sipeed SLogic 16u3](https://wiki.sipeed.com/hardware/en/logic_analyzer/slogic16u3/Introduction.html)**: The SLogic16U3 is a next‑generation USB3 logic analyzer. It delivers high sample rates over a 5 Gbps USB3 interface: 800M@4CH, 400M@8CH, 200M@16CH. It supports 0–10V signal input, configurable voltage trigger thresholds from 0–6V, and software triggering.
* **And many others**

---

## 🔍 Reverse Engineering & Binary Analysis

Core utilities for software-level reverse engineering, firmware unpacking, and binary comparisons.

### Included Capabilities
* **Disassembly & Decompilation**: **[Ghidra](https://github.com/NationalSecurityAgency/ghidra)** software reverse engineering suite, integrated with Python / PyGhidra support.
* **Firmware Extraction & Analysis**: 
  * **[Binwalk 3](https://github.com/ReFirmLabs/binwalk)** for searching binary images for embedded files and executable code.
  * **[Firmwalker](https://github.com/hotelzululima/firmwalker)** script for auditing extracted firmware file systems.
* **Fuzzy Hashing & Forensics**: 
  * **[Binwally](https://github.com/martinboller/binwally)** (Python 3 port utilizing `ppdeep`) for structural binary comparisons and fuzzy hashing across firmware revisions.
  * **[Volatility 3](https://github.com/volatilityfoundation/volatility3)** memory forensics framework.
  * **[Autopsy](https://www.autopsy.com/)** forensics analysis platform running securely inside an automated **[Docker](https://www.docker.com/)** container with **[The Sleuth Kit (TSK)](https://www.sleuthkit.org/)**.

---

## 📋 Additional Categories & Components

* **Base System & Infrastructure**: Core retrieval utilities (`curl`, `wget`, `git`), Debian Trixie backports, and build essentials (`cmake`, Python 3 virtual environments).
* **Network Security & Analysis**
  * **[Wireshark](https://www.wireshark.org/)**: Aircrack-ng is a complete suite of tools to assess WiFi network security.
  * **[Nmap](https://nmap.org/)**: Nmap (“Network Mapper”) is an open source tool for network exploration and security auditing.
  * **[Bettercap](https://www.bettercap.org/)**: The Swiss Army knife for WiFi, Bluetooth Low Energy, wireless HID hijacking, CAN-bus and IPv4 and IPv6 networks reconnaissance and MITM attacks.
  * **[tcpdump](https://www.tcpdump.org/)**:  powerful command-line packet analyzer; and libpcap, a portable C/C++ library for network traffic capture.
  * **[aircrack-ng](https://www.aircrack-ng.org/)**: Aircrack-ng is a complete suite of tools to assess WiFi network security.
  * **[flent](https://flent.org/)**: Flent (The FLExible Network Tester) is a Python-based benchmarking utility that orchestrates multiple network testing tools (such as netperf and iperf) to run aggregate, repeatable tests and analyze performance under load, such as detecting bufferbloat.
* **Desktop Environment & GNOME**: Automated deployment of extensions (*Dash to Panel*, *Caffeine*), custom App Folders (*Hardware Hacking*, *Reverse Engineering*, *Fault Injection*, *Digital Forensics*), and window manager tweaks.
* **Virtualization**:
  * **Multi-architecture emulation, specifically ARM, RISC-V, PowerPC, IBM S-390, Sparc32**
  * **[QEMU/KVM](https://www.qemu.org/)**: A generic and open source machine emulator and virtualizer.
  * **[Virt-Manager](https://virt-manager.org/)**: The virt-manager application is a desktop user interface for managing virtual machines through libvirt. It primarily targets KVM VMs, but also manages Xen and LXC (linux containers).
  * **[gnome-boxes (Boxes)](https://help.gnome.org/gnome-boxes/supported-protocols.html)**: Boxes uses qemu-kvm, libvirt-glib and spice-gtk to allow users to easily manage virtual machines. Useful for quickly spinning up a box.
* **Productivity**:
  * Flatpak integration (**[VSCodium](https://vscodium.com/)**, **[ImHex](https://imhex.werwolv.net/)**, **[OpenSCAD](https://openscad.org/)**), and Microsoft PowerShell.

---

## 🚀 Usage

---

### Usage

**1a. Clone the repo**
```bash
git clone https://github.com/martinboller/MyDebian.git
cd MyDebian/
```
or

**1b. Download and unzip the repo**
```bash
wget https://github.com/martinboller/MyDebian/archive/refs/heads/master.zip
unzip master.zip
cd MyDebian-master/
```

**2a. Configure installation preferences**
```bash
python3 installmenu.py
```

### Overview of installmenu.py
`installmenu.py` is an interactive Python terminal menu used to configure features and modules within the .env configuration file prior to running the main Debian deployment script. It features automatic dependency enforcement (transitively enabling required core tools or disabling dependent ones) and tracks user configuration states.
* **Built-in Presets**:
  * **[H] Hacking Preset**: Activates GNOME desktop enhancements, virtualization infrastructure, system forensics, networking tools, and specialized hardware hacking/reverse engineering components (including Ghidra, hardware utilities, and electronic tools).
  * **[R] Reverse Engineering Preset**: Focuses on core development dependencies, desktop customization, virtualization, and binary analysis packages such as Hashcat, Volatility, and reverse-engineering utilities.
  * **[N] Networking Preset**: Configures network troubleshooting and scanning suites alongside system tools and Python environments.
  * **[P] Productivity Preset**: Streamlines the profile to standard user utilities, multimedia apps, and GNOME workspace adjustments.
  * **Granular Toggling**: Each category (GNOME, Virtualization, Forensics/Networking, Hacking & RE, Development, User Tools, MS Integration, and NVIDIA Drivers) can be managed individually via numeric options.
  * **Quick Toggles**: Instantly flip all options ([A]), toggle GNOME features ([G]), or configure Microsoft integrations ([M]).
  * **GRUB Timeout**: Adjusts the system bootloader wait time ([T]) directly from the menu.   

**2b. Configure installation preferences manually**
```bash
vi .env
```
***Be careful with dependencies!***

**3. Ensure your user is in sudoers**
```bash
su root -c "/sbin/usermod -aG sudo $USER"
```
Reboot if you weren't already in sudoers.

**4. Run the customization script as your user**
```bash
./customize.sh
```
Follow along in the two terminal windows, then reboot when prompted to. That's it! You now have a number of tools at your disposal (depending on what choices you made in section 2a and/or 2b)

## 📄 License

This project is open-source software licensed under the **[European Union Public Licence (EUPL)](https://joinup.ec.europa.eu/collection/eupl/eupl-text-eu-public-licence)** (v1.2 or later). 

By contributing or using this repository, you agree to be bound by the terms of the EUPL. You may obtain a copy of the License at:

* [Official EUPL Text & Translations](https://joinup.ec.europa.eu/collection/eupl/eupl-text-eu-public-licence)