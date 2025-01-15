#!/usr/bin/env bash

if (( ${EUID:-$(id -u)} != 0 )); then
    printf -- '%s\n' "This script needs to be run as root (use sudo)." >&2
    exit 1
fi

# Define VARIABLES
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RESET='\033[0m'

# Function to check and install figlet if not installed
animated_text_dependencies() {
    if ! command -v figlet &> /dev/null; then
        echo "Installing something Cool !"
        apt-get update &> /dev/null && apt-get install -y figlet&> /dev/null
    else
        echo "Done Installing"
    fi
}
# Animated Test
ascii_animate() {
    local input_text="$1"  # Get the text passed as an argument
    figlet -f "./fonts/Bloody.flf" -w 200 "$input_text"
}

# Function to install base packages
install_base_package() {

    # List of packages to install
    local packages=("wget" 
    "curl" 
    "git" 
    "vim" 
    "glances")
    
    # Display the list of packages in blue
    echo -e "${BLUE}The following packages will be installed:${RESET}"
    for package in "${packages[@]}"; do
        echo -e "${BLUE}$package${RESET}"
    done
    echo -e "${YELLOW}System: Installing Packages ${RESET}\n"
    # Loop through the packages and install them
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "${package}"; then
            echo -e "${YELLOW}System: Installing ${package} ${RESET}"
            apt-get install -y "${package}" &> /dev/null
            echo -e "${GREEN}System: ${package} Installed${RESET}"
        else
            echo -e "${GREEN}System: ${package} Already Installed${RESET}"
        fi
    done
    echo -e "\n${GREEN}System: All Packages Installed Successfully${RESET}\n"
}


# Function to patch the system
system_patch() {
    echo -e "${YELLOW}System : Updating Packages ${RESET}"
    apt-get update &> /dev/null 
    apt-get upgrade -y &> /dev/null
    echo -e "${GREEN}System : Updates Installed${GREEN}"
}

# Main Function
main() {
    animated_text_dependencies
    ascii_animate "H E L L O"

    local OPTIONS=(
        "Patch the System [ Update all the packages ]"
        "Install Required Base Packages"
        "Install Docker Engine"
        "Install Kubernetes"
        "Set Aliases"
    )

    PS3="Choose an option: "

    select CHOICE in "${OPTIONS[@]}"; do
        case $REPLY in
            1) system_patch ; break ;;
            2) install_base_package ; break ;;
            3) echo "You chose: $CHOICE"; break ;;
            4) echo "You chose: $CHOICE"; break ;;
            5) echo "You chose: $CHOICE"; break ;;
            *) echo "Invalid choice. Try again."; ;;
        esac
    done
}

# Call the function
main
