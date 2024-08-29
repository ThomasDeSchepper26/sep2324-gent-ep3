#!/bin/bash

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

source /path/to/ssl_config.sh

#------------------------------------------------------------------------------
# Configure SSL for Apache
#------------------------------------------------------------------------------

echo "Installing mod_ssl for Apache"
dnf install -y mod_ssl

echo "Backing up the original SSL configuration file"
cp $APACHE_SSL_CONF "${APACHE_SSL_CONF}.bak"

echo "Configuring Apache to use SSL"
sed -i "s|SSLCertificateFile.*|SSLCertificateFile $SSL_CERT_PATH|" $APACHE_SSL_CONF
sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile $SSL_KEY_PATH|" $APACHE_SSL_CONF

echo "Enabling and restarting Apache to apply SSL configuration"
systemctl enable httpd
systemctl restart httpd

echo "Apache SSL configuration completed"
