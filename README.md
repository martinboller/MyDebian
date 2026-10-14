# myDebian

Automated setup script and configuration environment for Debian 13 (Trixie), tailored for **Hardware Hacking**, **Reverse Engineering**, and custom GNOME Desktop setups. Control your installation profile interactively via `installmenu.py`.

---

## 🔌 Hardware Hacking & Embedded Toolchain

The environment features specialized tools tailored for hardware reverse engineering, embedded systems debugging, microcontroller flashing, and logic analysis.

### Included Tooling & Capabilities
* **Logic Analysis**: **PulseView** (built from source leveraging Debian backports) for visual protocol decoding (SPI, I2C, UART) via logic analyzers.
* **Flash, Firmware, Debugging & Programming**: 
  * `flashrom` for reading, writing, erasing, and verifying flash chips (SPI/BIOS/EEPROM).
  * `ufsprog` for UFS storage interface operations (`ufsnandprog`, `ufsnandtest`, `ufsnorprog`, `ufsnortest`). 
  * `openocd` (Open On-Chip Debugger) supporting JTAG/SWD debugging.
  * `stlink-tools` for flashing and interacting with STM32 microcontrollers.
  * `esptool` for flashing Espressif ESP32-series chips (such as ESP32-S3 devices).
  * `snander` (Serial Nor/nAND/Eeprom programmeR).
  * `sertack` for embedded device security auditing, firmware extraction, and hardware debugging.
* **Serial Port Access**: Automated user group configuration granting non-root access to serial ports.
 
### Supported Boards & Hardware Interfaces
* **WHIDBoard**: The ultimate Swiss-Army-Knife for hacking any (I)IoT & Embedded devices. Powered by the BRUSCHETTAPRO core controller, it supports multiple protocols (UART, SPI, I2C, JTAG, SWD) across multiple logic levels (1.8V, 2.5V, 3.3V, and target VREF).
* **Bruschetta Board**: Multi-Protocol Swiss-Army-Knife.
* **BUSSide**: An automated tool for hardware hacking using a modernized fork of the original BUSSide project by Silvio Cesare.
* **SEGGER J-Link**: High-speed JTAG/SWD debugging and flash programming.
* **ST-LINK (V2/V3)**: Native flashing and debugging support for STM32 microcontrollers via `stlink-tools` and OpenOCD.
* **Microcontrollers & SoC Modules**: Espressif ESP32 families (including ESP32-S3), STM32 series, and generic SPI flash memories.

---

## 🔍 Reverse Engineering & Binary Analysis

To complement the physical hardware toolchain, core utilities for software-level reverse engineering, firmware unpacking, and binary comparisons are included.

### Included Capabilities
* **Disassembly & Decompilation**: **Ghidra** software reverse engineering suite for analyzing compiled binaries across multiple architectures.
* **Firmware Extraction & Analysis**: 
  * `binwalk` for searching binary images for embedded files and executable code.
  * `flashfinder` for locating specific patterns or components within flash dumps.
* **Fuzzy Hashing**: `binwally` for directory and file fuzzy hashing, structural binary comparison, and identifying similarities across firmware revisions or compiled binaries.

---

## 📋 Additional Categories & Components

Beyond core hacking and reverse engineering tools, the setup manages:
* **Base System & Infrastructure**: Core retrieval utilities (`curl`, `wget`, `git`), backports repositories, and build tools (`build-essential`, `cmake`, Python 3 runtimes).
* **Network Diagnostics & Security**: Ping, net-tools, dnsutils, traceroute, nmap, Wireshark, tcpdump, and ncat.
* **Desktop Environment & GNOME**: Dash to Panel and Caffeine extensions, dynamic panel length, shortcut bindings, and layout configurations.
* **Virtualization & Productivity**: Flatpak integration (VS-Codium, BitWarden, Calibre, Ungoogled Chromium, Signal, etc.) and Microsoft package repositories (PowerShell).

---

### Usage

**1. Clone the repo**
```bash
$ git clone [https://github.com/martinboller/myDebian.git](https://github.com/martinboller/myDebian.git)
$ cd myDebian/
```


**2. Configure installation preferences**
```bash
python3 installmenu.py
```

**3. Ensure your user is in sudoers**
```bash
su root -c "/sbin/usermod -aG sudo $USER"
```
Reboot if you weren't already in sudoers.

**4. Run the customization script as your user**
```bash
./customize.sh
```

