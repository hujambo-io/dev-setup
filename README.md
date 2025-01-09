# Development Environment Setup

An Ansible-based cross-platform development environment setup tool that provides role-based installation of development tools.

## Prerequisites

- Git (for cloning the repository)
- macOS or Linux or Windows with WSL
- Internet connection

## Installation Methods

### Direct Installation from GitHub

```bash
# macOS
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/hujambo-io/dev-setup/main/bootstrap-macos.sh)" -- --role default

# Linux
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/hujambo-io/dev-setup/main/bootstrap-linux.sh)" -- --role default

# Windows (PowerShell)
irm https://raw.githubusercontent.com/hujambo-io/dev-setup/main/bootstrap-windows.ps1 | iex; bootstrap-windows --role default
```

### Manual Installation

1. Clone and run:
```bash
git clone https://github.com/hujambo-io/dev-setup.git
cd dev-setup
./bootstrap-macos.sh --role default   # For macOS
./bootstrap-linux.sh --role default   # For Linux
./bootstrap-windows.ps1 --role default # For Windows
```

## Available Roles

- `default`: Basic development tools (git, VSCode, etc.)
- `frontend`: Frontend development tools
- `backend`: Backend development tools
- `mobile`: Mobile development tools
- `full-stack`: All development tools
- `QA`: Testing and QA tools

## Usage Examples

```bash
# Install basic development tools
./bootstrap-macos.sh --role default

# Install backend development tools
./bootstrap-macos.sh --role backend

# Install all tools
./bootstrap-macos.sh --role full-stack

# Uninstall specific role tools
./bootstrap-macos.sh --uninstall --role mobile

# Uninstall everything
./bootstrap-macos.sh --uninstall

# Install single application
ansible-playbook ansible/playbook.yml --tags install --extra-vars 'single_app=visual-studio-code'

# Uninstall single application
ansible-playbook ansible/playbook.yml --tags uninstall --extra-vars 'single_app=visual-studio-code'

# Additional Operations

## Tag-based Operations
The setup tool now supports tag-based operations for finer control:


# Initial environment setup
./bootstrap-macos.sh --tag bootstrap

# Create project directory structure
./bootstrap-macos.sh --tag setup

# Post-installation cleanup
./bootstrap-macos.sh --tag finish
```

Replace `bootstrap-macos.sh` with `bootstrap-linux.sh` or `bootstrap-windows.ps1` as needed.

## Features

- Role-based installation
- Cross-platform support (macOS, Linux, Windows)
- Individual tool installation/uninstallation
- Idempotent execution (safe to run multiple times)
- Platform-specific package manager support
  - Homebrew for macOS
  - apt/dnf/yum/pacman for Linux
  - Chocolatey for Windows


Development Tools
Java Development

Uses asdf for Java version management
Installs OpenJDK 21 by default
Configured specifically for Android and Spring Boot development

Flutter Development

Platform-specific installation (uses --cask on macOS)
Automatic ARM/Intel architecture detection
Native performance optimization

## Directory Structure

The repository follows this structure:
```
dev-setup/
├── ansible/
│   ├── playbook.yml
│   ├── inventory.yml
│   └── windows_tasks.yml
├── bootstrap-macos.sh
├── bootstrap-linux.sh
├── bootstrap-windows.ps1
└── README.md
```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License.
