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

readonly webserver_ip="192.168.108.150"
readonly domain_name="ad.g08-systemsolutions.internal"

# Actions/settings common to all servers
source "${PROVISIONING_SCRIPTS}/common.sh"

#------------------------------------------------------------------------------
# DNS
#------------------------------------------------------------------------------
sudo bash -c 'echo "nameserver 192.168.108.148" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'

# Disable ssh password login and root login
sudo sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/' -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Installatie nmap
sudo dnf -y install nmap

#------------------------------------------------------------------------------
# Nginx
#------------------------------------------------------------------------------

log "=== Starting server specific provisioning tasks on ${HOSTNAME} ==="

log "Installing nginx reverse proxy"

sudo dnf install gcc pcre-devel zlib-devel openssl-devel -y

wget 'http://nginx.org/download/nginx-1.21.4.tar.gz'
tar -xzvf nginx-1.21.4.tar.gz
cd nginx-1.21.4/
wget https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.37.tar.gz
tar -xzvf v0.37.tar.gz

if [ -d "/nginx-1.21.4/src/http/modules/headers-more-nginx-module-0.37" ]; then
    sudo rm -rf /nginx-1.21.4/src/http/modules/headers-more-nginx-module-0.37
fi
mv headers-more-nginx-module-0.37 /nginx-1.21.4/src/http/modules/
./configure --prefix=/etc/nginx --add-module=/nginx-1.21.4/src/http/modules/headers-more-nginx-module-0.37 --with-http_ssl_module --with-http_v2_module

make
sudo make install

cat <<EOF > "/etc/systemd/system/nginx.service"
[Unit]
Description=nginx - high performance web server
After=network.target

[Service]
Type=forking
ExecStart=/etc/nginx/sbin/nginx
ExecReload=/etc/nginx/sbin/nginx -s reload
ExecStop=/etc/nginx/sbin/nginx -s stop
PIDFile=/etc/nginx/logs/nginx.pid
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload

#------------------------------------------------------------------------------
# TLS
#------------------------------------------------------------------------------

log "Aanmaken tls keys"

sudo mkdir -p /etc/ssl/certs
chmod 700 /etc/ssl/certs

sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -keyout "/etc/ssl/certs/myKey.key" -out  "/etc/ssl/certs/myCertificate.crt" \
    -subj "/C=BE/ST=OV/L=Ghent/O=Hogent/CN=${domain_name}"

sudo chmod 600 /etc/ssl/certs/myKey.key /etc/ssl/certs/myCertificate.crt

log "Enabling nginx service"
sudo systemctl start nginx

sudo systemctl enable --now nginx

log "Starting nginx config"

sudo mkdir -p /etc/nginx/certs
sudo mkdir -p /etc/nginx/conf.d

#------------------------------------------------------------------------------
# Nginx config file
#------------------------------------------------------------------------------
log "Nginx config file"

sudo rm /etc/nginx/conf/nginx.conf -f
cat <<EOF > "/etc/nginx/conf/nginx.conf"
worker_processes auto;
# pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 2048;
    use epoll;  # Efficient handling of connections on Linux
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    # access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   20s;
    types_hash_max_size 2048;
    server_tokens       off;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 valid=300s;  # External resolver for OCSP stapling

    # Custom server header for security through obscurity
    more_set_headers 'Server: Apache';

    # Rate limiting setup
    limit_req_zone \$binary_remote_addr zone=one:10m rate=5r/s;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://trustedscripts.example.com;";

    include /etc/nginx/conf.d/*.conf;  # Include all external server blocks

}
EOF
#Configure nginx
log "Nginx domain config file"
cat <<EOF > "/etc/nginx/conf.d/g08-systemsolutions.internal.conf"
upstream backend{
    server $webserver_ip;
}
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name g08-systemsolutions.internal www.g08-systemsolutions.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    ssl_client_certificate /etc/nginx/certs/myCA.crt;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    location / {
        proxy_pass http://backend;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;

        # Error Handling
        error_page 502 503 504 /custom_50x.html;
        location = /custom_50x.html {
            root /usr/share/nginx/html;
            internal;
        }
    }

    location /wordpress/ {
        proxy_pass http://192.168.108.150/wordpress/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

#------------------------------------------------------------------------------
# SELinux Configuration
#------------------------------------------------------------------------------
log "Configuring SELinux"

# Generate SELinux policy for nginx if there are denials
if sudo ausearch -c 'nginx' --raw | audit2allow -M nginx_custom; then
    log "SELinux policy module nginx_custom created."
else
    log "No relevant SELinux denials found. Skipping SELinux policy creation."
fi

# Apply the SELinux module if created
if [ -f nginx_custom.pp ]; then
    sudo semodule -i nginx_custom.pp
    if semodule -l | grep -q nginx_custom; then
        log "SELinux policy module nginx_custom successfully installed."
    else
        log "SELinux policy module installation failed."
    fi
else
    log "SELinux policy module was not created, skipping module installation."
fi

#------------------------------------------------------------------------------
# Additional SELinux Rules for Upstream Connection
#------------------------------------------------------------------------------
log "Adding SELinux rules for NGINX upstream connection"

# Create and apply SELinux module to allow upstream connection
sudo ausearch -m avc -ts recent | audit2allow -M nginx_upstream
sudo semodule -i nginx_upstream.pp

#------------------------------------------------------------------------------
# Firewall Configuration
#------------------------------------------------------------------------------
log "Configuring Firewall"

sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --reload

sudo systemctl restart nginx

# Exit script
log '=== Provisioning completed successfully ==='
exit 0
