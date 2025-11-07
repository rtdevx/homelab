#!/bin/bash
# Execute: curl https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/terminal/oh-my-posh/install.sh | bash

# INFO: Variables
poshtheme="powerlevel10k_rainbow.omp.json" # themes: https://ohmyposh.dev/docs/themes
#powerlevel10k_rainbow.omp.json, quick-term.omp.json, spaceship.omp.json, clean-detailed.omp.json

# Exit on error
set -e

# INFO: Install pre-requisites
echo "Installing pre-resquisites..."

sudo apt update && sudo apt upgrade -y && sudo apt install -y git curl zip unzip zsh

# INFO: Install Oh My Posh
echo "Installing Oh My Posh..."
export PATH=$HOME/.local/bin:$PATH
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# INFO: Set up theme
mkdir -p ~/.poshthemes
curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/$poshtheme -o ~/.poshthemes/$poshtheme

chmod u+rw ~/.poshthemes/*.json

# Define the line to inject
newline="eval \"\$(oh-my-posh init bash --config ~/.poshthemes/$poshtheme)\""

# If the line exists, replace it; otherwise, append it
if grep -q "oh-my-posh init bash" ~/.profile; then
  sed -i "s|^eval .*oh-my-posh init bash.*|$newline|" ~/.profile
else
  echo "$newline" >> ~/.profile
fi

echo "Oh My Posh configuration updated in .profile"

# INFO: Enable Oh My Posh upgrades
oh-my-posh enable upgrade

# INFO: Installing Hack Nerd Font specifically. Matches Windows terminal settings.
oh-my-posh font install hack

# INFO: Set default shell
echo "Setting default shell to zsh..."

# Get current shell from /etc/passwd
currentshell=$(getent passwd "$USER" | cut -d: -f7)

# Desired shell
targetshell="/bin/zsh"

# Compare and update if needed
if [ "$currentshell" != "$targetshell" ]; then
  echo "Changing shell to Zsh..."
  chsh -s "$targetshell"
else
  echo "Shell is already set to Zsh. Skipping."
fi

echo "Installation complete. Restart your terminal or run 'source ~/.zshrc' to apply changes."