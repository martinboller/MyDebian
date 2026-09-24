#!/usr/bin/env python3

import re
import sys
import os
from datetime import datetime

clear = lambda: os.system('clear') #on Linux System

# Define configuration sections and their items (Label, Variable)
CONFIG_GROUPS = [
    ("GNOME Desktop", [
        ("Enable Minimize/Maximize Buttons", "MM_BUTTONS_CONFIGURE"),
        ("Configure Menu Key as Compose Key", "MENU_IS_COMPOSE"),
        ("Configure Keyboard Shortcuts", "KB_SHORTCUTS"),
        ("Install Dash to Panel Gnome Extension", "GNOME_DASH_TO_PANEL"),
        ("IntelliHide the Panel", "GNOME_INTELLIHIDE"),
        ("Set Panel Length to Dynamic", "GNOME_PANEL_LENGTH_DYNAMIC"),
        ("Hide Overview on Startup", "GNOME_HIDE_OVERVIEW"),
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

# Mapping of features to their required dependency packages
DEPENDENCIES = {
    "HWHACKTOOLS_INSTALL": ["BACKPORTS_INSTALL", "DEVTOOLS_INSTALL", "PYTHON_INSTALL"],
    "PULSEVIEW_INSTALL": ["BACKPORTS_INSTALL", "DEVTOOLS_INSTALL", "PYTHON_INSTALL"],
    "HASHCAT_INSTALL": ["DEVTOOLS_INSTALL", "PYTHON_INSTALL"],
    "REVERSETOOLS_INSTALL": ["DEVTOOLS_INSTALL", "PYTHON_INSTALL"],
}

def load_env(filepath=".env"):
    """Reads the environment file line by line."""
    try:
        with open(filepath, "r") as f:
            return f.readlines()
    except FileNotFoundError:
        print(f"Error: Could not find '{filepath}'. Place the script in the same folder.")
        sys.exit(1)

def update_env_version(lines):
    """Updates the ENV_VERSION variable with the current timestamp."""
    now_iso = datetime.now().astimezone().isoformat(timespec='seconds')
    pattern = re.compile(r'^(\s*ENV_VERSION\s*=\s*)["\']?.*?["\']?(\s*(?:#.*)?)$')
    for i, line in enumerate(lines):
        if re.match(r'^\s*ENV_VERSION\s*=', line):
            lines[i] = pattern.sub(rf"\g<1>'{now_iso}'\g<2>", line)
            break

def save_env(lines, filepath=".env"):
    """Writes updated lines back to the environment file."""
    update_env_version(lines)
    with open(filepath, "w") as f:
        f.writelines(lines)
    print("\n[+] Configuration saved successfully.")

def extract_values(lines):
    """Parses current key-value pairs from file contents."""
    data = {}
    for line in lines:
        match = re.match(r'^\s*([A-Za-z0-9_]+)\s*=\s*["\']?([^"\']*)["\']?', line)
        if match:
            data[match.group(1)] = match.group(2)
    return data

def update_var_in_lines(lines, var_name, new_val):
    """Updates any variable's value while retaining original formatting."""
    pattern = re.compile(rf'^(\s*{var_name}\s*=\s*["\']?).*?(["\']?\s*(?:#.*)?)$')
    for i, line in enumerate(lines):
        if re.match(rf'^\s*{var_name}\s*=', line):
            lines[i] = pattern.sub(rf'\g<1>{new_val}\g<2>', line)
            break

def toggle_in_lines(lines, var_name, new_val):
    """Updates a variable's value while retaining original formatting."""
    update_var_in_lines(lines, var_name, new_val)

def enforce_dependencies(lines, last_action_var=None, last_action_val=None):
    """
    Enforces feature package dependencies bi-directionally:
    1. If a tool depending on prerequisites is enabled, automatically enables its required packages.
    2. If a required package is explicitly disabled ('No'), automatically disables dependent tools.
    """
    changed = True
    while changed:
        changed = False
        env_data = extract_values(lines)

        # 1. Direct disable propagation: if a prerequisite was toggled to 'No', disable dependent features
        if last_action_var and last_action_val == "No":
            for dep_var, req_vars in DEPENDENCIES.items():
                if last_action_var in req_vars and env_data.get(dep_var, "No") == "Yes":
                    update_var_in_lines(lines, dep_var, "No")
                    changed = True
            if changed:
                env_data = extract_values(lines)

        # 2. Forward requirements check: Enable prerequisite packages if dependent tool is 'Yes'
        for dep_var, req_vars in DEPENDENCIES.items():
            if env_data.get(dep_var, "No") == "Yes":
                for req in req_vars:
                    if env_data.get(req, "No") != "Yes":
                        update_var_in_lines(lines, req, "Yes")
                        changed = True

        if changed:
            env_data = extract_values(lines)

        # 3. Guard check: Ensure dependent features aren't 'Yes' if any prerequisite is 'No'
        for dep_var, req_vars in DEPENDENCIES.items():
            if env_data.get(dep_var, "No") == "Yes":
                if any(env_data.get(req, "No") != "Yes" for req in req_vars):
                    update_var_in_lines(lines, dep_var, "No")
                    changed = True

def set_all_values(lines, new_val):
    """Bulk sets all defined variables in CONFIG_GROUPS to target value."""
    for _, items in CONFIG_GROUPS:
        for _, var_name in items:
            toggle_in_lines(lines, var_name, new_val)
    enforce_dependencies(lines)

def toggle_all_values(lines):
    """
    Toggles all variables: if every variable is currently set to 'Yes',
    sets them all to 'No'. Otherwise, sets them all to 'Yes'.
    """
    env_data = extract_values(lines)
    all_vars = {var_name for _, items in CONFIG_GROUPS for _, var_name in items}
    all_enabled = all(env_data.get(v, "No") == "Yes" for v in all_vars)
    new_val = "No" if all_enabled else "Yes"
    set_all_values(lines, new_val)

def apply_preset(lines, target_group_titles, explicit_vars=None):
    """
    Sets target groups and explicit variables to 'Yes' while disabling ('No')
    all other variables. Automatically resolves required package dependencies.
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

    enforce_dependencies(lines)

def toggle_vars(lines, var_names):
    """
    Toggles a specific set of variables: if all are 'Yes', sets them to 'No'.
    Otherwise, sets them all to 'Yes'. Leaves unrelated options untouched.
    """
    env_data = extract_values(lines)
    all_enabled = all(env_data.get(var, "No") == "Yes" for var in var_names)
    new_val = "No" if all_enabled else "Yes"

    for var in var_names:
        toggle_in_lines(lines, var, new_val)

    enforce_dependencies(lines)

def main():
    filepath = ".env"
    lines = load_env(filepath)

    # Resolve dependencies on startup based on existing file state
    enforce_dependencies(lines)

    while True:
        clear()
        env_data = extract_values(lines)
        option_map = {}
        index = 1

        print("#####     Environment Features Configuration     #####")
    
        for group_title, items in CONFIG_GROUPS:
            print(f"-- {group_title} --")
            for label, var_name in items:
                status = env_data.get(var_name, "N/A")
                print(f"  [{index}] {label} ({var_name}): [{status}]")
                option_map[index] = var_name
                index += 1

        grub_timeout = env_data.get("GRUB_TIMEOUT", "N/A")

        print("\n  [A] Toggle All\t\t[G] Toggle GNOME features")
        print("  [H] Hacking Preset\t\t[P] Productivity Preset ")
        print("  [M] Toggle MS Integration\t[N] Networking Preset")
        print(f"  [T] Set GRUB Timeout [{grub_timeout}s]\t[R] Reverse Engineering Preset")
        print("  [Q] Quit Without Saving\t[S] Save Changes")
        
        choice = input("\nSelect an option to toggle (or A/G/H/P/M/N/T/R/Q/S): ").strip().lower()

        if choice == 's':
            save_env(lines, filepath)
            break
        elif choice == 'q':
            print("Exiting without saving.")
            break
        elif choice == 'a':
            toggle_all_values(lines)
        elif choice == 'h':
            hacker_groups = [
                "GNOME Desktop",
                "Virtualization",
                "Forensics and Networking",
                "Hacking & Reverse Engineering",
                "Development",
            ]
            hacker_extra_vars = {"FP_ELECTRONICSTOOLS_INSTALL", "FP_3DTOOLS_INSTALL"}
            apply_preset(lines, hacker_groups, explicit_vars=hacker_extra_vars)
        elif choice == 'r':
            re_groups = [
                "GNOME Desktop",
                "Virtualization",
                "Development",
            ]
            re_extra_vars = {"REVERSETOOLS_INSTALL", "HASHCAT_INSTALL"}
            apply_preset(lines, re_groups, explicit_vars=re_extra_vars)
        elif choice == 'p':
            productivity_groups = [
                "GNOME Desktop",
                "User Tools",
            ]
            apply_preset(lines, productivity_groups)
        elif choice == 'm':
            toggle_vars(lines, ["MICROSOFT_APT", "PWSH_INSTALL"])
        elif choice == 'n':
            networking_groups = [
                "GNOME Desktop",
            ]
            networking_extra_vars = {"NETTOOLS_INSTALL", "SYSTOOLS_INSTALL", "PYTHON_INSTALL"}
            apply_preset(lines, networking_groups, explicit_vars=networking_extra_vars)
        elif choice == "g":
            toggle_vars(lines, ["MENU_IS_COMPOSE", "MM_BUTTONS_CONFIGURE", "KB_SHORTCUTS", "GNOME_DASH_TO_PANEL", "GNOME_CAFFEINE", "GNOME_INTELLIHIDE", "GNOME_PANEL_LENGTH_DYNAMIC", "GNOME_HIDE_OVERVIEW"])
        elif choice == 't':
            val = input(f"\nEnter GRUB Timeout in seconds (0-10, current: {grub_timeout}): ").strip()
            if val.isdigit() and 0 <= int(val) <= 10:
                update_var_in_lines(lines, "GRUB_TIMEOUT", val)
            else:
                input("\nInvalid value! Timeout must be an integer between 0 and 10. Press Enter to continue...")
        elif choice.isdigit() and int(choice) in option_map:
            var_to_toggle = option_map[int(choice)]
            current_val = env_data.get(var_to_toggle, "No")
            new_val = "No" if current_val == "Yes" else "Yes"
            toggle_in_lines(lines, var_to_toggle, new_val)
            enforce_dependencies(lines, last_action_var=var_to_toggle, last_action_val=new_val)
        else:
            input("\nInvalid choice. Press Enter to try again...")

if __name__ == "__main__":
    main()