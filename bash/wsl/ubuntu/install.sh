#!/bin/bash
# Execute: curl https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/wsl/ubuntu/install.sh | bash

# INFO: Install Oh My Posh on WSL Ubuntu with zsh

# INFO: Variables
poshtheme="spaceship.omp.json" # themes: https://ohmyposh.dev/docs/themes
#powerlevel10k_rainbow.omp.json, quick-term.omp.json, spaceship.omp.json, clean-detailed.omp.json, amro.omp.json, blue-owl.omp.json

# Exit on error
set -e

# Install Oh My Posh pre-requisites
echo "Installing oh-my-posh pre-resquisites..."

sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt install -y git curl zip unzip zsh zsh-autosuggestions

# Set default shell
echo "Setting default shell to $targetshell"

# Get current shell from /etc/passwd
currentshell=$(getent passwd "$USER" | cut -d: -f7)

# Desired shell
targetshell="/bin/zsh"

# Compare and update if needed
if [ "$currentshell" != "$targetshell" ]; then
  echo "Changing shell to $targetshell"
  chsh -s "$targetshell"
else
  echo "Shell is already set to $targetshell. Skipping."
fi

# Install Oh My Posh
echo "Installing Oh My Posh..."

# Ensure ~/.local/bin is in PATH
export PATH=$HOME/.local/bin:$PATH

exporthomepath='export PATH=$HOME/.local/bin:$PATH'

for file in ~/.zshrc ~/.zprofile; do
  if ! grep -Fxq "$exporthomepath" "$file"; then
    echo "$exporthomepath" >> "$file"
    echo "Added PATH export to $file"
  else
    echo "PATH export already exists in $file"
  fi
done

# Install Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash

# Set up theme
mkdir -p ~/.poshthemes
curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/$poshtheme -o ~/.poshthemes/$poshtheme

