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

# Clone the repository containing the Brewfile
REPO_URL="https://github.com/hujambo-io/dev-setup.git"
TEMP_DIR=$(mktemp -d)
echo "Cloning Brewfile repository..."
git clone "$REPO_URL" "$TEMP_DIR"

# Install all tools and applications from the Brewfile
BREWFILE_PATH="$TEMP_DIR/Brewfile"
if [ -f "$BREWFILE_PATH" ]; then
  echo "Installing tools and applications from Brewfile..."
  brew bundle --file="$BREWFILE_PATH"
else
  echo "Error: Brewfile not found in the repository."
  exit 1
fi

# Cleanup temporary directory
rm -rf "$TEMP_DIR"

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

