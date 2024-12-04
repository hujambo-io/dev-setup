#!/bin/bash

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
  echo "Ansible is not installed. Installing Ansible..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install ansible
  else
    sudo apt update && sudo apt install -y ansible
  fi
fi

# Define playbook and inventory paths
PLAYBOOK="ansible/playbook.yml"
INVENTORY="ansible/inventory.yml"

# Run Ansible playbook
if [[ -f $INVENTORY ]]; then
  echo "Running playbook with inventory..."
  ansible-playbook $PLAYBOOK -i $INVENTORY "$@"
else
  echo "Running playbook without inventory..."
  ansible-playbook $PLAYBOOK "$@"
fi

echo "Setup complete!"
