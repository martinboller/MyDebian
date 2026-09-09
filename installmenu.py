import re
import sys

# Define configuration sections and their items (Label, Variable)
CONFIG_GROUPS = [
    ("General Configuration", [
        ("Configure Debian Repositories", "APT_CONFIGURE"),
        ("Configure Nix", "NIX_CONFIGURE"),
        ("Configure Serial Access", "CONFIGURE_SERIAL"),
        ("Install Updates", "UPDATES_INSTALL"),
    ]),
    ("Debian Packages", [
        ("Enable Installation of Debian Packages", "APT_UTILS"),
        ("Install Forensics Tools", "FORTOOLS_INSTALL"),
        ("Install Network Tools", "NETTOOLS_INSTALL"),
        ("Install User Tools", "USERTOOLS_INSTALL"),
        ("Install System Tools", "SYSTOOLS_INSTALL"),
        ("Install Python Environment", "PYTHON_INSTALL"),
        ("Flatpak Support", "FLATPAK_INSTALL"),
        ("Install NTFS Support", "NTFS_INSTALL"),
        ("Install Debian Backports", "BACKPORTS_INSTALL"),
        ("Install Development Tools from Debian Packages", "DEVTOOLS_INSTALL"),
        ("Install Go Language Support", "GO_INSTALL"),
        ("Install Pulseview (require Development tools)", "PULSEVIEW_INSTALL"),
        ("Install Hashcat (require Development tools)", "HASHCAT_INSTALL"),
        ("Install Hardware Hacking Tools (require Development tools)", "HWHACKTOOLS_INSTALL"),
    ]),
    ("Flatpak Packages", [
        ("Enable Flatpak Integration", "FLATPAK_UTILS"),
        ("Install Flatpak User Tools", "FP_USERTOOLS_INSTALL"),
        ("Install Flatpak Development Tools", "FP_DEVTOOLS_INSTALL"),
        ("Install Flatpak Electronics Tools", "FP_ELECTRONICSTOOLS_INSTALL"),
        ("Install Flatpak 3D Tools", "FP_3DTOOLS_INSTALL"),
    ]),
    ("GNOME Desktop", [
        ("Enable GNOME Desktop Configurations", "GNOME_SETTINGS"),
        ("Enable Minimize/Maximize Buttons", "MM_BUTTONS_CONFIGURE"),
        ("Configure Menu Key as Compose Key", "MENU_IS_COMPOSE"),
        ("Configure Keyboard Shortcuts", "KB_SHORTCUTS"),
        ("Install Dash to Panel Gnome Extension", "GNOME_DASH_TO_PANEL"),
        ("Install Caffeine GNOME Extension", "GNOME_CAFFEINE"),        
    ]),
    ("Microsoft Integration", [
        ("Enable Microsoft APT Repo", "MICROSOFT_APT"),
        ("Microsoft Repo Workaround", "MICROSOFT_APT_WORKAROUND"),
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

def main():
    filepath = ".env"
    lines = load_env(filepath)

    while True:
        env_data = extract_values(lines)
        option_map = {}
        index = 1

        print("\n==========================================")
        print("     Environment Component Configuration")
        print("==========================================")

        for group_title, items in CONFIG_GROUPS:
            print(f"\n-- {group_title} --")
            for label, var_name in items:
                status = env_data.get(var_name, "N/A")
                print(f"  [{index}] {label} ({var_name}): [{status}]")
                option_map[index] = var_name
                index += 1

        print("\n  [S] Save Changes")
        print("  [Q] Quit Without Saving")
        
        choice = input("\nSelect an option to toggle (or S/Q): ").strip().lower()

        if choice == 's':
            save_env(lines, filepath)
            break
        elif choice == 'q':
            print("Exiting without saving.")
            break
        elif choice.isdigit() and int(choice) in option_map:
            var_to_toggle = option_map[int(choice)]
            current_val = env_data.get(var_to_toggle, "No")
            new_val = "No" if current_val == "Yes" else "Yes"
            toggle_in_lines(lines, var_to_toggle, new_val)
        else:
            print("\nInvalid choice. Press Enter to try again...")

if __name__ == "__main__":
    main()