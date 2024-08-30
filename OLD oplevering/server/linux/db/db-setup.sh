#! /bin/bash

# --------------------------------------------------------------------------------------------------
# The following script does the configuration for the DB server for the OLOD of SEP at HoGent
# --------------------------------------------------------------------------------------------------

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

# --------------------------------------------------------------------------------------------------
# Load configuration from config file
# --------------------------------------------------------------------------------------------------

# Path to the configuration file
CONFIG_FILE="/vagrant/db/db-setup.conf"

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

# Check and grab (added to make our script fault tolerant) 
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
# MariaDB installation and configuration
# --------------------------------------------------------------------------------------------------

# Install MariaDB
sudo dnf install mariadb-server -y

# Reload and enable
sudo systemctl daemon-reload
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Set bind-address
echo "[mysqld]" | sudo tee -a /etc/my.cnf.d/mariadb-server.cnf
echo "bind-address = 0.0.0.0" | sudo tee -a /etc/my.cnf.d/mariadb-server.cnf
sudo systemctl restart mariadb

# Configure MariaDB
sudo mysql --user=root --password=admin -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'admin';"
sudo mysql --user=root --password=admin -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql --user=root --password=admin -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql --user=root --password=admin -e "DROP DATABASE IF EXISTS test;"
sudo mysql --user=root --password=admin -e "FLUSH PRIVILEGES;"

# Create WordPress database and user
sudo mysql --user=root --password=admin -e "CREATE DATABASE WordPress;"
sudo mysql --user=root --password=admin -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';"
sudo mysql --user=root --password=admin -e "CREATE USER 'wp_user'@'192.168.115.130' IDENTIFIED BY 'wp_password';"
sudo mysql --user=root --password=admin -e "GRANT ALL ON WordPress.* TO 'wp_user'@'localhost';"
sudo mysql --user=root --password=admin -e "GRANT ALL ON WordPress.* TO 'wp_user'@'192.168.115.130';"
sudo mysql --user=root --password=admin -e "FLUSH PRIVILEGES;"

echo "MariaDB and WordPress database setup complete."

# --------------------------------------------------------------------------------------------------
# Firewall configuration
# --------------------------------------------------------------------------------------------------

sudo systemctl start firewalld
sudo systemctl enable firewalld

if sudo systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.115.130/29" port port=3306 protocol=tcp accept'
  sudo firewall-cmd --reload
else
  echo -e "\033[0;31mFirewall is not active, no changes made.\033[0m"
fi

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
