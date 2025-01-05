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
    1) update_system ;;
    2) install_common_tools ;;
    3) install_version_managers ;;
    4) install_editors_flatpak ;;
    5) install_docker ;;
    6) install_kubernetes ;;
    7) install_zinit ;;
    8) install_network_tools ;;
    9) add_shell_aliases ;;
    10) install_flatpak ;;
    11)
        echo -e "${GREEN}Exiting the script. Goodbye!${RESET}"
        exit 0
        ;;
    *) echo -e "${RED}Invalid choice. Please select a valid option.${RESET}" ;;
    esac
}

# Function to run all tasks sequentially
run_all_functions() {
    echo -e "${YELLOW}Running all functions sequentially...${RESET}"
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
    echo -e "${GREEN}All tasks completed successfully.${RESET}"
}

# Functions for each menu option
update_system() {
    echo "Updating system..."
    case "$PACKAGE_MANAGER" in
    apt) sudo apt update -qq >/dev/null && sudo apt upgrade -y -qq >/dev/null ;;
    pacman) sudo pacman -Syu --noconfirm --quiet >/dev/null ;;
    yum) sudo yum update -q -y >/dev/null ;;
    dnf) sudo dnf upgrade --refresh -q -y >/dev/null ;;
    esac
    echo -e "${GREEN}System updated.${RESET}"
}

install_common_tools() {
    local tools=("neofetch" "zsh" "git" "curl" "wget")
    for tool in "${tools[@]}"; do
        echo "Installing $tool..."
        case "$PACKAGE_MANAGER" in
        apt) sudo apt install -y -qq "$tool" >/dev/null ;;
        pacman) sudo pacman -S --noconfirm --quiet "$tool" >/dev/null ;;
        yum) sudo yum install -q -y "$tool" >/dev/null ;;
        dnf) sudo dnf install -q -y "$tool" >/dev/null ;;
        esac
        echo -e "${GREEN}$tool installed.${RESET}"
    done
}

install_version_managers() {
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash >/dev/null 2>&1
    echo "Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh >/dev/null 2>&1
    bash ~/miniconda.sh -b -u -p ~/miniconda3 >/dev/null 2>&1
    ~/miniconda3/bin/conda init >/dev/null 2>&1
    echo -e "${GREEN}Version managers installed.${RESET}"
}

install_editors_flatpak() {
    echo "Installing editors using Flatpak..."
    flatpak install -y -q flathub org.zed.Zed com.visualstudio.code org.wireshark.Wireshark >/dev/null
    echo -e "${GREEN}Editors installed.${RESET}"
}

install_docker() {
    echo "Installing Docker..."
    case "$PACKAGE_MANAGER" in
    apt) sudo apt purge -y -qq docker docker.io containerd.io >/dev/null || true
         sudo apt autoremove -y -qq >/dev/null || true
         sudo apt install -y -qq docker.io >/dev/null ;;
    pacman) sudo pacman -Rns --noconfirm --quiet docker >/dev/null || true
            sudo pacman -S --noconfirm --quiet docker >/dev/null ;;
    yum) sudo yum remove -q -y docker docker-compose >/dev/null || true
         sudo yum install -q -y docker >/dev/null ;;
    dnf) sudo dnf remove -q -y docker docker-compose >/dev/null || true
         sudo dnf install -q -y docker >/dev/null ;;
    esac
    sudo systemctl enable --now docker >/dev/null
    sudo usermod -aG docker "$USER"
    echo -e "${GREEN}Docker installed. Please restart your session.${RESET}"
}

install_kubernetes() {
    echo "Installing Kubernetes..."
    case "$PACKAGE_MANAGER" in
    apt) sudo apt install -y -qq kubectl kubeadm kubelet >/dev/null ;;
    pacman) sudo pacman -S --noconfirm --quiet kubectl kubeadm kubelet >/dev/null ;;
    yum) sudo yum install -q -y kubectl kubeadm kubelet >/dev/null ;;
    dnf) sudo dnf install -q -y kubectl kubeadm kubelet >/dev/null ;;
    esac
    sudo systemctl enable --now kubelet >/dev/null
    echo -e "${GREEN}Kubernetes installed.${RESET}"
}

install_zinit() {
    echo "Installing Zinit..."
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" >/dev/null 2>&1
    echo -e "${GREEN}Zinit installed.${RESET}"
}

install_network_tools() {
    local tools=("netcat" "nmap" "traceroute" "iperf3")
    for tool in "${tools[@]}"; do
        echo "Installing $tool..."
        case "$PACKAGE_MANAGER" in
        apt) sudo apt install -y -qq "$tool" >/dev/null ;;
        pacman) sudo pacman -S --noconfirm --quiet "$tool" >/dev/null ;;
        yum) sudo yum install -q -y "$tool" >/dev/null ;;
        dnf) sudo dnf install -q -y "$tool" >/dev/null ;;
        esac
        echo -e "${GREEN}$tool installed.${RESET}"
    done
}

install_flatpak() {
    echo "Installing and enabling Flatpak..."
    case "$PACKAGE_MANAGER" in
    apt) sudo apt install -y -qq flatpak >/dev/null ;;
    pacman) sudo pacman -S --noconfirm --quiet flatpak >/dev/null ;;
    yum) sudo yum install -q -y flatpak >/dev/null ;;
    dnf) sudo dnf install -q -y flatpak >/dev/null ;;
    esac
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null
    echo -e "${GREEN}Flatpak installed and enabled.${RESET}"
}

add_shell_aliases() {
    echo "Adding aliases to shell configuration..."
    cat <<EOF >>~/.zshrc
# Aliases added by script
alias sysupdate='sudo ${PACKAGE_MANAGER} update'
alias sysinstall='sudo ${PACKAGE_MANAGER} install'
EOF
    echo -e "${GREEN}Aliases added to ~/.zshrc.${RESET}"
}

# Main script logic
if [[ "$1" == "all" ]]; then
    run_all_functions
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
