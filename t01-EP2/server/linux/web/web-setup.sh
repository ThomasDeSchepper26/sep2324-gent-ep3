#! /bin/bash

# --------------------------------------------------------------------------------------------------
# The following script does the configuration for the WEB server for the OLOD of SEP at HoGent
# --------------------------------------------------------------------------------------------------

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

# --------------------------------------------------------------------------------------------------
# Load configuration from config file
# --------------------------------------------------------------------------------------------------

# Path to the configuration file
CONFIG_FILE="/vagrant/web/web-setup.conf"

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
# Packages installation
# --------------------------------------------------------------------------------------------------

# Install the required packages for Apache and PHP
sudo dnf install httpd php php-common php-opcache php-cli php-gd php-curl php-mysqlnd wget -y

# Reload and enable Apache
sudo systemctl daemon-reload
sudo systemctl start httpd
sudo systemctl enable httpd

# --------------------------------------------------------------------------------------------------
# Firewall configuration
# --------------------------------------------------------------------------------------------------

sudo systemctl start firewalld
sudo systemctl enable firewalld

if sudo systemctl is-active --quiet firewalld; then
    sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.115.146/30" service name="http" accept' --permanent
    sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.115.146/30" service name="https" accept' --permanent
    sudo firewall-cmd --reload
else
    echo -e "\033[0;31mFirewall is not active, no changes made.\033[0m"
fi

# --------------------------------------------------------------------------------------------------
# Wordpress configuration
# --------------------------------------------------------------------------------------------------

cd /tmp
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Configure WordPress database settings
sudo sed -i "s/database_name_here/$DB/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$DB_USER/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$DB_PW/g" /var/www/html/wp-config.php
sudo sed -i "s/localhost/$DB_SRV/g" /var/www/html/wp-config.php

# Configure SELinux policies
sudo setsebool -P httpd_can_network_connect_db 1
sudo chcon -t httpd_sys_rw_content_t /var/www/html/ -R
sudo restorecon -Rv /var/www/html/

# Restart Apache
sudo systemctl restart httpd

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