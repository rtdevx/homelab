#!/bin/bash

# Exit on error
set -e

echo "Installing Oh My Posh..."

# Install Oh My Posh binary
curl -s https://ohmyposh.dev/install.sh | bash

# Add Oh My Posh to PATH (if needed)
export PATH=$HOME/.local/bin:$PATH

# Download a sample theme (e.g., jandedobbeleer)
mkdir -p ~/.poshthemes
curl -s https://ohmyposh.dev/themes/jandedobbeleer.omp.json -o ~/.poshthemes/jandedobbeleer.omp.json

# Make sure themes are readable
chmod u+rw ~/.poshthemes/*.json

# Add Oh My Posh init to .bashrc
if ! grep -q "oh-my-posh init bash" ~/.bashrc; then
  echo 'eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"' >> ~/.bashrc
  echo "Oh My Posh configuration added to .bashrc"
fi

echo "Installation complete. Restart your terminal or run 'source ~/.bashrc' to apply changes."