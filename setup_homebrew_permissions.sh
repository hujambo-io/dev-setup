#!/bin/bash

# Create dev-team group if it doesn't exist
if ! dseditgroup -o read dev-team &>/dev/null; then
  sudo dseditgroup -o create dev-team
  echo "Created dev-team group"
fi

# Change ownership and permissions
sudo chown -R root:dev-team /opt/homebrew
sudo chmod -R g+rwx /opt/homebrew
sudo find /opt/homebrew -type d -exec chmod g+s {} \;
sudo chmod -R +a "group:dev-team allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" /opt/homebrew

echo "Homebrew permissions set for dev-team group"
