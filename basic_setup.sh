#!/bin/bash

# Function to run commands and display status messages
install_and_report() {
    local app_name=$1
    local install_command=$2
    local log_file=$3
    
    echo "Starting installation of $app_name..."
    
    {
        echo "Installing $app_name..."
        eval "$install_command"
        if [ $? -eq 0 ]; then
            echo "$app_name installation completed successfully."
        else
            echo "$app_name installation failed." >&2
        fi
    } >> "$log_file" 2>&1

    echo "$app_name installation process is complete."
}

# Log file for installation outputs
log_file="install_log.txt"
> "$log_file"

# System updates
echo "--------------------------- UPDATING OS ----------------------------"
install_and_report "System Updates" "
    sudo apt-get update -y &&
    sudo apt-get upgrade -y
" "$log_file"


echo "----------------- INSTALLING APT BASED PACKAGES ---------------------"
# Install APT packages
install_and_report "APT Packages" "sudo apt-get install -y neofetch zsh" "$log_file"


echo "---------- INSTALLING VERSION MANAGERS : NODE , PYTHON ---------------"
# Install NVM
install_and_report "NVM" "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash" "$log_file"

# Install Miniconda
install_and_report "Miniconda" "
    mkdir -p ~/miniconda3 &&
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh &&
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 &&
    rm ~/miniconda3/miniconda.sh &&
    ~/miniconda3/bin/conda init bash &&
    ~/miniconda3/bin/conda init zsh
" "$log_file"

echo "-------------------- INSTALLING CODE EDITORS XD -----------------------"

# Install ZED Editor
install_and_report "ZED Editor" "curl -f https://zed.dev/install.sh | sh" "$log_file"

# Install Visual Studio Code
install_and_report "Visual Studio Code" "
    sudo apt-get install -y software-properties-common apt-transport-https wget &&
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - &&
    sudo sh -c 'echo \"deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main\" > /etc/apt/sources.list.d/vscode.list' &&
    sudo apt-get update &&
    sudo apt-get install -y code
" "$log_file"


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
" "$log_file"

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
" "$log_file"

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
