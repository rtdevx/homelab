#!/bin/bash
# Execute: curl https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/terminal/oh-my-posh/install.sh | bash

# Variables
poshtheme="powerlevel10k_rainbow.omp.json" # themes: https://ohmyposh.dev/docs/themes

# Exit on error
set -e

echo "Installing pre-resquisites..."

sudo apt update && sudo apt install -y git curl zip unzip #zsh

echo "Installing Oh My Posh..."

# Install Oh My Posh binary
curl -s https://ohmyposh.dev/install.sh | bash

# Add Oh My Posh to PATH (if needed)
export PATH=$HOME/.local/bin:$PATH

# Download theme
mkdir -p ~/.poshthemes
curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/$poshtheme -o ~/.poshthemes/$poshtheme

# Make sure themes are readable
chmod u+rw ~/.poshthemes/*.json

# Add Oh My Posh init to .profile
#if ! grep -q "oh-my-posh init bash" ~/.profile; then
#  echo "eval \"\$(oh-my-posh init bash --config ~/.poshthemes/$poshtheme)\"" >> ~/.profile
#  echo "Oh My Posh configuration added to .profile"
#fi

# Define the line to inject
newline="eval \"\$(oh-my-posh init bash --config ~/.poshthemes/$poshtheme)\""

# If the line exists, replace it; otherwise, append it
if grep -q "oh-my-posh init bash" ~/.profile; then
  sed -i "s|^eval .*oh-my-posh init bash.*|$newline|" ~/.profile
else
  echo "$newline" >> ~/.profile
fi

echo "Oh My Posh configuration updated in .profile"

# Installing Hack Nerd Font specifically. Matches Windows terminal settings.
oh-my-posh font install hack

# Set default shell
#chsh -s /bin/zsh $USER
#chsh -s /bin/bash $USER

echo "Installation complete. Restart your terminal or run 'source ~/.bashrc' to apply changes."