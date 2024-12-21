#!/usr/bin/env bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script needs to be run as root (use sudo)."
    exit 1
fi

# Define color codes
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RESET='\033[0m'

# Detect package manager
detect_package_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    else
        echo "unsupported"
    fi
}

PACKAGE_MANAGER=$(detect_package_manager)

if [ "$PACKAGE_MANAGER" == "unsupported" ]; then
    echo -e "${RED}Unsupported Linux distribution. Exiting.${RESET}"
    exit 1
fi

# Function to display the main menu
show_menu() {
    echo -e "${BLUE}Select an option:${RESET}"
    echo "1. Update System"
    echo "2. Install Common Tools (Neofetch, Git, Curl, Wget, Zsh)"
    echo "3. Install Version Managers (NVM, Miniconda)"
    echo "4. Install Editors (ZED, VS Code, Wireshark) using Flatpak"
    echo "5. Install Docker"
    echo "6. Install Kubernetes (Kubeadm)"
    echo "7. Install Zinit for Zsh"
    echo "8. Install Network Tools (Netcat, Nmap, Traceroute, Iperf)"
    echo "9. Add Aliases to Shell Config"
    echo "10. Install and Enable Flatpak"
    echo "11. Exit"
}

# Function to handle menu selection
handle_menu_choice() {
    case $1 in
    1)
        update_system
        ;;
    2)
        install_common_tools
        ;;
    3)
        install_version_managers
        ;;
    4)
        install_editors_flatpak
        ;;
    5)
        install_docker
        ;;
    6)
        install_kubernetes
        ;;
    7)
        install_zinit
        ;;
    8)
        install_network_tools
        ;;
    9)
        add_shell_aliases
        ;;
    10)
        install_flatpak
        ;;
    11)
        echo "Exiting the script. Goodbye!"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Please select a valid option.${RESET}"
        ;;
    esac
}

# Functions for each menu option
update_system() {
    echo "Updating system..."
    case "$PACKAGE_MANAGER" in
    apt)
        sudo apt update && sudo apt upgrade -y
        ;;
    pacman)
        sudo pacman -Syu --noconfirm
        ;;
    yum)
        sudo yum update -y
        ;;
    dnf)
        sudo dnf upgrade --refresh -y
        ;;
    esac
    echo -e "${GREEN}System updated.${RESET}"
}

install_common_tools() {
    local tools=("neofetch" "zsh" "git" "curl" "wget")
    for tool in "${tools[@]}"; do
        echo "Installing $tool..."
        case "$PACKAGE_MANAGER" in
        apt)
            sudo apt install -y "$tool"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$tool"
            ;;
        yum)
            sudo yum install -y "$tool"
            ;;
        dnf)
            sudo dnf install -y "$tool"
            ;;
        esac
        echo -e "${GREEN}$tool installed.${RESET}"
    done
}

install_version_managers() {
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    echo "Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -u -p ~/miniconda3
    ~/miniconda3/bin/conda init
    echo -e "${GREEN}Version managers installed.${RESET}"
}

install_editors_flatpak() {
    echo "Installing editors and tools using Flatpak..."
    flatpak install -y flathub com.zed.Zed
    flatpak install -y flathub com.visualstudio.code
    flatpak install -y flathub org.wireshark.Wireshark
    echo -e "${GREEN}Editors and tools installed via Flatpak.${RESET}"
}

install_docker() {
    echo "Installing Docker..."
    # Remove conflicting containerd package if exists
    sudo apt-get remove --purge -y containerd
    sudo apt-get clean
    sudo apt-get update
    
    # Install Docker dependencies and Docker itself
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key and repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    
    # Install Docker and containerd.io
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Enable and start Docker service
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    echo -e "${GREEN}Docker installed. You might need to restart your session.${RESET}"
}

install_kubernetes() {
    echo "Installing Kubernetes..."
    case "$PACKAGE_MANAGER" in
    apt)
        sudo apt install -y kubectl kubeadm kubelet
        ;;
    pacman)
        sudo pacman -S --noconfirm kubectl kubeadm kubelet
        ;;
    yum)
        sudo yum install -y kubectl kubeadm kubelet
        ;;
    dnf)
        sudo dnf install -y kubectl kubeadm kubelet
        ;;
    esac
    sudo systemctl enable --now kubelet
    echo -e "${GREEN}Kubernetes installed.${RESET}"
}

install_zinit() {
    echo "Installing Zinit..."
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    zinit self-update
    echo -e "${GREEN}Zinit installed.${RESET}"
}

install_network_tools() {
    local tools=("netcat" "nmap" "traceroute" "iperf3")
    for tool in "${tools[@]}"; do
        echo "Installing $tool..."
        case "$PACKAGE_MANAGER" in
        apt)
            sudo apt install -y "$tool"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$tool"
            ;;
        yum)
            sudo yum install -y "$tool"
            ;;
        dnf)
            sudo dnf install -y "$tool"
            ;;
        esac
        echo -e "${GREEN}$tool installed.${RESET}"
    done
}

install_flatpak() {
    echo "Installing and enabling Flatpak..."
    case "$PACKAGE_MANAGER" in
    apt)
        sudo apt install -y flatpak
        ;;
    pacman)
        sudo pacman -S --noconfirm flatpak
        ;;
    yum)
        sudo yum install -y flatpak
        ;;
    dnf)
        sudo dnf install -y flatpak
        ;;
    esac
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "${GREEN}Flatpak installed and enabled.${RESET}"
}

add_shell_aliases() {
    echo "Adding aliases to ~/.zshrc..."
    cat <<EOF >>~/.zshrc

# Added by installation script
alias kubectl="minikube kubectl --"
alias sysupdate="sudo $PACKAGE_MANAGER -Syu"
alias sysinstall="sudo $PACKAGE_MANAGER -S --noconfirm"
EOF
    echo -e "${GREEN}Aliases added. Please reload your shell using 'source ~/.zshrc'.${RESET}"
}

# Main script logic
if [[ "$1" == "all" ]]; then
    update_system
    install_common_tools
    install_version_managers
    install_editors_flatpak
    install_docker
    install_kubernetes
    install_zinit
    install_network_tools
    install_flatpak
    add_shell_aliases
    echo -e "${GREEN}All functions executed successfully.${RESET}"
    exit 0
fi

# Main script loop
while true; do
    show_menu
    read -p "Enter your choice(s) (space-separated for multiple options): " -a choices
    for choice in "${choices[@]}"; do
        handle_menu_choice "$choice"
    done
done
