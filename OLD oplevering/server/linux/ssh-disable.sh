#! /bin/bash

# --------------------------------------------------------------------------------------------------
# The following script disables SSH login by root
# --------------------------------------------------------------------------------------------------

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

# --------------------------------------------------------------------------------------------------
# VARs section
# --------------------------------------------------------------------------------------------------

sshConfig="/etc/ssh/sshd_config"

# --------------------------------------------------------------------------------------------------
# SSH disable root login
# --------------------------------------------------------------------------------------------------

# Include a check
if sudo grep -q "^#*PermitRootLogin" "$sshConfig"; then
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$sshConfig"
    echo -e "\033[1;36mCorrect line is found in config file, value set to no and uncommented\033[0m"
else
    echo "PermitRootLogin no" | sudo tee -a "$sshConfig" > /dev/null
    eecho -e "\033[1;33mCorrect line not found in config file, so line created and value set to no\033[0m"
fi

echo -e "\033[1;32mSSH access for the root user has been disabled\033[0m"

# --------------------------------------------------------------------------------------------------
# SSH disable credentials login
# --------------------------------------------------------------------------------------------------

# Include a check
if sudo grep -q "^#*PasswordAuthentication" "$sshConfig"; then
    sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$sshConfig"
    echo -e "\033[1;36mCorrect line is found in config file, value set to no and uncommented\033[0m"
else
    echo "PasswordAuthentication no" | sudo tee -a "$sshConfig" > /dev/null
    eecho -e "\033[1;33mCorrect line not found in config file, so line created and value set to no\033[0m"
fi

echo -e "\033[1;32mSSH is forced to use keys, no password login allowed anymore\033[0m"

# Restart on service
sudo systemctl restart sshd