#!/bin/bash

# Enable "Bash strict mode"
set -o errexit   # Abort on nonzero exitstatus
set -o nounset   # Abort on unbound variable
set -o pipefail  # Don't mask errors in piped commands

# Location of provisioning scripts and files
readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

# Location of tftp directory
TFTP_DIRECTORY="/var/lib/tftpboot"

# Actions/settings common to all servers
source "${PROVISIONING_SCRIPTS}/common.sh"

# Provision TFTP server
echo "Installing and configuring TFTP server..."
dnf install -y tftp-server

# Start and enable TFTP server
systemctl start tftp
systemctl enable tftp

# Open SSH and TFTP ports
echo "Opening SSH and TFTP ports..."
firewall-cmd --add-service=ssh --permanent
firewall-cmd --add-service=tftp --permanent

# Reload firewall
echo "Reloading firewall..."
firewall-cmd --reload

# Ensure the TFTP directory exists
mkdir -p "$TFTP_DIRECTORY"
chmod -R 777 "$TFTP_DIRECTORY"

# Change the owner to nobody for all files and directories in the TFTP directory
echo "Changing owner to nobody..."
chown -R nobody:nobody "$TFTP_DIRECTORY"

# Copy files to the TFTP directory
echo "Copying files to TFTP directory..."
cp /vagrant/netwerk-scripts/* "$TFTP_DIRECTORY/"

# Ensure the TFTP server can write to the directory
# Add the -c option to configure TFTP server to create new files
echo "Configuring TFTP server..."
sed -i 's|^ExecStart=/usr/sbin/in.tftpd -s /var/lib/tftpboot|ExecStart=/usr/sbin/in.tftpd -c -s /var/lib/tftpboot|' /usr/lib/systemd/system/tftp.service

# Reload systemd to apply the changes
systemctl daemon-reload

# Restart TFTP server to apply the changes
systemctl restart tftp

echo "TFTP server (tftp-server) is now installed, configured, and running."
