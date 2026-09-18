#!/usr/bin/env python3

import re
import sys
import os
clear = lambda: os.system('clear') #on Linux System

# Define configuration sections and their items (Label, Variable)
CONFIG_GROUPS = [
    ("GNOME Desktop", [
        ("Enable GNOME Desktop Configurations", "GNOME_SETTINGS"),
        ("Enable Minimize/Maximize Buttons", "MM_BUTTONS_CONFIGURE"),
        ("Configure Menu Key as Compose Key", "MENU_IS_COMPOSE"),
        ("Configure Keyboard Shortcuts", "KB_SHORTCUTS"),
        ("Install Dash to Panel Gnome Extension", "GNOME_DASH_TO_PANEL"),
        ("Install Caffeine GNOME Extension", "GNOME_CAFFEINE"),        
    ]),
    ("Virtualization", [
        ("Install Virtualization", "VIRT_INSTALL"),
        ("Install Docker", "DOCKER_INSTALL"),
    ]),
    ("Forensics and Networking", [
        ("Install Forensics Tools", "FORTOOLS_INSTALL"),
        ("Install Network Tools", "NETTOOLS_INSTALL"),
        ("Install System Tools", "SYSTOOLS_INSTALL"),
    ]),
    ("Hacking & Reverse Engineering", [
        ("Install Development Tools from Debian Packages", "DEVTOOLS_INSTALL"),
        ("Install Debian Backports", "BACKPORTS_INSTALL"),
        ("Install Hardware Hacking Tools (require Backports, Development and Python tools)", "HWHACKTOOLS_INSTALL"),
        ("Install Sigrok Client & Pulseview (require Backports, Development and Python tools)", "PULSEVIEW_INSTALL"),
        ("Install Hashcat (require Development tools)", "HASHCAT_INSTALL"),
        ("Install Reverse Engineering Tools (require Development tools)", "REVERSETOOLS_INSTALL"),
    ]),
    ("Development", [
        ("Install Development Tools from Debian Packages", "DEVTOOLS_INSTALL"),
        ("Install Flatpak Development Tools", "FP_DEVTOOLS_INSTALL"),
        ("Install Go Language Support", "GO_INSTALL"),
        ("Install Python Environment", "PYTHON_INSTALL"),
    ]),
    ("User Tools", [
        ("Install Debian User Tools", "USERTOOLS_INSTALL"),
        ("Install Flatpak User Tools", "FP_USERTOOLS_INSTALL"),
        ("Install Flatpak Electronics Tools", "FP_ELECTRONICSTOOLS_INSTALL"),
        ("Install Flatpak 3D Tools", "FP_3DTOOLS_INSTALL"),
    ]),
    ("Microsoft Integration", [
        ("Enable Microsoft APT Repo", "MICROSOFT_APT"),
        ("PowerShell Install", "PWSH_INSTALL"),
    ]),
]

def load_env(filepath=".env"):
    """Reads the environment file line by line."""
    try:
        with open(filepath, "r") as f:
            return f.readlines()
    except FileNotFoundError:
        print(f"Error: Could not find '{filepath}'. Place the script in the same folder.")
        sys.exit(1)

def save_env(lines, filepath=".env"):
    """Writes updated lines back to the environment file."""
    with open(filepath, "w") as f:
        f.writelines(lines)
    print("\n[+] Configuration saved successfully.")

def extract_values(lines):
    """Parses current key-value pairs from file contents."""
    data = {}
    for line in lines:
        match = re.match(r'^\s*([A-Za-z0-9_]+)\s*=\s*["\']?(Yes|No)["\']?', line)
        if match:
            data[match.group(1)] = match.group(2)
    return data

def toggle_in_lines(lines, var_name, new_val):
    """Updates a variable's value while retaining original formatting."""
    pattern = re.compile(rf'^(\s*{var_name}\s*=\s*["\']?)(Yes|No)(["\']?.*)$')
    for i, line in enumerate(lines):
        if pattern.match(line):
            lines[i] = pattern.sub(rf'\g<1>{new_val}\g<3>', line)
            break

def set_all_values(lines, new_val):
    """Bulk sets all defined variables in CONFIG_GROUPS to target value."""
    for _, items in CONFIG_GROUPS:
        for _, var_name in items:
            toggle_in_lines(lines, var_name, new_val)

def apply_preset(lines, target_group_titles, explicit_vars=None):
    """
    Enables variables in target groups and explicit variable overrides,
    disabling all other variables.
    """
    if explicit_vars is None:
        explicit_vars = set()

    enabled_vars = set(explicit_vars)
    all_vars = set()

    for group_title, items in CONFIG_GROUPS:
        for _, var_name in items:
            all_vars.add(var_name)
            if group_title in target_group_titles:
                enabled_vars.add(var_name)

    for var_name in all_vars:
        new_val = "Yes" if var_name in enabled_vars else "No"
        toggle_in_lines(lines, var_name, new_val)

def main():
    filepath = ".env"
    lines = load_env(filepath)

    while True:
        clear()
        env_data = extract_values(lines)
        option_map = {}
        index = 1

        print("#####     Environment Component Configuration     #####")
    
        for group_title, items in CONFIG_GROUPS:
            print(f"-- {group_title} --")
            for label, var_name in items:
                status = env_data.get(var_name, "N/A")
                print(f"  [{index}] {label} ({var_name}): [{status}]")
                option_map[index] = var_name
                index += 1

        print("\n  [A] Enable All          - [D] Disable All")
        print("  [H] Hacking & Forensics - [P] Productivity")
        print("  [Q] Quit Without Saving - [S] Save Changes")
        
        choice = input("\nSelect an option to toggle (or A/D/H/P/Q/S): ").strip().lower()

        if choice == 's':
            save_env(lines, filepath)
            break
        elif choice == 'q':
            print("Exiting without saving.")
            break
        elif choice == 'h':
            hacker_groups = [
                "General Configuration",
                "GNOME Desktop",
                "Virtualization",
                "Forensics and Networking",
                "Hacking & Reverse Engineering",
                "Development",
            ]
            hacker_extra_vars = {"FP_ELECTRONICSTOOLS_INSTALL", "FP_3DTOOLS_INSTALL"}
            apply_preset(lines, hacker_groups, explicit_vars=hacker_extra_vars)
        elif choice == 'p':
            productivity_groups = [
                "General Configuration",
                "GNOME Desktop",
                "User Tools",
            ]
            apply_preset(lines, productivity_groups)
        elif choice == 'a':
            set_all_values(lines, "Yes")
        elif choice == 'd':
            set_all_values(lines, "No")
        elif choice.isdigit() and int(choice) in option_map:
            var_to_toggle = option_map[int(choice)]
            current_val = env_data.get(var_to_toggle, "No")
            new_val = "No" if current_val == "Yes" else "Yes"
            toggle_in_lines(lines, var_to_toggle, new_val)
        else:
            print("\nInvalid choice. Press Enter to try again...")

if __name__ == "__main__":
    main()