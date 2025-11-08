#!/bin/zsh
# Execute: curl https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/zsh/terminal/oh-my-posh/install.sh | zsh

# INFO: Variables
poshtheme="powerlevel10k_rainbow.omp.json" # themes: https://ohmyposh.dev/docs/themes
#powerlevel10k_rainbow.omp.json, quick-term.omp.json, spaceship.omp.json, clean-detailed.omp.json

# Exit on error
set -e

# INFO: Install pre-requisites
echo "Installing pre-resquisites..."

sudo apt update && sudo apt upgrade -y && sudo apt install -y git curl zip unzip zsh

# INFO: Set default shell
echo "Setting default shell to zsh..."

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

# INFO: Install Oh My Posh
echo "Installing Oh My Posh..."

# Ensure ~/.local/bin is in PATH
export PATH=$HOME/.local/bin:$PATH

homepath='export PATH=$HOME/.local/bin:$PATH'

for file in ~/.zshrc ~/.zprofile; do
  if ! grep -Fxq "$homepath" "$file"; then
    echo "$homepath" >> "$file"
    echo "Added PATH export to $file"
  else
    echo "PATH export already exists in $file"
  fi
done

# Install Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash

# INFO: Set up theme
mkdir -p ~/.poshthemes
curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/$poshtheme -o ~/.poshthemes/$poshtheme

chmod u+rw ~/.poshthemes/*.json

# Define the line to inject
newline="eval \"\$(oh-my-posh init zsh --config ~/.poshthemes/$poshtheme)\""

# If the line exists, replace it; otherwise, append it
if grep -q "oh-my-posh init zsh" ~/.profile; then
  sed -i "s|^eval .*oh-my-posh init zsh.*|$newline|" ~/.profile
else
  echo "$newline" >> ~/.profile
fi

echo "Oh My Posh configuration updated in .profile"

: '
# Define the line to inject
newline="eval \"\$(oh-my-posh init zsh --config ~/.poshthemes/$poshtheme)\""

# If the line exists, replace it; otherwise, append it
if grep -q "oh-my-posh init zsh" ~/.zshrc; then
  sed -i "s|^eval .*oh-my-posh init zsh.*|$newline|" ~/.zshrc
else
  echo "$newline" >> ~/.zshrc
fi

echo "Oh My Posh configuration updated in .zshrc"
'

# INFO: Enable Oh My Posh upgrades
oh-my-posh enable upgrade

# INFO: Installing Hack Nerd Font specifically. Matches Windows terminal settings.
oh-my-posh font install hack

echo "Installation complete. Restart your terminal or run 'exec zsh' to apply changes."