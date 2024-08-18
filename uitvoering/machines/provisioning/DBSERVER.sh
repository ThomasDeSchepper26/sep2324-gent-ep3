#!/bin/bash

# Enable "Bash strict mode"
set -o errexit
set -o nounset
set -o pipefail

# Variables
readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
readonly db_root_password='sep8wachtwoord'
readonly db_name='g08db'
readonly db_user='Administrator'
readonly db_password='23Admin24'
readonly webserver_ip="192.168.108.150"

# Source common functions
source ${PROVISIONING_SCRIPTS}/common.sh

# Install MariaDB
sudo dnf install -y mariadb-server

# Start and enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Configure firewall
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

# Secure MariaDB installation
sudo mysql_secure_installation <<EOF

y
${db_root_password}
${db_root_password}
y
y
y
y
EOF

# Wait for MariaDB to initialize
sleep 10

# Database initialization and configuration
mysql --user=root --password="${db_root_password}" <<EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${db_root_password}');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS ${db_name};
DELETE FROM mysql.db WHERE Db='${db_name}' OR Db='${db_name}\\_%';
CREATE DATABASE IF NOT EXISTS ${db_name};
GRANT ALL ON ${db_name}.* TO '${db_user}'@'${webserver_ip}' IDENTIFIED BY '${db_password}';
FLUSH PRIVILEGES;
EOF

# Verify database creation
mysql --user=root --password="${db_root_password}" -e "SHOW DATABASES;"
mysql --user=root --password="${db_root_password}" -e "SELECT User, Host FROM mysql.user;"

echo "Database provisioning completed successfully."
exit 0
