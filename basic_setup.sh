#!/usr/bin/env bash

# Check if the script is run as root (sudo) or not
if [ "$(id -u)" -ne 0 ]; then
    echo "This script needs to be run as root (use sudo)."
    exit 1
fi

# Function to display percentage completion progress
loading_percentage() {
    local message="$1"
    local total_steps=$2
    local current_step=0
    local last_percentage=0
    local progress_bar_length=50  # Progress bar length in characters

    echo -n "$message"  # Print message once
    echo  # Newline for the message

    while [ $current_step -le $total_steps ]; do
        # Calculate percentage
        local percentage=$(( 100 * current_step / total_steps ))

        # Print progress bar only if percentage has changed
        if [ $percentage -gt $last_percentage ]; then
            # Clear the line first by moving the cursor back to the beginning
            echo -ne "\rProgress : "

            # Calculate the number of characters to represent the progress
            local progress_length=$(( percentage * progress_bar_length / 100 ))
            local remaining_length=$(( progress_bar_length - progress_length ))
            local progress=$(printf "%-${progress_length}s" "#" | tr " " "#")
            local remaining=$(printf "%-${remaining_length}s" " " | tr " " "-")

            # Print the updated progress bar
            echo -ne "[${progress}${remaining}] ${percentage}%"
            last_percentage=$percentage
        fi

        # Simulate some work being done (replace this with actual task progress)
        sleep 0.1  # Sleep to simulate the process running
        current_step=$((current_step + 1))
    done
    echo " "
    echo " "
    echo "Installation Complete."
}

# Function to run commands and display status messages with loading percentage
install_and_report() {
    local app_name=$1
    local install_command=$2
    local total_steps=$3
    local log_file=$4                                                                                                                                                                                                                   # Start the loading percentage progress in the background
    loading_percentage "$app_name installation in progress..." $total_steps &
    loading_pid=$!

    {
        # Run the installation command
        echo "Installing $app_name..."
        eval "$install_command"
        if [ $? -eq 0 ]; then
            echo "$app_name installation completed successfully."
        else
            echo "$app_name installation failed." >&2
        fi
    } >> "$log_file" 2>&1

    # Wait for loading percentage to finish
    wait $loading_pid
    echo
    echo "$app_name installation process is complete."
}

# Log file for installation outputs
log_file="install_log.txt"
> "$log_file"  # Ensure the log file exists and is empty at the start

# System updates
echo "--------------------------- UPDATING OS ----------------------------"
install_and_report "System Updates" "
    sudo apt-get update -y &&
    sudo apt-get upgrade -y
" 10 "$log_file"  # Provide a number for total_steps, not the log file

echo "----------------- INSTALLING APT BASED PACKAGES ---------------------"
# Install APT packages
install_and_report "APT Packages" "sudo apt-get install -y neofetch zsh" 5 "$log_file"  # Example of a smaller number

echo "---------- INSTALLING VERSION MANAGERS : NODE , PYTHON ---------------"
# Install NVM
install_and_report "NVM" "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash" 10 "$log_file"

# Install Miniconda
install_and_report "Miniconda" "
    mkdir -p ~/miniconda3 &&
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh &&
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 &&
    rm ~/miniconda3/miniconda.sh &&
    ~/miniconda3/bin/conda init bash &&
    ~/miniconda3/bin/conda init zsh
" 20 "$log_file"  # Adjust this as needed

echo "-------------------- INSTALLING CODE EDITORS XD -----------------------"
# Install ZED Editor
install_and_report "ZED Editor" "curl -f https://zed.dev/install.sh | sh" 5 "$log_file"

# Install Visual Studio Code
install_and_report "Visual Studio Code" "
    sudo apt-get install -y software-properties-common apt-transport-https wget &&
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - &&
    sudo sh -c 'echo \"deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main\" > /etc/apt/sources.list.d/vscode.list' &&
    sudo apt-get update &&
    sudo apt-get install -y code
" 10 "$log_file"

echo "---------------------- INSTALLING WORKING ENVs --------------------------"
# Install Docker CLI
install_and_report "Docker CLI" "
    sudo apt-get update &&
    sudo apt-get install -y ca-certificates curl &&
    sudo install -m 0755 -d /etc/apt/keyrings &&
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &&
    sudo chmod a+r /etc/apt/keyrings/docker.asc &&
    echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \$(. /etc/os-release && echo \"\$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
    sudo apt-get update &&
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &&
    sudo groupadd docker &&
    sudo usermod -aG docker $USER &&
    newgrp docker
" 15 "$log_file"  # Adjust the number for Docker

# Install Kubeadm
install_and_report "Kubeadm" "
    sudo apt-get update &&
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg &&
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg &&
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list &&
    sudo apt-get update &&
    sudo apt-get install -y kubelet kubeadm kubectl &&
    sudo apt-mark hold kubelet kubeadm kubectl &&
    sudo systemctl enable --now kubelet &&
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb &&
    sudo dpkg -i minikube_latest_amd64.deb &&
    rm minikube_latest_amd64.deb
" 15 "$log_file"  # Adjust the number for Kubeadm

# Update .bashrc and .zshrc
echo "---------- UPDATING .BASHRC AND .ZSHRC ---------------"
ALIASES=$(cat << 'EOF'

# USER CREATED ALIASES :

alias kubectl="minikube kubectl --"
alias appupdate="sudo apt-get update -y"
alias appupgrade="sudo apt-get upgrade -y"
alias appinstall="sudo apt-get install -y"
alias appremove="sudo apt-get remove -y"

EOF
)

if ! grep -q '^alias kubectl' ~/.bashrc; then
  echo "$ALIASES" >> ~/.bashrc
  echo "Aliases added to .bashrc"
else
  echo "All Aliases are up to date in ~/.bashrc"
fi

if ! grep -q '^alias kubectl' ~/.zshrc; then
  echo "$ALIASES" >> ~/.zshrc
  echo "Aliases added to .zshrc"
else
  echo "All Aliases are up to date in .zshrc"
fi

# Source .bashrc and .zshrc to apply changes
echo "RELOADING SHELLS---------"
source ~/.bashrc
source ~/.zshrc
echo "SHELLS RELOADED---------"

# Notify user
echo "All installations are complete. Check '$log_file' for details."
cat << 'EOF'

# THE FOLLOWING ALIASES HAVE BEEN GENERATED FOR EASIER USE :  :

alias kubectl                                  "minikube kubectl --"
alias appupdate                                "sudo apt-get update -y"
alias appupgrade                               "sudo apt-get upgrade -y"
alias appinstall                               "sudo apt-get install -y"
alias appremove                                "sudo apt-get remove -y"

------------------------------------------------------------------------------------
COMMANDS TO RUN POST SCRIPT :

nvm install --lts                               Install the latest LTS version
nvm use --lts                                   Use the latest LTS version
conda create --name env_base python=3.10        Create Base Env. with v=3.10
conda config --set auto_activate_base false     Prevent default conda env activation

-------------------------------------------------------------------------------------
MOREOVER , TO TRY OHMYZSH PLEASE RUN :
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
EOF
