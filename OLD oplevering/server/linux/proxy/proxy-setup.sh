#! /bin/bash

# --------------------------------------------------------------------------------------------------
# The following script does the configuration for the PROXY server for the OLOD of SEP at HoGent
# -------------------------------------------------------------------------------------------------

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

# --------------------------------------------------------------------------------------------------
# Load configuration from config file
# --------------------------------------------------------------------------------------------------

# Path to the configuration file
CONFIG_FILE="/vagrant/proxy/proxy-setup.conf"

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
# Install packages and start Apache
# --------------------------------------------------------------------------------------------------

# Install Apache and mod_ssl
sudo dnf install httpd mod_ssl mod_http2 -y

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# --------------------------------------------------------------------------------------------------
# Firewall configuration
# --------------------------------------------------------------------------------------------------

sudo systemctl start firewalld
sudo systemctl enable firewalld

if sudo systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --add-service=http --permanent
  sudo firewall-cmd --add-service=https --permanent
  sudo firewall-cmd --reload
else
  echo -e "\033[0;31mFirewall is not active, no changes made.\033[0m"
fi

# --------------------------------------------------------------------------------------------------
# SSL Certificate 
# --------------------------------------------------------------------------------------------------

# Ensure SSL directories exist
sudo mkdir -p "${DIR_SSL_CERT}"
sudo mkdir -p "${DIR_SSL_KEY}"

# Check if SSL private key file already exists in the private directory
if [ ! -f "${DIR_SSL_KEY}/${SSL_NAME}.key" ]; then
    # Create SSL certificate and key
    sudo openssl req \
    -subj "/CN=${DOMAIN}/O=syndus/C=BE" \
    -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout \
    "${DIR_SSL_KEY}/${SSL_NAME}.key" -out "${DIR_SSL_CERT}/${SSL_NAME}.crt"
fi

# Change permissions
sudo chown -R apache:apache "${DIR_SSL_CERT}" "${DIR_SSL_KEY}"
sudo chmod -R 600 "${DIR_SSL_KEY}"/*

# --------------------------------------------------------------------------------------------------
# Apache config file
# --------------------------------------------------------------------------------------------------

echo "Editing Apache config file to set up as a reverse proxy"
sudo tee "/etc/httpd/conf.d/t01-syndus.internal.conf" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName www.${DOMAIN}
    ServerAlias ${DOMAIN}
    RewriteEngine On
    RewriteRule ^/(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
</VirtualHost>

<VirtualHost *:443>
    ServerName www.${DOMAIN}
    ServerAlias ${DOMAIN}

    SSLEngine on
    SSLCertificateFile "${DIR_SSL_CERT}/${SSL_NAME}.crt"
    SSLCertificateKeyFile "${DIR_SSL_KEY}/${SSL_NAME}.key"

    Header always set Content-Security-Policy "upgrade-insecure-requests"
    RequestHeader set X-Forwarded-Proto "https"

    Protocols h2 http/1.1

    ProxyPreserveHost On
    ProxyPass / http://${WEB_IP}/
    ProxyPassReverse / http://${WEB_IP}/
</VirtualHost>
EOF

# --------------------------------------------------------------------------------------------------
# SELinux configuration
# --------------------------------------------------------------------------------------------------

sudo setsebool -P httpd_can_network_connect 1

# --------------------------------------------------------------------------------------------------
# Reload Apache after successful installation
# --------------------------------------------------------------------------------------------------

sudo systemctl reload httpd

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