#!/bin/bash

# Exit on errors
set -e

echo "Starting development environment setup..."

# Check for Homebrew and install if not found
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Adding Homebrew to PATH for this script..."
  eval "$(/opt/homebrew/bin/brew shellenv)" # Add Homebrew to PATH for the current script session
else
  echo "Homebrew already installed."
  eval "$(/opt/homebrew/bin/brew shellenv)" # Ensure PATH is updated for the current script session
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Fetch and use the Brewfile from the repository
BREWFILE_URL="https://raw.githubusercontent.com/<your-username>/<repo-name>/main/Brewfile"
echo "Fetching Brewfile..."
curl -fsSL "$BREWFILE_URL" -o /tmp/Brewfile

# Install all tools and applications from the Brewfile
echo "Installing tools and applications from Brewfile..."
brew bundle --file=/tmp/Brewfile

# Configure NVM
echo "Configuring NVM..."
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"

# Install Node.js (LTS)
echo "Installing Node.js via NVM..."
nvm install --lts
nvm use --lts

# Cleanup
echo "Cleaning up..."
brew cleanup

echo "Development environment setup complete!"

