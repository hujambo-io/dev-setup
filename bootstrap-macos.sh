#!/bin/zsh

# Install Ansible if not installed
if ! command -v ansible &>/dev/null; then
  echo "Installing Ansible..."
  brew install ansible
fi

# Run Ansible playbook
# Check if inventory file exists
if [ -f "ansible/inventory.yml" ]; then
  echo "Running Ansible playbook with inventory..."
  ansible-playbook -i ansible/inventory.yml ansible/playbook.yml
else
  echo "Running Ansible playbook without inventory..."
  ansible-playbook ansible/playbook.yml
fi