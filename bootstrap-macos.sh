#!/bin/bash

# Exit on error
set -e


# Handle direct installation
SCRIPT_SOURCE="https://github.com/hujambo-io/dev-setup.git"
TEMP_DIR=""
ORIGINAL_DIR=""


if [[ ! -f "ansible/playbook.yml" ]]; then
    echo "Direct installation detected. Cloning repository..."
    TEMP_DIR=$(mktemp -d)
    git clone "$SCRIPT_SOURCE" "$TEMP_DIR"
    cd "$TEMP_DIR"
fi


# Script variables
PLAYBOOK="ansible/playbook.yml"
INVENTORY="ansible/inventory.yml"
VERBOSITY="-v"  # Default verbosity
ACTION="install" # Default action
ROLE=""         # No role by default
VALID_ROLES=("default" "frontend" "backend" "mobile" "full-stack" "QA")

# Function to display usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Set up development environment using Ansible"
    echo
    echo "For Installation (requires --role):"
    echo "  --role ROLE    Specify role to install"
    echo "                 Valid roles: ${VALID_ROLES[*]}"
    echo "                 Note: 'full-stack' includes all tools"
    echo
    echo "For Uninstallation:"
    echo "  --uninstall           Uninstall all tools"
    echo "  --uninstall --role ROLE   Uninstall tools for specific role"
    echo
    echo "Other Options:"
    echo "  -v, -vv, -vvv  Increase verbosity level"
    echo "  --help         Display this help message"
    echo
    echo "Examples:"
    echo "  $0 --role default     # Install basic development tools"
    echo "  $0 --role backend     # Install backend tools"
    echo "  $0 --role full-stack  # Install all tools"
    echo "  $0 --role mobile -vv  # Install mobile tools with increased verbosity"
    echo "  $0 --uninstall        # Uninstall all tools"
    echo "  $0 --uninstall --role QA  # Uninstall only QA tools"
    echo "# Install single app without role"
    echo "ansible-playbook ansible/playbook.yml --tags install --extra-vars 'single_app=visual-studio-code'"
    echo "# Uninstall single app without role"
    echo "ansible-playbook ansible/playbook.yml --tags uninstall --extra-vars 'single_app=visual-studio-code'"
}

# Function to validate role
validate_role() {
    local role=$1
    for valid_role in "${VALID_ROLES[@]}"; do
        if [[ "$role" == "$valid_role" ]]; then
            return 0
        fi
    done
    echo "Error: Invalid role '$role'"
    echo "Valid roles are: ${VALID_ROLES[*]}"
    exit 1
}

# Function to check prerequisites
check_prerequisites() {
    # Check if playbook exists
    if [[ ! -f "$PLAYBOOK" ]]; then
        echo "Error: Playbook not found at $PLAYBOOK"
        exit 1
    fi
    # Check for Homebrew and install if not found
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to your PATH in zsh based on architecture
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    # Check if ansible is installed
    if ! command -v ansible-playbook &> /dev/null; then
        echo "Ansible is not installed. Installing Ansible..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install ansible
        else
            sudo apt update && sudo apt install -y ansible
        fi
    fi

    # Verify ansible installation
    if ! ansible-playbook --version &> /dev/null; then
        echo "Error: Ansible installation failed or is corrupted"
        exit 1
    fi
}

# Function to install required collections
install_collections() {
    echo "Installing required Ansible collections..."
    local collections=("ansible.windows" "community.general" "community.windows")
    
    for collection in "${collections[@]}"; do
        echo "Installing $collection..."
        if ! ansible-galaxy collection install "$collection" --force; then
            echo "Error: Failed to install $collection"
            exit 1
        fi
    done
}

# Function to validate playbook syntax
validate_playbook() {
    echo "Validating playbook syntax..."
    if ! ansible-playbook "$PLAYBOOK" --syntax-check; then
        echo "Error: Playbook syntax validation failed"
        exit 1
    fi
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --uninstall)
            ACTION="uninstall"
            shift
            ;;
        --role)
            ROLE="$2"
            validate_role "$ROLE"
            shift 2
            ;;
        -v|-vv|-vvv)
            VERBOSITY="$1"
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if role is specified for installation
if [[ "$ACTION" == "install" && -z "$ROLE" ]]; then
    echo "Error: Role must be specified with --role for installation"
    show_usage
    exit 1
fi

# Main execution
echo "Starting development environment setup..."
check_prerequisites
install_collections
validate_playbook

# Prepare ansible-playbook command
ANSIBLE_CMD="ansible-playbook $PLAYBOOK $VERBOSITY"
if [[ -f "$INVENTORY" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD -i $INVENTORY"
else
    echo "Warning: Inventory file not found at $INVENTORY"
fi

# Add role and tags based on action
if [[ "$ACTION" == "uninstall" ]]; then
    if [[ -n "$ROLE" ]]; then
        # Role-specific uninstall
        echo "Uninstalling tools for role: $ROLE"
        ANSIBLE_CMD="$ANSIBLE_CMD --extra-vars role=$ROLE --tags uninstall"
    else
        # Complete uninstall
        echo "Uninstalling all tools"
        ANSIBLE_CMD="$ANSIBLE_CMD --tags uninstall"
    fi
else
    # Install always needs a role
    ANSIBLE_CMD="$ANSIBLE_CMD --extra-vars role=$ROLE --tags 'always,install,setup'"
fi

# Execute ansible-playbook
echo "Executing: $ANSIBLE_CMD"
if ! eval "$ANSIBLE_CMD"; then
    echo "Error: Ansible playbook execution failed"
    exit 1
fi


# Add cleanup at the end
if [[ -n "$TEMP_DIR" ]]; then
    echo "Cleaning up temporary files..."
    cd "$ORIGINAL_DIR"
    rm -rf "$TEMP_DIR"
fi

echo "Setup completed successfully!"
