
# Development Environment Setup

This repository contains scripts and configurations to set up a development environment across macOS, Linux, and Windows using Ansible.

## How to Use

### Step 1: Clone the Repository
Clone this repository to your local machine:
```bash
git clone https://github.com/hujambo-io/dev-setup.git
cd dev-setup
Step 2: Run the Bootstrap Script
Run the appropriate bootstrap script for your operating system:

macOS

./bootstrap-macos.sh
Linux

./bootstrap-linux.sh
Windows

powershell ./bootstrap-windows.ps1
These scripts will:

Install Ansible (if not already installed).
Pull the necessary playbook files.
Execute the playbook.yml to set up your development environment.
Deprecated Methods

The following methods are deprecated and will be removed in future updates.

Bash-Based Script
/bin/zsh setup.sh
Remote Execution via curl or wget
/bin/zsh -c "$(wget -qO- https://raw.githubusercontent.com/hujambo-io/dev-setup/main/setup.sh)"
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/hujambo-io/dev-setup/main/setup.sh)"
While these methods still work, we recommend transitioning to the Ansible-based approach for a more robust and cross-platform setup process.

Additional Notes

The new Ansible-based approach supports macOS, Linux, and Windows.
It ensures idempotent execution, meaning tools will only be installed if they are missing.
For detailed platform-specific instructions, refer to the comments in the playbook (playbook.yml).
Contributing

Feel free to submit issues or pull requests to enhance the setup process.

License

This project is licensed under the MIT License.


---

### **Changes Made**
1. **Highlighted the New Ansible Workflow**:
   - Added clear instructions for using the Ansible-based bootstrap scripts.
   - Made it the default method.

2. **Moved Old Methods to a Deprecated Section**:
   - Retained the old setup methods (`setup.sh`, `curl`, `wget`) under a "Deprecated" heading.
   - Marked them for removal in future updates.

3. **Clarified Platform Support**:
   - Emphasized cross-platform compatibility with Ansible.

4. **Future-Proofing**:
   - Encouraged users to adopt the new method while keeping the old one temporarily.

Let me know if you’d like further tweaks or additions! 🚀