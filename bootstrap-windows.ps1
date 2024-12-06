# Exit on error
$ErrorActionPreference = "Stop"


# Handle direct installation
$SCRIPT_SOURCE = "https://github.com/hujambo-io/dev-setup.git"
$TEMP_DIR = ""
$ORIGINAL_LOCATION = ""

if ($MyInvocation.MyCommand.Source -eq "") {
    Write-Output "Direct installation detected. Cloning repository..."
    $ORIGINAL_LOCATION = Get-Location
    $TEMP_DIR = "$env:TEMP\dev-setup-" + [System.Guid]::NewGuid().ToString()
    New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
    git clone $SCRIPT_SOURCE $TEMP_DIR
    Set-Location $TEMP_DIR
}


# Script variables
$Playbook = "ansible/playbook.yml"
$Inventory = "ansible/inventory.yml"
$Verbosity = "-v"  # Default verbosity
$ValidRoles = @("default", "frontend", "backend", "mobile", "full-stack", "QA")

# Function to display usage
function Show-Usage {
    Write-Output "Usage: .\bootstrap-windows.ps1 [OPTIONS]"
    Write-Output "Set up development environment using Ansible"
    Write-Output ""
    Write-Output "For Installation (requires --role):"
    Write-Output "  --role ROLE    Specify role to install"
    Write-Output "                 Valid roles: $($ValidRoles -join ', ')"
    Write-Output "                 Note: 'full-stack' includes all tools"
    Write-Output ""
    Write-Output "For Uninstallation:"
    Write-Output "  --uninstall           Uninstall all tools"
    Write-Output "  --uninstall --role ROLE   Uninstall tools for specific role"
    Write-Output ""
    Write-Output "Other Options:"
    Write-Output "  -v, -vv, -vvv  Increase verbosity level"
    Write-Output "  --help         Display this help message"
    Write-Output ""
    Write-Output "Examples:"
    Write-Output "  .\bootstrap-windows.ps1 --role default     # Install basic development tools"
    Write-Output "  .\bootstrap-windows.ps1 --role backend     # Install backend tools"
    Write-Output "  .\bootstrap-windows.ps1 --role full-stack  # Install all tools"
    Write-Output "  .\bootstrap-windows.ps1 --uninstall        # Uninstall all tools"
    Write-Output "  .\bootstrap-windows.ps1 --uninstall --role QA  # Uninstall only QA tools"
    Write-Output " # Install single app without role"
    Write-Output "ansible-playbook ansible/playbook.yml --tags install --extra-vars 'single_app=visual-studio-code'"
    Write-Output "# Uninstall single app without role"
    Write-Output "ansible-playbook ansible/playbook.yml --tags uninstall --extra-vars 'single_app=visual-studio-code'"
}

# Function to validate role
function Test-Role {
    param (
        [string]$Role
    )
    if ($Role -in $ValidRoles) {
        return $true
    }
    Write-Output "Error: Invalid role '$Role'"
    Write-Output "Valid roles are: $($ValidRoles -join ', ')"
    exit 1
}

# Function to check prerequisites
function Test-Prerequisites {
    # Check if playbook exists
    if (-not (Test-Path $Playbook)) {
        Write-Output "Error: Playbook not found at $Playbook"
        exit 1
    }

    # Check if Ansible is installed
    if (-Not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
        Write-Output "Error: Ansible must be installed via WSL"
        Write-Output "Please install WSL and Ansible before continuing"
        exit 1
    }

    # Verify ansible installation
    try {
        ansible-playbook --version | Out-Null
    } catch {
        Write-Output "Error: Ansible installation failed or is corrupted"
        exit 1
    }
}

# Function to install required collections
function Install-Collections {
    Write-Output "Installing required Ansible collections..."
    $collections = @("ansible.windows", "community.general", "community.windows")
    
    foreach ($collection in $collections) {
        Write-Output "Installing $collection..."
        try {
            ansible-galaxy collection install $collection --force
        } catch {
            Write-Output "Error: Failed to install $collection"
            exit 1
        }
    }
}

# Function to validate playbook syntax
function Test-PlaybookSyntax {
    Write-Output "Validating playbook syntax..."
    try {
        ansible-playbook $Playbook --syntax-check
    } catch {
        Write-Output "Error: Playbook syntax validation failed"
        exit 1
    }
}

# Parse command-line arguments
param (
    [switch]$Uninstall,
    [string]$Role = "",
    [string]$v,
    [switch]$Help
)

if ($Help) {
    Show-Usage
    exit 0
}

$Action = if ($Uninstall) { "uninstall" } else { "install" }

# Validate role if provided
if ($Role -ne "") {
    Test-Role $Role
}

# Check if role is specified for installation
if ($Action -eq "install" -and $Role -eq "") {
    Write-Output "Error: Role must be specified with --role for installation"
    Show-Usage
    exit 1
}

# Main execution
Write-Output "Starting development environment setup..."
Test-Prerequisites
Install-Collections
Test-PlaybookSyntax

# Prepare ansible-playbook command
$AnsibleCmd = "ansible-playbook $Playbook $Verbosity"
if (Test-Path $Inventory) {
    $AnsibleCmd = "$AnsibleCmd -i $Inventory"
} else {
    Write-Output "Warning: Inventory file not found at $Inventory"
}

# Add role and tags based on action
if ($Action -eq "uninstall") {
    if ($Role -ne "") {
        # Role-specific uninstall
        Write-Output "Uninstalling tools for role: $Role"
        $AnsibleCmd = "$AnsibleCmd --extra-vars `"role=$Role`" --tags uninstall"
    } else {
        # Complete uninstall
        Write-Output "Uninstalling all tools"
        $AnsibleCmd = "$AnsibleCmd --tags uninstall"
    }
} else {
    # Install always needs a role
    $AnsibleCmd = "$AnsibleCmd --extra-vars `"role=$Role`" --tags 'always,install,setup'"
}

# Execute ansible-playbook
Write-Output "Executing: $AnsibleCmd"
try {
    Invoke-Expression $AnsibleCmd
} catch {
    Write-Output "Error: Ansible playbook execution failed"
    exit 1
}

# Cleanup
if ($TEMP_DIR -ne "") {
    Write-Output "Cleaning up temporary files..."
    Set-Location $ORIGINAL_LOCATION
    Remove-Item -Recurse -Force $TEMP_DIR
}

Write-Output "Setup completed successfully!"
