# Check if Ansible is installed
if (-Not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
    Write-Output "Ansible is not installed. Please set it up in WSL or equivalent."
    exit 1
}

# Define playbook and inventory paths
$Playbook = "ansible/playbook.yml"
$Inventory = "ansible/inventory.yml"

# Run Ansible playbook
if (Test-Path $Inventory) {
    Write-Output "Running playbook with inventory..."
    ansible-playbook $Playbook -i $Inventory @args
} else {
    Write-Output "Running playbook without inventory..."
    ansible-playbook $Playbook @args
}

Write-Output "Setup complete!"
