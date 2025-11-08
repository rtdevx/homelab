#!/bin/zsh
# Execute: curl https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/wsl/ubuntu/install.sh | bash

# INFO: Install Oh My Posh on WSL Ubuntu with zsh

# INFO: Variables
poshtheme="powerlevel10k_rainbow.omp.json" # themes: https://ohmyposh.dev/docs/themes
#powerlevel10k_rainbow.omp.json, quick-term.omp.json, spaceship.omp.json, clean-detailed.omp.json

# Exit on error
set -e

# Install Oh My Posh pre-requisites
echo "Installing oh-my-posh pre-resquisites..."

sudo apt update && sudo apt upgrade -y && sudo apt install -y git curl zip unzip zsh

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

sudo apt update
sudo apt install unattended-upgrades -y

# INFO: Installing terraform

echo "Installing Terraform..."

# Install required packages
sudo apt install -y wget gnupg2

# Add the HashiCorp GPG key
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the official HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package lists again
sudo apt update

# Install Terraform
sudo apt install -y terraform

# Verify installation
terraform --version

# INFO: Configure git

echo "Configuring git..."

mkdir -p ~/git

# Define the parent directory
PARENT_DIR=~/git

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
    # Extract the folder name from the URL
    FOLDER_NAME=$(basename "$REPO_URL" .git)
    echo "Cloning $REPO_URL into $PARENT_DIR/$FOLDER_NAME..."
    
    git clone "$REPO_URL" "$FOLDER_NAME"

    # Check for success
    if [ $? -eq 0 ]; then
        echo "Successfully cloned $REPO_URL into $FOLDER_NAME"
    else
        echo "Failed to clone $REPO_URL"
    fi
done
