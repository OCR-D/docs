# OCR-D Virtualbox

## Deployment Infos

- Based on Xubuntu 18.04

```sh
# Install packages
sudo apt install git curl vim make zsh htop xclip apt-file silversearcher-ag

# Remove cruft
rm -rf $HOME/{Music,Pictures,Public,Templates,Videos}
sudo apt remove libreoffice-{core,writer,calc} thundrbird pidgin-data libflite1

# Install dotfiles
git clone https://github.com/kba/dotfiles
echo "" > "$HOME/dotfiles/REPOLIST"
echo home-bin >> "$HOME/dotfiles/REPOLIST"
echo shcolor >> "$HOME/dotfiles/REPOLIST"
echo tmux-config >> "$HOME/dotfiles/REPOLIST"
echo zsh-config >> "$HOME/dotfiles/REPOLIST"
echo vim-config >> "$HOME/dotfiles/REPOLIST"
echo git-config >> "$HOME/dotfiles/REPOLIST"
cd dotfiles;./dotfiles.sh clone;./dottfiles.sh init
```
