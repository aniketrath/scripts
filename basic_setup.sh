#! /bin/bash

# ---------- UPDATING OS ---------------
echo "---------- UPDATING OS ---------------"
sudo apt-get update -y
sudo apt-get upgrade -y


# ---------- INSTALL PACKAGES ---------------

echo "---------- INSTALLING APT_PACKAGES ---------------"
sudo apt-get install -y neofetch zsh


echo "----------- INSTALLING NVM -----------"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash || { echo "Failed to install NVM."; exit 1; }

echo "---------- INSTALLING MINICONDA ---------------"
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh || { echo "Failed to download Miniconda installer."; exit 1; }
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 || { echo "Failed to install Miniconda."; exit 1; }
rm ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash || { echo "Failed to initialize Conda for bash."; exit 1; }
~/miniconda3/bin/conda init zsh || { echo "Failed to initialize Conda for zsh."; exit 1; }

echo "---------- INSTALLING ZED EDITOR ---------------"
curl -f https://zed.dev/install.sh | sh

echo "---------- INSTALLING VS CODE ---------------"
trap 'error_handler "An error occurred during VS Code installation."' ERR
echo "Installing necessary packages..."
sudo apt-get install -y software-properties-common apt-transport-https wget || { echo "Failed to install necessary packages."; exit 1; }
echo "Importing Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - || { echo "Failed to import Microsoft GPG key."; exit 1; }
echo "Adding VS Code repository..."
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' || { echo "Failed to add VS Code repository."; exit 1; }
echo "Updating package list..."
sudo apt-get update || { echo "Failed to update package list."; exit 1; }
echo "Installing Visual Studio Code..."
sudo apt-get install -y code || { echo "Failed to install Visual Studio Code."; exit 1; }
echo "Visual Studio Code has been successfully installed."


echo "-------- INSTALLING DOCKER CLI ---------- "
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world


echo "-----------INSTALING KUBEADM ------------"
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
rm minikube_latest_amd64.deb 


# ---------- UPDATING .BASHRC AND .ZSHRC ---------------
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

# Check if the aliases are already present
if ! grep -q '^alias kubectl' ~/.bashrc; then
  echo "$ALIASES" >> ~/.bashrc
  echo "Aliases added to .bashrc"
else
  echo "Aliases already present in .bashrc"
fi

if ! grep -q '^alias kubectl' ~/.zshrc; then
  echo "$ALIASES" >> ~/.zshrc
  echo "Aliases added to .zshrc"
else
  echo "Aliases already present in .zshrc"
fi
# Source .bashrc to apply changes
echo "------RELOADING SHELLS---------"
source ~/.bashrc
source ~/.zshrc

# Optionally, install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || { echo "Failed to install Oh My Zsh."; exit 1; }


echo "---------------------- THANK YOU --------------------------"