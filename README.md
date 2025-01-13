
## Deployment

### debian_setup.sh

```bash
  git clone https://github.com/aniketrath/scripts.git;
  cd cripts;
  chmod 700 linux_installer.sh
  sudo ./linux_installer.sh
```

### zshrc

#### Make sure zshell is installed on your System
#### NOTE : These will need a Code-Font . Please Install before running it as it might leas to non-readable characters in ASCII

```bash
    git clone https://github.com/aniketrath/scripts.git;
    cd cripts;
    mv ~/.zshrc ~/.zshrc.bak
    cp .zshrc ~/.zshrc
    source ~/.zshrc
```
Close the current shell and open an new shell to make the necessary changes. the Application will also install and help you go through the Powerlevel 10k configuration

### .tmux.conf
#### Make sure tmux is installed on your System

Install Tmux Plugin Manager to install necessary plugins

```bash
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
Config can be placed in two locations :

```bash
    $HOME/.tmux.conf
```
or

```bash
    $XDG_CONFIG_HOME/.config/tmux/tmux.conf
```

Clone the repo and copy to the location of your choice :

```bash
    git clone https://github.com/aniketrath/scripts.git;
    cd cripts;
    mv ~/.zshrc ~/.zshrc.bak
    cp .tmux.conf < the locaation u need >
```




