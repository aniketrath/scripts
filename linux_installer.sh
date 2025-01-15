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

# Animated Text
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

install_kubernetes() {

    echo -e "${YELLOW}System : Installing Kubernetes${RESET}"

    # Update system package list and install prerequisites
    system_patch
    apt-get install -y apt-transport-https ca-certificates curl gnupg &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}System : Failed to install prerequisites. Exiting.${RESET}"
        return 1
    fi

    # Add Kubernetes apt key
    echo -e "${YELLOW}System : Adding Kubernetes APT key${RESET}"
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}System : Failed to add Kubernetes APT key. Exiting.${RESET}"
        return 1
    fi
    chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # Add Kubernetes apt repository
    echo -e "${YELLOW}System : Adding Kubernetes APT repository${RESET}"
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list &> /dev/null
    chmod 644 /etc/apt/sources.list.d/kubernetes.list

    # Update package list again
    system_patch

    # Install kubectl
    echo -e "${YELLOW}System : Installing kubectl${RESET}"
    apt-get install -y kubectl &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}System : Failed to install kubectl. Exiting.${RESET}"
        return 1
    fi

    echo -e "${GREEN}System : Kubernetes (kubectl) Installed Successfully!${RESET}"
}

setup_device() {
    echo -e "${BLUE}System : Setting Up as a New Device ${RESET}\n"
    echo -e "${BLUE}System : All the packages and tools offered in this script will be installed. ${RESET}\n"
    system_patch
    install_base_package
    install_docker_desktop
    install_kubernetes
}

# Parse Flags Function
parse_flags() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --setup-device)
                setup_device
                ;;
            --patch-system)
                system_patch
                ;;
            --install-docker)
                install_docker_desktop
                ;;
            --install-kubernetes)
                install_kubernetes
                ;;
            --install-base-packages)
                install_base_package
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Available options:"
                echo "  --setup-device          Run device setup"
                echo "  --patch-system          Update and upgrade all packages"
                echo "  --install-docker        Install Docker Engine and Desktop"
                echo "  --install-kubernetes    Install Kubernetes (kubectl)"
                echo "  --install-base-packages Install required base packages"
                echo "  --help, -h              Display this help message"
                exit 0
                ;;
            *)
                echo "Invalid option: $1"
                echo "Use --help to see available options."
                exit 1
                ;;
        esac
        shift # Move to the next argument
    done
}


# Main Function
main() {
    animated_text_dependencies
    ascii_animate "H E L L O"

    # If script is run with arguments (flags)
    if [[ $# -gt 0 ]]; then
        parse_flags "$@"
        exit 0
    fi

    local OPTIONS=(
        "Patch the System [ Update all the packages ]"
        "Install Required Base Packages"
        "Install Docker Engine"
        "Install Kubernetes"
        "Set Aliases"
        "Set up the System"
    )

    PS3="Choose an option: "

    select CHOICE in "${OPTIONS[@]}"; do
        case $REPLY in
            1) system_patch ; break ;;
            2) install_base_package ; break ;;
            3) install_docker_desktop ; break ;;
            4) install_kubernetes ; break ;;
            5) echo "You chose: $CHOICE"; break ;;
            6) esetup_device ; break ;;
            *) echo "Invalid choice. Try again."; ;;
        esac
    done
}

# Call the function
main
