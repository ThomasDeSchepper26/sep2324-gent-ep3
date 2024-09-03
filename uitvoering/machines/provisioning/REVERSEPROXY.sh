#!/bin/bash

# Enable "Bash strict mode"
set -o errexit   # Abort on nonzero exit status
set -o nounset   # Abort on unbound variable
set -o pipefail  # Don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

readonly domain_name="ad.g08-systemsolutions.internal"

# Actions/settings common to all servers
source "${PROVISIONING_SCRIPTS}/common.sh"

# --------------------------------------------------------------------------------------------------
# Load configuration from config file
# --------------------------------------------------------------------------------------------------

# Path to the configuration file
CONFIG_FILE="/vagrant/provisioning/proxy-setup.conf"

# Check on confige file
if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "\033[0;31mConfiguration file not found: $CONFIG_FILE\033[0m"
  exit 1
fi

echo -e "\033[1;32mConfiguration file found: $CONFIG_FILE\033[0m"

# Load the variables from config
source $CONFIG_FILE

#------------------------------------------------------------------------------
# DNS
#------------------------------------------------------------------------------
sudo bash -c 'echo "nameserver 192.168.108.148" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'

# Disable ssh password login and root login
sudo sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/' -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Installatie nmap
sudo dnf -y install nmap

log "=== Starting server specific provisioning tasks on ${HOSTNAME} ==="

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
    -subj "/CN=${domain_name}/O=syndus/C=BE" \
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
# Hardening uitbreiding
# --------------------------------------------------------------------------------------------------

sudo dnf install -y epel-release mod_security mod_security_crs httpd

MODSEC_CONF="/etc/httpd/conf.d/mod_security.conf"

# Activate mod security
if [ -f "$MODSEC_CONF" ]; then
    sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' $MODSEC_CONF
    echo -e "\033[0;32mModSecurity configuration file found and activated.\033[0m"
else
    echo -e "\033[0;31mModSecurity configuration file not found!\033[0m"
    exit 1
fi

# Configure ServerSignature and ServerTokens
APACHE_CONF="/etc/httpd/conf/httpd.conf"
echo "ServerTokens Full" | sudo tee -a $APACHE_CONF > /dev/null
echo "SecServerSignature 'Microsoft-IIS/5.0'" | sudo tee -a $APACHE_CONF > /dev/null

# Restart apache service
sudo systemctl restart httpd

echo -e "\033[0;32mApache hardening completed\033[0m"

sudo ip route del default
sudo ip route add default via 192.168.108.163

# Exit script
log '=== Provisioning completed successfully ==='
exit 0
