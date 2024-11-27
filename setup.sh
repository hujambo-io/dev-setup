#!/bin/zsh

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
if git clone "$REPO_URL" "$TEMP_DIR"; then
  echo "Repository cloned successfully."
else
  echo "Warning: Failed to clone repository. Check the URL or network connection."
  exit 1
fi

# Install all tools and applications from the Brewfile
BREWFILE_PATH="$TEMP_DIR/Brewfile"
if [ -f "$BREWFILE_PATH" ]; then
  echo "Installing tools and applications from Brewfile..."
  if ! brew bundle --file="$BREWFILE_PATH"; then
    echo "Warning: Some dependencies failed to install. Review the errors above."
  fi
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
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  . "/opt/homebrew/opt/nvm/nvm.sh"
else
  echo "Warning: NVM script not found. Ensure NVM is installed properly."
fi

# Install Node.js (LTS)
echo "Installing Node.js via NVM..."
if ! nvm install --lts; then
  echo "Warning: Node.js installation failed via NVM."
else
  nvm use --lts || echo "Warning: Unable to switch to Node.js LTS version."
fi

# Install SDKMAN
if ! command -v sdk &>/dev/null; then
  echo "Installing SDKMAN..."
  if curl -s "https://get.sdkman.io" | bash; then
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.zshrc
    echo '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"' >> ~/.zshrc
    source ~/.zshrc
    echo "Installing Java via SDKMAN..."
    if ! sdk install java; then
      echo "Warning: Java installation via SDKMAN failed."
    fi
  else
    echo "Warning: SDKMAN installation failed."
  fi
else
  echo "SDKMAN already installed."
fi

# Cleanup
echo "Cleaning up..."
if ! brew cleanup; then
  echo "Warning: Homebrew cleanup failed."
fi

echo "Development environment setup complete! Review warnings above for any issues."
