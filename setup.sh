#!/bin/zsh

# Exit on errors
set -e

echo "Creating development environment directory structure..."
mkdir -p ~/Developer/{01-ToSync/{01-10-Learn,01-20-Tools,01-50-Projects,01-70-VirtualEnvs},05-SyncSelected/{05-10-Learn,05-20-Tools,05-50-Projects,05-70-VirtualEnvs},09-NoSync/{09-10-Learn,09-20-Tools,09-50-Projects,09-70-VirtualEnvs}}
echo "Development environment directories created."

#!/bin/zsh

# Base directories for projects
BASE_DIRS=(
  ~/Developer/01-ToSync/01-50-Projects
  ~/Developer/05-SyncSelected/05-50-Projects
  ~/Developer/09-NoSync/09-50-Projects
)

# Sample project name
SAMPLE_PROJECT="01-ProjectTemplate"

# Function to create the project structure
create_structure() {
  local base_dir=$1
  local project_path="$base_dir/$SAMPLE_PROJECT"

  echo "Creating project structure at: $project_path"

  mkdir -p "$project_path"/{01-Docs/{01-Requirements,02-Draft,03-Design,04-Prototype,05-DevelopmentNotes,06-TestingPlans,07-ReferenceMaterials},03-Src,05-Tests/{01-UnitTests,02-IntegrationTests,03-EndToEndTests},07-Deliverables/{01-WeeklyReports,02-MonthlyReviews,03-QuarterlyReviews,04-InitialProposal,05-TechnicalSpecs,06-FinalReport,07-Presentations}}

  echo "Project structure created at: $project_path"
}

# Loop through each base directory and create the structure
for base_dir in "${BASE_DIRS[@]}"; do
  create_structure "$base_dir"
done

echo "Sample project structure created under all specified directories."


echo "Starting development environment setup..."

# Check for Homebrew and install if not found
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Adding Homebrew to PATH for this script..."
  eval "$(/opt/homebrew/bin/brew shellenv)" # Add Homebrew to PATH for the current script session

    echo >> /Users/ramsub/.zprofile
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/ramsub/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"

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


conda init zsh

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

conda init zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Cleanup
echo "Cleaning up..."
if ! brew cleanup; then
  echo "Warning: Homebrew cleanup failed."
fi

echo "Development environment setup complete! Review warnings above for any issues."
