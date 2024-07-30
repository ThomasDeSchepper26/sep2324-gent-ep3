#! /bin/bash

# Provisioning script for database server

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

readonly db_root_password='sep8wachtwoord'
readonly db_name='g08db'
readonly db_table='table'
readonly db_user='Administrator'
readonly db_password='23Admin24'
readonly webserver_ip="192.168.108.150"

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provisioning tasks
#------------------------------------------------------------------------------

# MariaDB installeren
dnf install -y mariadb-server

# Start and enable MariaDB
systemctl start mariadb
systemctl enable mariadb

# Firewall voor mariadb en ssh configureren
systemctl enable firewalld
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Database-initialisatie en configuratie
mysql -u root -p <<EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${db_root_password}');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS g08db;
DELETE FROM mysql.db WHERE Db='g08db' OR Db='g08db\\_%';
CREATE DATABASE IF NOT EXISTS ${db_name};
GRANT ALL ON ${db_name}.* TO '${db_user}'@'${webserver_ip}' IDENTIFIED BY '${db_password}';
FLUSH PRIVILEGES;
EOF