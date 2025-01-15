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
    "glances"
    "eza"
    "bat")
    
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

install_docker_desktop() {
    echo -e "${YELLOW}System : Setting up Docker: Desktop ${RESET}"
    
    # Install required tools
    echo -e "${YELLOW}System : Installing prerequisites ${RESET}"
    apt-get update -y &> /dev/null
    apt-get install -y gnome-terminal ca-certificates curl &> /dev/null

    # Add Docker's official GPG key
    echo -e "${YELLOW}System : Adding Docker's GPG key ${RESET}"
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources
    echo -e "${YELLOW}System : Adding Docker's repository ${RESET}"
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y &> /dev/null

    # Define URL and output file
    local url="https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"
    local deb_file="docker-desktop-amd64.deb"

    # Download the .deb file
    echo -e "${YELLOW}System : Downloading Docker: Desktop ${RESET}"
    wget -O "$deb_file" "$url"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}System : Failed to download Docker Desktop. Exiting ${RESET}"
        return 1
    fi

    # Install the .deb package
    echo -e "${YELLOW}System : Installing Docker: Desktop ${RESET}"
    dpkg -i "$deb_file" &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}System : dpkg encountered an issue, fixing dependencies ${RESET}"
        apt-get install -f -y
    fi

    # Cleanup
    echo -e "${YELLOW}System : Cleaning up ${RESET}"
    rm -f "$deb_file"

    echo -e "${YELLOW}System : Docker Desktop setup complete! ${RESET}"
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
