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
        echo "Installing something Cool!"
        apt-get update &> /dev/null && apt-get install -y figlet &> /dev/null
    else
        echo "Done Installing"
    fi
}

# Animated Text
ascii_animate() {
    local input_text="$1"
    figlet -f "./fonts/Bloody.flf" -w 200 "$input_text"
}

# Install base packages
install_base_package() {
    local packages=(
    "wget" 
    "curl" 
    "git" 
    "vim" 
    "glances" 
    "eza" 
    "bat"
    "gnome-tweaks"
    "gnome-shell-extensions"
    "github-desktop"
    )

    wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
    sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" > /etc/apt/sources.list.d/shiftkey-packages.list'
    system_patch

    echo -e "${BLUE}The following packages will be installed:${RESET}"

    for package in "${packages[@]}"; do
        echo -e "${BLUE}$package${RESET}"
    done
    echo -e "${YELLOW}System : Installing Packages${RESET}\n"

    for package in "${packages[@]}"; do
        echo -e "${YELLOW}System : Installing ${package}${RESET}"
        apt-get install -y "${package}" &> /dev/null
        echo -e "${GREEN}System : ${package} Installed${RESET}"
    done
    echo -e "\n${GREEN}System : All Packages Installed Successfully${RESET}\n"

}

# Install All the .deb Files
install_extra_packages() {

    # Declare the associative array within the function
    declare -A list=(
        ["warp"]="https://app.warp.dev/download?package=deb"  
        ["vs-code"]="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"  
    )

    for package in "${!list[@]}"; do
        local download_link="${list[$package]}"
        local file_name="${package}.deb"  # Save the file as <package>.deb

        echo -e "${BLUE}Downloading $package from $download_link...${RESET}"

        curl -L -o "$file_name" "$download_link" &> /dev/null
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Download complete. Installing $package...${RESET}"

            apt-get install -y ./"$file_name" &> /dev/null
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}Encountered errors during installation of $package. Fixing dependencies...${RESET}"
                apt-get -f install -y &> /dev/null
                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}$package installed successfully after fixing dependencies.${RESET}"
                else
                    echo -e "${RED}Failed to fix dependencies for $package. Manual intervention required.${RESET}"
                fi
            else
                echo -e "${GREEN}$package installed successfully.${RESET}"
            fi
        else
            echo -e "${RED}Failed to download $package.${RESET}"
        fi
        # Cleanup downloaded file
        rm -f "$file_name"
    done
}

# Installing Jenkins Server
install_jenkins_service() {

    echo -e "${YELLOW}System: Setting Up Jenkins${RESET}"
    echo -e "${BLUE}System: Setting Up Dependencies${RESET}"

    apt-get install -y fontconfig openjdk-17-jre &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to install dependencies. Check your internet connection or package manager.${RESET}"
        return 1
    fi

    echo -e "${BLUE}System: Setting Up PPA and Keys${RESET}"

    wget -O /usr/share/keyrings/jenkins-keyring.asc \
        https://pkg.jenkins.io/debian/jenkins.io-2023.key &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download Jenkins key. Check your internet connection.${RESET}"
        return 1
    fi

    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | \
        tee /etc/apt/sources.list.d/jenkins.list > /dev/null

    echo -e "${BLUE}System: Updating package list${RESET}"
    apt-get update &> /dev/null

    echo -e "${YELLOW}System: Installing Jenkins Service${RESET}"
    apt-get install -y jenkins &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "\n${GREEN}System: Jenkins Installed Successfully${RESET}\n"
    else
        echo -e "\n${RED}System: Failed to install Jenkins. Check for issues manually.${RESET}\n"
        return 1
    fi
}

# System Patching
system_patch() {
    echo -e "${YELLOW}System : Updating Packages${RESET}"
    apt-get update &> /dev/null
    apt-get upgrade -y &> /dev/null
    echo -e "${GREEN}System : Updates Installed${RESET}"
}

