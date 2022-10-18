#!/bin/bash -eu

# ==============================================================================
# Variables
# ==============================================================================

### Environment
UNAME="$(uname)" # Get OS name
KERNEL="$(uname -r)" # Get kernel release

IS_LINUX="$(if [ "$UNAME" = "Linux" ] ; then echo "true" ; else echo "false" ; fi)"
IS_DARWIN="$(if [ "$UNAME" = "Darwin" ] ; then echo "true" ; else echo "false" ; fi)" # macOS
IS_WSL="$(if echo "$KERNEL" | grep -iq "microsoft" ; then echo "true" ; else echo "false" ; fi)"
IS_REMOTE_CONTAINER="${REMOTE_CONTAINERS:-"false"}"

# ==============================================================================
# If this script is running on a non-supported OS
# ==============================================================================

# Supports Linux and macOS
if ! ("$IS_LINUX" || "$IS_DARWIN") ; then
  echo "This OS is no longer supported and will be terminated"
  exit 1
fi

# ==============================================================================
# Get password
# ==============================================================================

# Disable in Container
if ! "$IS_REMOTE_CONTAINER" ; then
  echo "#------------------------------------------------#"
  echo "  Please enter your login password"
  echo "#------------------------------------------------#"

  read -sp "password for $USER: " password
  tty -s
  echo
  echo
fi

# ==============================================================================
# Set configurations
# ==============================================================================

### For WSL
if "$IS_WSL" && ! "$IS_REMOTE_CONTAINER" ; then
  echo "#------------------------------------------------#"
  echo "  Create /etc/wsl.conf and set default settings"
  echo "#------------------------------------------------#"
  echo

  if [ ! -e /etc/wsl.conf ]; then
    echo "$password" | sudo -S touch /etc/wsl.conf

    echo "$password" | sudo -S sh -c "echo '[Interop]' >> /etc/wsl.conf"
    echo "$password" | sudo -S sh -c "echo 'appendWindowsPath = false' >> /etc/wsl.conf"
  fi
fi

# ==============================================================================
# Install package manager
# ==============================================================================

### For macOS
if "$IS_DARWIN" ; then
  ### Install Homebrew
  echo "#------------------------------------------------#"
  echo "  Install Homebrew"
  echo "#------------------------------------------------#"
  echo

  NOINTERACTIVE=1 echo "$password" | sudo -S /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ==============================================================================
# Install packages
# ==============================================================================

echo "#------------------------------------------------#"
echo "  Install packages"
echo "#------------------------------------------------#"
echo

### For Linux
if "$IS_LINUX" ; then
  # Update and upgrade packages
  echo "$password" | sudo -S apt update
  DEBIAN_FRONTEND=noninteractive echo "$password" | sudo -S apt upgrade -y

  # Install packages
  DEBIAN_FRONTEND=noninteractive echo "$password" | sudo -S apt install -y \
    peco \
    zsh

### For macOS
elif "$IS_DARWIN" ; then
  # Install packages
  brew install \
    peco \
    zsh
fi

# ==============================================================================
# ZSH set up
# ==============================================================================

echo "#------------------------------------------------#"
echo "  Set up ZSH"
echo "#------------------------------------------------#"
echo

# Set ZSH path to /etc/shells
echo "Set ZSH path to /etc/shells"
if ! grep -qx "$(which zsh)" /etc/shells ; then
  sudo -S sh -c "echo "$(which zsh)" >> /etc/shells"
fi

### Install Zinit
echo "Start install Zinit..."
NO_INPUT=true NO_ANNEXES=true NO_EDIT=true bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

### Install Starship
echo "Start install Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# ==============================================================================
# Install nvm and Node.js LTS version
# ==============================================================================

# Disabled in Remote Container (by VSCode)
if ! "$IS_REMOTE_CONTAINER" ; then
  echo "#------------------------------------------------#"
  echo "  Install nvm and Node.js LTS version"
  echo "#------------------------------------------------#"
  echo

  ### Install nvm
  echo "Start install nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

  ### Load nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  ### Install Node.js LTS version
  echo "Start install Node.js LTS version..."
  nvm install --lts

  ### Upgrade npm version
  echo "Upgrade npm version..."
  npm install -g npm
fi

# ==============================================================================
# Create directories for development
# ==============================================================================

# Disabled in Remote Container (by VSCode)
if ! "$IS_REMOTE_CONTAINER" ; then
  echo "#------------------------------------------------#"
  echo "  Create directories for development"
  echo "#------------------------------------------------#"
  echo

  cd
  # Create directories
  mkdir -p \
    "Application" \
    "Develop" \
    "Laboratory"
fi

# ==============================================================================
# Set default shell to ZSH
# ==============================================================================

# Disabled in Remote Container (by VSCode)
if ! "$IS_REMOTE_CONTAINER" ; then
  echo "#------------------------------------------------#"
  echo "  Set default shell to ZSH"
  echo "#------------------------------------------------#"

  read -n 1 -p "Do you want to change the default shell to ZSH? [Y/n]: " __answer
  echo

  case "$__answer" in
    [yY]) chsh -s "$(which zsh)" ;;
    *) echo "Default shell was not changed" ;;
  esac
fi

# ==============================================================================
# Finalize
# ==============================================================================
echo "#------------------------------------------------#"
echo "  All set up and ready to go!"
echo "#------------------------------------------------#"

echo 'Run "zsh" to apply the changes.'
echo
