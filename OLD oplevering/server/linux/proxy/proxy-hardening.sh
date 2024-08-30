#! /bin/bash

# --------------------------------------------------------------------------------------------------
# Hardening script for the PROXY server configuration
# --------------------------------------------------------------------------------------------------

# https://vipulchaskar.blogspot.com/2012/09/changing-apache-banner-to-trick-nmap.html
# The link above is used as a reference

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

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