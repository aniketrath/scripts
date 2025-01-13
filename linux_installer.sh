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
    if command -v apt-get &>/dev/null; then
        echo "apt-get"
    elif command -v apt &>/dev/null; then
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

# Pre-check function to install required dependencies like apt-utils, curl, wget, etc.
install_dependencies() {
    local dependencies=("apt-utils" "curl" "wget" "git" "zsh" "flatpak")

    echo -e "${YELLOW}Checking for missing dependencies...${RESET}"
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "${YELLOW}$dep not found. Installing...${RESET}"
            case "$PACKAGE_MANAGER" in
            apt|apt-get) apt-get install -y -qq "$dep" >/dev/null ;;
            pacman) pacman -S --noconfirm --quiet "$dep" >/dev/null ;;
            yum) yum install -q -y "$dep" >/dev/null ;;
            dnf) dnf install -q -y "$dep" >/dev/null ;;
            *) echo -e "${RED}Unsupported package manager. Could not install $dep.${RESET}" ;;
            esac
            echo -e "${GREEN}$dep installed.${RESET}"
        fi
    done
}

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
        echo "Exiting the script. Goodbye!"
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
    add_shell_aliases
    echo -e "${GREEN}All tasks completed successfully.${RESET}"
}

# Functions for each menu option
update_system() {
    echo "Updating system..."
    case "$PACKAGE_MANAGER" in
    apt|apt-get)  apt-get update -qq >/dev/null &&  apt-get upgrade -y -qq >/dev/null ;;
    pacman)  pacman -Syu --noconfirm --quiet >/dev/null ;;
    yum)  yum update -q -y >/dev/null ;;
    dnf)  dnf upgrade --refresh -q -y >/dev/null ;;
    *)
        echo -e "${RED}Unsupported package manager. Could not update system.${RESET}"
        exit 1
        ;;
    esac
    echo -e "${GREEN}System updated.${RESET}"
}

install_common_tools() {
    local tools=("neofetch" "zsh" "git" "curl" "wget")
    for tool in "${tools[@]}"; do
        echo "Installing $tool..."
        case "$PACKAGE_MANAGER" in
        apt|apt-get)  apt-get install -y -qq "$tool" >/dev/null ;;
        pacman)  pacman -S --noconfirm --quiet "$tool" >/dev/null ;;
        yum)  yum install -q -y "$tool" >/dev/null ;;
        dnf)  dnf install -q -y "$tool" >/dev/null ;;
        *)
            echo -e "${RED}Unsupported package manager. Could not install $tool.${RESET}"
            exit 1
            ;;
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
    # Check if Flatpak is installed, if not install it
    if ! command -v flatpak &>/dev/null; then
        echo -e "${YELLOW}Flatpak not found, installing Flatpak...${RESET}"
        install_flatpak
    fi

    echo "Installing editors and tools using Flatpak..."
    flatpak install -y -q flathub org.zed.Zed
    flatpak install -y -q flathub com.visualstudio.code
    flatpak install -y -q flathub org.wireshark.Wireshark
    echo -e "${GREEN}Editors and tools installed via Flatpak.${RESET}"
}

install_docker() {
    echo "Installing Docker..."
    case "$PACKAGE_MANAGER" in
    apt|apt-get)  apt-get purge -y -qq docker docker.io containerd.io >/dev/null || true
                  apt-get autoremove -y -qq >/dev/null || true
                  apt-get install -y -qq docker.io >/dev/null ;;
    pacman)  pacman -Rns --noconfirm --quiet docker >/dev/null || true
             pacman -S --noconfirm --quiet docker >/dev/null ;;
    yum)  yum remove -q -y docker docker-compose >/dev/null || true
          yum install -q -y docker >/dev/null ;;
    dnf)  dnf remove -q -y docker docker-compose >/dev/null || true
          dnf install -q -y docker >/dev/null ;;
    *)
        echo -e "${RED}Unsupported package manager. Could not install Docker.${RESET}"
        exit 1
        ;;
    esac
     systemctl enable --now docker >/dev/null
     usermod -aG docker "$USER"
    echo -e "${GREEN}Docker installed. Please restart your session.${RESET}"
}

install_kubernetes() {
    echo "Installing Kubernetes (kubectl)..."

    # Specify the version and architecture for kubectl
    KUBECTL_VERSION="v1.32.0"
    KUBECTL_ARCH="amd64"
    KUBECTL_BIN="kubectl"

    # Download the kubectl binary using curl
    echo "Downloading kubectl version $KUBECTL_VERSION..."
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/${KUBECTL_BIN}" >/dev/null 2>&1

    if [[ -f "$KUBECTL_BIN" ]]; then
        # Make the binary executable
        chmod +x "$KUBECTL_BIN"
        # Move it to a directory in the PATH (e.g., /usr/local/bin)
         mv "$KUBECTL_BIN" /usr/local/bin/
        # Verify installation
        if command -v kubectl &>/dev/null; then
            echo -e "${GREEN}Kubernetes (kubectl) version $KUBECTL_VERSION installed successfully.${RESET}"
        else
            echo -e "${RED}Failed to install kubectl. Please check the installation steps.${RESET}"
        fi
    else
        echo -e "${RED}Failed to download kubectl binary. Please check the URL or your network connection.${RESET}"
    fi
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
        apt|apt-get)  apt-get install -y -qq "$tool" >/dev/null ;;
        pacman)  pacman -S --noconfirm --quiet "$tool" >/dev/null ;;
        yum)  yum install -q -y "$tool" >/dev/null ;;
        dnf)  dnf install -q -y "$tool" >/dev/null ;;
        *)
            echo -e "${RED}Unsupported package manager. Could not install $tool.${RESET}"
            exit 1
            ;;
        esac
        echo -e "${GREEN}$tool installed.${RESET}"
    done
}

add_shell_aliases() {
    echo "Adding aliases to ~/.zshrc..."
    case "$PACKAGE_MANAGER" in
    apt|apt-get) alias_update=" apt-get update" ; alias_install=" apt-get install -y" ;;
    pacman) alias_update=" pacman -Syu" ; alias_install=" pacman -S --noconfirm" ;;
    yum) alias_update=" yum update" ; alias_install=" yum install -y" ;;
    dnf) alias_update=" dnf upgrade" ; alias_install=" dnf install -y" ;;
    esac
    cat <<EOF >>~/.zshrc

# Added by installation script
alias sysupdate="$alias_update"
alias sysinstall="$alias_install"
EOF
    echo -e "${GREEN}Aliases added. Please reload your shell using 'source ~/.zshrc'.${RESET}"
}

# Main script logic
if [[ "$1" == "all" ]]; then
    install_dependencies
    run_all_functions
    exit 0
fi

# Main script loop
while true; do
    install_dependencies
    show_menu
    read -p "Enter your choice: " choice
    handle_menu_choice "$choice"
done
