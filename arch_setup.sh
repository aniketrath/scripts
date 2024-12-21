#!/usr/bin/env bash

# Check if the script is run as root (sudo) or not
if [ "$(id -u)" -ne 0 ]; then
    echo "This script needs to be run as root (use sudo)."
    exit 1
fi

# Define color codes
RED='\033[31m'
GREEN='\033[32m'
RESET='\033[0m'

# Function to display percentage completion progress
loading_percentage() {
    local message="$1"
    local total_steps=$2
    local current_step=0
    local last_percentage=0
    local progress_bar_length=50  # Progress bar length in characters

    # Print the application name in green
    echo -e "${GREEN}$message${RESET}"
    echo  # Newline for the message
    while [ $current_step -le $total_steps ]; do
        local percentage=$(( 100 * current_step / total_steps ))

        if [ $percentage -gt $last_percentage ]; then
            echo -ne "\rProgress : "
            local progress_length=$(( percentage * progress_bar_length / 100 ))
            local remaining_length=$(( progress_bar_length - progress_length ))
            local progress=$(printf "%-${progress_length}s" "#" | tr " " "#")
            local remaining=$(printf "%-${remaining_length}s" " " | tr " " "-")
            echo -ne "${RED}[${progress}${remaining}] ${percentage}%${RESET}"
            last_percentage=$percentage
        fi

        sleep 0.1
        current_step=$((current_step + 1))
    done

    echo -e "\rProgress : [##################################################] 100%"
}

# Function to check if a package is installed using pacman -Q
is_package_installed() {
    local package_name=$1
    pacman -Q $package_name &> /dev/null
    return $?
}

# Function to check if a command is available
is_command_installed() {
    local command_name=$1
    command -v $command_name &> /dev/null
    return $?
}

install_and_report() {
    local app_name=$1
    local install_command=$2
    local total_steps=$3
    local log_file=$4
    local check_command=$5

    # Check if the tool/command is already installed
    if is_command_installed "$check_command"; then
        echo -e "${GREEN}$app_name is already installed.${RESET}"
        return
    fi

    echo "$(date +'%Y-%m-%d %H:%M:%S') - Installing $app_name..." >> "$log_file"
    loading_percentage "$app_name installation in progress..." $total_steps &
    loading_pid=$!

    {
        echo "Installing $app_name..."
        eval "$install_command"
        if [ $? -eq 0 ]; then
            echo "$(date +'%Y-%m-%d %H:%M:%S') - $app_name installation completed successfully." >> "$log_file"
        else
            echo "$(date +'%Y-%m-%d %H:%M:%S') - $app_name installation failed." >&2
            echo "$(date +'%Y-%m-%d %H:%M:%S') - $app_name installation failed." >> "$log_file"
        fi
    } >> "$log_file" 2>&1

    wait $loading_pid
    sleep 0.5
    echo
    echo -e "${GREEN}Installation Complete.${RESET}"
}

log_file="install_log.txt"
> "$log_file"

echo "--------------------------- UPDATING SYSTEM ----------------------------"
install_and_report "System Updates" "sudo pacman -Syu --noconfirm" 10 "$log_file" "base"

echo "---------------- INSTALLING PACKAGES ------------------"
cat << 'EOF' | tee >(echo -e "\033[32m")
# THE FOLLOWING WILL BE INSTALLED:
-> Neofetch
-> Zsh
-> Git
-> Curl
-> Wget
EOF

# Install each package separately using pacman and sudo
install_and_report "Neofetch" "sudo pacman -S --noconfirm neofetch" 1 "$log_file" "neofetch"
install_and_report "Zsh" "sudo pacman -S --noconfirm zsh" 1 "$log_file" "zsh"
install_and_report "Git" "sudo pacman -S --noconfirm git" 1 "$log_file" "git"
install_and_report "Curl" "sudo pacman -S --noconfirm curl" 1 "$log_file" "curl"
install_and_report "Wget" "sudo pacman -S --noconfirm wget" 1 "$log_file" "wget"

echo "----------- INSTALLING VERSION MANAGERS: NODE, PYTHON -----------"
install_and_report "NVM" "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash" 10 "$log_file" "nvm"
install_and_report "Miniconda" "
    mkdir -p ~/miniconda3 &&
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh &&
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 &&
    rm ~/miniconda3/miniconda.sh &&
    ~/miniconda3/bin/conda init bash &&
    ~/miniconda3/bin/conda init zsh
" 20 "$log_file" "conda"

echo "------------------ INSTALLING CODE EDITORS --------------------"
install_and_report "ZED Editor" "curl -f https://zed.dev/install.sh | sh" 5 "$log_file" "zed"
install_and_report "Visual Studio Code" "
    sudo pacman -S --noconfirm code
" 10 "$log_file" "code"

echo "------------------- INSTALLING DOCKER -------------------"
install_and_report "Docker CLI" "
    sudo pacman -S --noconfirm docker &&
    systemctl enable docker &&
    systemctl start docker &&
    groupadd docker &&
    usermod -aG docker $USER &&
    newgrp docker
" 15 "$log_file" "docker"

echo "------------------ INSTALLING KUBEADM -------------------"
install_and_report "Kubeadm" "
    sudo pacman -S --noconfirm kubectl kubeadm kubelet &&
    systemctl enable --now kubelet
" 15 "$log_file" "kubectl"

echo "----------- UPDATING SHELL CONFIGS -----------"
ALIASES=$(cat << 'EOF'

# SCRIPT CREATED ALIASES:

alias kubectl="minikube kubectl --"
alias sysupdate="sudo pacman -Syu"
alias sysupgrade="sudo pacman -Syu"
alias sysinstall="sudo pacman -S --noconfirm"
alias sysremove="sudo pacman -Rns --noconfirm"
EOF
)

if ! grep -q '^alias kubectl' ~/.zshrc; then
  echo "$ALIASES" >> ~/.zshrc
  echo "Aliases added to .zshrc"
else
  echo "All Aliases are up to date in .zshrc"
fi

echo -e "\033[32mAll installations are complete. Check '$log_file' for details.\033[0m"

cat << 'EOF' | tee >(echo -e "${RED}")  # Ensure this part is colored green
Please change your shell and reload using the command

chsh /usr/bin/zsh
source ~/.zshrc

EOF

cat << 'EOF' | tee >(echo -e "\033[32m")  # Ensure this part is colored green
# THE FOLLOWING ALIASES HAVE BEEN GENERATED FOR EASIER USE :

alias kubectl                                  "minikube kubectl --"
alias sysupdate                                "sudo pacman -Syu"
alias sysupgrade                               "sudo pacman -Syu"
alias sysinstall                               "sudo pacman -S --noconfirm"
alias sysremove                                "sudo pacman -Rns --noconfirm"
------------------------------------------------------------------------------------
COMMANDS TO RUN POST SCRIPT :

nvm install --lts                               Install the latest LTS version
nvm use --lts                                   Use the latest LTS version
conda create --name env_base python=3.10        Create Base Env. with v=3.10
conda config --set auto_activate_base false     Prevent default conda env activation

-------------------------------------------------------------------------------------
MOREOVER, TO TRY OHMYZSH PLEASE RUN :
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
EOF
