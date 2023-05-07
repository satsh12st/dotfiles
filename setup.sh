#!/bin/bash

# ==============================================================================
# Variables
# ==============================================================================

### Environment
readonly OS_NAME=`uname`
readonly KERNEL_RELEASE=`uname -r`

readonly IS_LINUX=`if [ "$OS_NAME" = "Linux" ] ; then echo true ; else echo false ; fi`
readonly IS_WSL=`if echo "$KERNEL_RELEASE" | grep -iq "microsoft" ; then echo true ; else echo false ; fi`

# ==============================================================================
# Process
# ==============================================================================

### If running this script on a non-supported OS
[ ! "$IS_LINUX" ] && echo "⛔ | This OS is not supported!" && exit 1

### Start setup
echo "🎉 | Start setup!"

### First sudo execute
if sudo -p "🔐 | Please enter your password: " echo > /dev/null 2>&1 ; then
  echo "👌 | Great! Password authentication succeeded!"
else
  echo "⛔ | Wrong password... Please try again"
  exit 1
fi

### Copy file to be placed in root
[ ! -e "/etc/wsl.conf" ] && sudo cp "./_/etc/wsl.conf" "/etc/wsl.conf" \
  && echo "👌 | Installed wsl.conf!" \
  || echo "👀 | wsl.conf already exists"

### Set timezone
sudo timedatectl set-timezone "Asia/Tokyo" \
  && echo "👌 | Timezone is set to "Asia/Tokyo"!" \
  || echo "⚠️ | Timezone could not be set"

### Create default directories
cd ~ \
  && mkdir -p \
    "Applications" \
    "Develop" \
    "Laboratory" \
    "Work" \
    "Workbench" \
    > /dev/null 2>&1 \
  && echo "👌 | Default directories have been created!" \
  || echo "⚠️ | Failed to create default directories"

### Update and install packages
sudo apt update > /dev/null 2>&1 \
  && sudo apt upgrade -y > /dev/null 2>&1 \
  && sudo apt install -y \
    build-essential \
    curl\
    git \
    peco \
    unzip \
    zip \
    zsh \
    > /dev/null 2>&1 \
  && echo "👌 | Packages have been Installed!" \
  || echo "⚠️ | Packages installation failed"

### Install Zinit
NO_INPUT=true NO_ANNEXES=true NO_EDIT=true bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" > /dev/null 2>&1 \
  && echo "👌 | Zinit has been Installed!" \
  || echo "⚠️ | Zinit installation failed"

### Install Starship
curl -sS https://starship.rs/install.sh | sh -s -- --yes > /dev/null 2>&1 \
  && echo "👌 | Starship has been Installed!" \
  || echo "⚠️ | Starship installation failed"

### Set default shell to ZSH
echo "🔐 | Set default shell to ZSH, please enter your password: "
chsh -s $(which zsh) > /dev/null 2>&1 \
  && echo "👌 | Default shell has been set to ZSH!" \
  || echo "⚠️ | Failed to set default shell"

### Install nvm
curl -sS https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash > /dev/null 2>&1 \
  && echo "👌 | nvm has been Installed!" \
  || echo "⚠️ | nvm installation failed"

### Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

### Install node.js LTS version
nvm install --lts > /dev/null 2>&1 \
  && echo "👌 | node.js has been Installed!" \
  || echo "⚠️ | node.js installation failed"

### Upgrade npm to latest version
npm install -g npm > /dev/null 2>&1 \
  && echo "👌 | npm has been upgraded!" \
  || echo "⚠️ | npm upgrade failed"

### Install Rustup
curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y > /dev/null 2>&1 \
  && echo "👌 | Rustup has been Installed!" \
  || echo "⚠️ | Rustup installation failed"


### Apply dotfiles
chezmoi apply --force > /dev/null 2>&1 \
  && echo "👌 | dotfiles have been applied!" \
  || echo "⚠️ | Failed to apply dotfiles"

### That's all!
echo "🏁 | All set up and ready to go!"
echo "🔃 | Please reload the shell"
