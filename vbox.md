# OCR-D Virtualbox

<!-- BEGIN-MARKDOWN-TOC -->
* [Deployment Infos](#deployment-infos)
	* [Base System](#base-system)
	* [Terminal setup](#terminal-setup)
	* [Tesseract](#tesseract)
	* [Python](#python)
		* [virtualenv](#virtualenv)
		* [core](#core)

<!-- END-MARKDOWN-TOC -->

## Deployment Infos

- Based on Xubuntu 18.04

Username: **`ocrd`**
Password: **`ocrd`**

### Base System

```sh
# Install packages
sudo apt install git curl vim make zsh htop xclip apt-file silversearcher-ag clipit terminator

# Remove cruft
rm -rf $HOME/{Music,Pictures,Public,Templates,Videos}
sudo apt remove libreoffice-{core,writer,calc} thundrbird pidgin-data libflite1

# Upgrade
sudo apt update
sudo apt upgrade
```

### Terminal setup

```sh
# Install dotfiles
git clone https://github.com/kba/dotfiles
cd dotfiles
echo "" > REPOLIST
echo home-bin >> REPOLIST
echo shcolor >> REPOLIST
echo zsh-config >> REPOLIST
echo vim-config >> REPOLIST
echo git-config >> REPOLIST
./dotfiles.sh clone
./dottfiles.sh init

# Set zsh
chsh -s /bin/zsh

# Download a nice font from http://nerdfonts.com and set up in terminal emulator

# --> Reboot
```

### Tesseract

```sh
sudo apt install libtesseract{4,-dev} tesseract-ocr{,-eng,-deu}
```

### Python

#### virtualenv

```sh
sudo apt install python3-virtualenv python-virtualenv
cd $HOME
virtualenv -p python3.6 venv3
virtualenv -p python2.7 venv2
```

#### core

```sh
source $HOME/venv2
```