chmod u+rw ~/.poshthemes/*.json

# Define the line to inject
newline="eval \"\$(oh-my-posh init zsh --config ~/.poshthemes/$poshtheme)\""

# If the line exists, replace it; otherwise, append it
if grep -q "oh-my-posh init zsh" ~/.zshrc; then
  sed -i "s|^eval .*oh-my-posh init zsh.*|$newline|" ~/.zshrc
else
  echo "$newline" >> ~/.zshrc
fi

echo "Oh My Posh configuration updated in .zshrc"

# Install zsh-autosuggestions plugin
echo "Installing zsh-autosuggestions plugin..."

# Define the plugin block
plugin_block='plugins=(
zsh-autosuggestions
git
)'

# Check if the block exists in ~/.zshrc
if ! grep -Fxq "plugins=(" ~/.zshrc || ! grep -Fxq "zsh-autosuggestions" ~/.zshrc || ! grep -Fxq "git" ~/.zshrc; then
  echo "$plugin_block" >> ~/.zshrc
  echo "Plugin block added to ~/.zshrc"
else
  echo "Plugin block already exists in ~/.zshrc"
fi

# Enable Oh My Posh upgrades
oh-my-posh enable upgrade

# Installing Hack Nerd Font specifically. Matches Windows terminal settings.
oh-my-posh font install hack

echo "Oh My Posh installation complete. Please restart your terminal to see the changes."

# INFO: Configure Ubuntu unattended upgrades

echo "Configuring unattended upgrades..."

sudo apt install unattended-upgrades -y
sudo curl -s https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/linux/apt/apt.conf.d/50unattended-upgrades -o /etc/apt/apt.conf.d/50unattended-upgrades

# INFO: Installing terraform

echo "Installing Terraform..."

# Install required packages
sudo apt install -y wget gnupg2

# Add the HashiCorp GPG key (overwrite)
#wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg # Doesn't overwrite the existing key
wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
sudo chmod 644 /usr/share/keyrings/hashicorp-archive-keyring.gpg


# Add the official HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
sudo apt update && sudo apt install -y terraform

# Verify installation
terraform --version

# INFO: Install AWS CLI

echo "Installing AWS CLI..."
sudo snap install aws-cli --classic

echo "Adding $HOME/.local/bin to PATH in zsh configuration files..."

line='export PATH=$PATH:/snap/bin'
file="$HOME/.zshrc"

# Check if the exact line exists
if ! grep -Fxq "$line" "$file"; then
  echo "$line" >> "$file"
  echo "Added PATH export to $file"
else
  echo "PATH export already exists in $file"
fi

# INFO: Configure git

echo "Configuring git..."

git config --global user.name "RobK"
git config --global user.email johndoe@example.com

# Define the parent directory
PARENT_DIR=~/git/public

# Create the parent directory if it doesn't exist
mkdir -p "$PARENT_DIR"
cd "$PARENT_DIR" || exit

# Create the parent directory if it doesn't exist
mkdir -p "$PARENT_DIR"
cd "$PARENT_DIR" || exit

# Define SSH repository URLs in a single line
REPO_URLS=(
    "git@github.com:rtdevx/homelab.git"
    "git@github.com:rtdevx/kubernetes.git"
    "git@github.com:rtdevx/dotfiles.git"
    "git@github.com:rtdevx/terraform.git"
)

# Clone each repository
for REPO_URL in "${REPO_URLS[@]}"; do
    FOLDER_NAME=$(basename "$REPO_URL" .git)
    DEST="$PARENT_DIR/$FOLDER_NAME"

    if [ -d "$DEST" ]; then
        echo "Skipping clone: $DEST already exists."
        continue
    fi

    echo "Cloning $REPO_URL into $DEST..."
    if git clone "$REPO_URL" "$DEST"; then
        echo "Successfully cloned $REPO_URL into $FOLDER_NAME"
    else
        echo "Failed to clone $REPO_URL"
    fi
done

# INFO: Configure ssh

echo "Configuring SSH..."
curl -s https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/ssh/config -o $HOME/.ssh/config
chmod 600 $HOME/.ssh/config

# INFO: Configure VSCode settings

# Install VSCode
echo "Installing VS Code..."

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
sudo chmod 644 /usr/share/keyrings/microsoft.gpg

# Define the target file path
SOURCE_FILE="/etc/apt/sources.list.d/vscode.sources"

# Create the file with the desired repository configuration
sudo tee "$SOURCE_FILE" > /dev/null <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

echo "Repository configuration written to $SOURCE_FILE"

#sudo apt update && sudo apt install -y apt-transport-https code # Not required for WSL, only for standalone Ubuntu

# Check if VS Code CLI is available
if ! command -v code &> /dev/null; then
    echo "VS Code CLI 'code' not found. Please install VS Code and ensure 'code' is in your PATH."
    exit 1
fi

# List of extensions to install
extensions=(
  ms-vscode.powershell
  ms-vscode-remote.remote-ssh
  ms-vscode.remote-server
  ms-vscode-remote.remote-wsl
  ms-vscode-remote.vscode-remote-extensionpack
  redhat.vscode-yaml
  github.copilot
  github.copilot-chat
  johnpapa.vscode-peacock
  ms-azuretools.vscode-docker
  esbenp.prettier-vscode
  eamodio.gitlens
  formulahendry.code-runner
  ms-vsliveshare.vsliveshare
  pkief.material-icon-theme
  tomoki1207.pdf
  mechatroner.rainbow-csv
  aaron-bond.better-comments
  hnw.vscode-auto-open-markdown-preview
  HashiCorp.terraform
)

# Loop through and install each extension
for ext in "${extensions[@]}"; do
    echo "Installing: $ext"
    code --install-extension "$ext" --force
done

echo "All extensions installed."

# INFO: Configure zsh aliases and settings

echo "Configuring zsh aliases and settings..."
# Define aliases and settings
zsh_config='
# Aliases
alias ll="ls -la"
alias gs="git status"
alias gp="git pull"
alias gc="git commit"
alias gco="git checkout"
alias k="kubectl"
alias kns="kubectl config set-context --current --namespace"
'
# Append to .zshrc if not already present
if ! grep -Fxq "# Aliases" ~/.zshrc; then
  echo "$zsh_config" >> ~/.zshrc
  echo "Added aliases and settings to ~/.zshrc"
else
  echo "Aliases and settings already exist in ~/.zshrc"
fi  

# Enable zsh-autosuggestions
#if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
#  git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
#fi

# Remove existing directory to ensure fresh clone
rm -rf "$HOME/.zsh/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"

# Append source line to .zshrc if not already present
if ! grep -Fxq "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ~/.zshrc; then
  echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
  echo "Enabled zsh-autosuggestions in ~/.zshrc"
else
  echo "zsh-autosuggestions already enabled in ~/.zshrc"
fi