# Docker installation
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
    wget -O "$deb_file" "$url" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}System : Failed to download Docker Desktop. Exiting ${RESET}"
        return 1
    fi

    # Install the .deb package
    echo -e "${YELLOW}System : Installing Docker: Desktop ${RESET}"
    apt-get install -y ./"$deb_file" &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}System : dpkg encountered an issue, fixing dependencies ${RESET}"
        apt-get install -f -y &> /dev/null
    fi

    # Cleanup
    echo -e "${YELLOW}System : Cleaning up ${RESET}"
    rm -f "$deb_file"

    echo -e "${GREEN}System : Docker Desktop setup complete! ${RESET}"
}

# Kubernetes installation
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

# New Device Setup : All installs 
setup_device() {
    echo -e "${BLUE}System : Setting Up as a New Device ${RESET}\n"
    echo -e "${BLUE}System : All the packages and tools offered in this script will be installed. ${RESET}\n"
    system_patch
    install_base_package
    install_extra_packages
    install_jenkins_service
    install_docker_desktop
    install_kubernetes
    add_aliases
}

#Setting up aliases
add_aliases() {

    local shell_rc
    # Detect whether the user is using bash or zsh
    if [[ -n "$ZSH_VERSION" ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi

    echo -e "${YELLOW}System : Adding aliases to $shell_rc${RESET}"

    # List of aliases to add
    declare -A aliases=(
        ["update"]="sudo apt-get update && sudo apt-get upgrade -y"
        ["install"]="sudo apt-get install -y"
        ["remove"]="sudo apt-get purge -y"
        ["clean"]="sudo apt-get autoclean -y"
        ["ls"]="eza"
        ["ll"]="eza -lah"
        ["cat"]="batcat"
    )

    # Loop through aliases and add them
    for alias_name in "${!aliases[@]}"; do
        local alias_cmd="alias $alias_name='${aliases[$alias_name]}'"

        # Check if the alias is already present
        if grep -q "$alias_cmd" "$shell_rc"; then
            echo -e "${BLUE}Alias '$alias_name' already exists in $shell_rc${RESET}"
        else
            echo "$alias_cmd" >> "$shell_rc"
            echo -e "${GREEN}Alias '$alias_name' added to $shell_rc${RESET}"
        fi
    done

    # Source the updated shell configuration file
    echo -e "${YELLOW}System : Reloading shell configuration${RESET}"
    source "$shell_rc"

    echo -e "${GREEN}System : All aliases have been added and are now available.${RESET}"
}

# Parse Flags Function
parse_flags() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --setup)
                setup_device
                exit 0
                ;;
            --patch)
                system_patch
                exit 0
                ;;
            --install-docker)
                install_docker_desktop
                exit 0
                ;;
            --install-kubernetes)
                install_kubernetes
                exit 0
                ;;
            --install-base)
                install_base_package
                exit 0
                ;;
            --install-extra)
                install_extra_packages
                exit 0
                ;;
            --install-jenkins)
                install_jenkins_service
                exit 0
                ;;
            --set-alias)
                add_aliases
                exit 0
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
        shift
    done
}

# Main Function
main() {
    animated_text_dependencies
    ascii_animate "H E L L O"

    if [[ $# -gt 0 ]]; then
        parse_flags "$@"
        exit 0
    fi

    local OPTIONS=(
        "Patch the System [ Update all the packages ]"
        "Install Required Base Packages"
        "Install Docker Engine"
        "Install Kubernetes"
        "Setup Jenkins Server"
        "Install Additional Packages Added by User [.deb]"
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
            5) install_jenkins_service ; break ;;
            6) install_extra_packages ; break ;; 
            7) add_aliases ; break ;; 
            8) setup_device ; break ;; 
            *) echo "Invalid choice. Try again." ;;
        esac
    done
}

# Call the main function
main "$@"