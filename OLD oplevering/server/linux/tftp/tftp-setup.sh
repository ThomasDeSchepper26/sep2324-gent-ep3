#! /bin/bash

# --------------------------------------------------------------------------------------------------
# The following script does the configuration for the TFTP server for the OLOD of SEP at HoGent
# --------------------------------------------------------------------------------------------------

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

# --------------------------------------------------------------------------------------------------
# Load configuration from config file
# --------------------------------------------------------------------------------------------------

# Path to the configuration file
CONFIG_FILE="/vagrant/tftp/tftp-setup.conf"

# Check on confige file
if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "\033[0;31mConfiguration file not found: $CONFIG_FILE\033[0m"
  exit 1
fi

echo -e "\033[1;32mConfiguration file found: $CONFIG_FILE\033[0m"

# Load the variables from config
source $CONFIG_FILE

# --------------------------------------------------------------------------------------------------
# Network settings
# --------------------------------------------------------------------------------------------------

# Grab the bridged connection and save to var eth1
eth1=$(nmcli -g NAME,DEVICE connection show | awk -F: '/eth1$/ {print $1}')
if [ -n "$eth1" ]; then
  echo "Found connection: $eth1"
  sudo nmcli connection modify "$eth1" ipv4.addresses "$IP"
  sudo nmcli connection modify "$eth1" ipv4.gateway "$GW"
  sudo nmcli connection modify "$eth1" ipv4.method manual
  sudo nmcli connection up "$eth1"
  echo -e "\033[1;32mNetwork successfully configured\033[0m"
else
  echo -e "\033[0;31mIssue thrown regarding the connector on eth1\033[0m"
fi

echo "nameserver 192.168.115.132" | sudo tee /etc/resolv.conf > /dev/null
echo "nameserver 192.168.115.133" | sudo tee -a /etc/resolv.conf > /dev/null

# --------------------------------------------------------------------------------------------------
# TFTP installation and configuration
# --------------------------------------------------------------------------------------------------

# Install the TFTP server
sudo dnf install tftp-server -y 

# Copy configurations
sudo cp /usr/lib/systemd/system/tftp.service /etc/systemd/system/tftp-server.service
sudo cp /usr/lib/systemd/system/tftp.socket /etc/systemd/system/tftp-server.socket
sudo cp $TFTP_CONFIG_PATH /etc/systemd/system/tftp-server.service

# Reload and enable
sudo systemctl daemon-reload
sudo systemctl start tftp-server
sudo systemctl enable tftp-server

# Set permission for 2 way get and put
sudo chown nobody:nobody /var/lib/tftpboot
sudo chmod 777 /var/lib/tftpboot

# Copy config file to tftp directory
sudo cp $R1_CONFIG_PATH /var/lib/tftpboot
sudo cp $S1_CONFIG_PATH /var/lib/tftpboot

# --------------------------------------------------------------------------------------------------
# Testplan additions
# --------------------------------------------------------------------------------------------------

# Addition to the VAR for making the testfile, because literal interpretation of date command
TEST_FILE=$(printf "$TEST_FILE_FORMAT" "$(date +"%Y-%m-%d")")

if [ -d "$TEST_DIR" ]; then
    sudo touch "$TEST_DIR/$TEST_FILE"
else
    sudo mkdir -p "$TEST_DIR"
    sudo touch "$TEST_DIR/$TEST_FILE"
fi

echo -e "\033[1;32mFile '$TEST_FILE' created in directory '$TEST_DIR'\033[0m"