#!/bin/bash

# Execute: curl https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/terminal/oh-my-posh/install.sh | bash

# Exit on error
set -e

echo "Installing pre-resquisites..."

sudo apt update && sudo apt install -y git curl zsh zip unzip

echo "Installing Oh My Posh..."

# Install Oh My Posh binary
curl -s https://ohmyposh.dev/install.sh | bash

# Add Oh My Posh to PATH (if needed)
export PATH=$HOME/.local/bin:$PATH

# Download theme
mkdir -p ~/.poshthemes
curl -s https://ohmyposh.dev/themes/gruvbox.omp.json -o ~/.poshthemes/gruvbox.omp.json

# Make sure themes are readable
chmod u+rw ~/.poshthemes/*.json

# Add Oh My Posh init to .bashrc
if ! grep -q "oh-my-posh init bash" ~/.bashrc; then
  # themes: https://ohmyposh.dev/docs/themes
  echo 'eval "$(oh-my-posh init bash --config ~/.poshthemes/gruvbox.omp.json)"' >> ~/.bashrc
  echo "Oh My Posh configuration added to .bashrc"
fi

# Install Nerd Fonts

#mkdir -p ~/tmp
#wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -O ~/tmp/nerd-fonts.zip
#sudo unzip ~/tmp/nerd-fonts.zip -d /usr/share/fonts/nerd-fonts
#sudo fc-cache -v -f /usr/share/fonts

# Installing Hack Nerd Font specifically. Matches Windows terminal settings.
oh-my-posh font install hack

# Set default shell
#chsh -s /bin/zsh $USER
#chsh -s /bin/bash $USER

echo "Installation complete. Restart your terminal or run 'source ~/.bashrc' to apply changes."