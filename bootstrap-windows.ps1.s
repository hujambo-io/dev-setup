# Check if WSL is installed
if (-Not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
    Write-Output "WSL is not installed. Installing WSL..."
    wsl --install
    Write-Output "WSL installed. Restart your computer and rerun this script."
    exit 0
}

# Check if Ubuntu (or any distro) is installed
if (-Not (wsl --list --online | Select-String "Ubuntu")) {
    Write-Output "Installing Ubuntu for WSL..."
    wsl --install -d Ubuntu
    Write-Output "Ubuntu installed. Please restart and rerun this script."
    exit 0
}

# Ensure Ansible is installed in WSL
Write-Output "Checking for Ansible installation in WSL..."
$ansibleCheck = wsl ansible --version 2>$null
if (-Not $ansibleCheck) {
    Write-Output "Ansible not found in WSL. Installing Ansible..."
    wsl sudo apt update
    wsl sudo apt install -y ansible
}

# Ensure Git is available for pulling repositories
Write-Output "Checking for Git in WSL..."
$gitCheck = wsl git --version 2>$null
if (-Not $gitCheck) {
    Write-Output "Git not found in WSL. Installing Git..."
    wsl sudo apt install -y git
}

# Pull the repository containing the playbook
Write-Output "Cloning or updating the Ansible repository..."
if (-Not (Test-Path -Path "ansible\playbook.yml")) {
    wsl git clone https://github.com/hujambo-io/dev-setup.git ~/dev-setup
} else {
    wsl git -C ~/dev-setup pull
}

# Run the Ansible playbook
if (Test-Path -Path "ansible\inventory.yml") {
    Write-Output "Running Ansible playbook with inventory..."
    wsl ansible-playbook -i ~/dev-setup/ansible/inventory.yml ~/dev-setup/ansible/playbook.yml
} else {
    Write-Output "Running Ansible playbook without inventory..."
    wsl ansible-playbook ~/dev-setup/ansible/playbook.yml
}