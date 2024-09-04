#! /bin/bash

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

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

# Database connection details
readonly db_host='192.168.108.149'
readonly db_user='Administrator'
readonly db_password='23Admin24'
readonly db_name='g08db'
readonly db_table='table'
readonly CMS="wordpress"  # Choose your CMS (e.g., wordpress, drupal, etc.)

# WordPress configuration
readonly WORDPRESS_VERSION="5.9"  # Update to the latest version
readonly WORDPRESS_URL="https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"
readonly WORDPRESS_DIR="/var/www/html/wordpress"

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------
cd /etc/ssh/ && sed -i 's/^#PermitRootLogin/PermitRootLogin/' sshd_config

log "Starting server specific provisioning tasks on ${HOSTNAME}"

# Install and launch Neofetch
log "Installing and initializing Neofetch"
dnf install -y epel-release

# Install and start Apache web server
log "Installing Apache server"
dnf install -y httpd

log "Enabling and starting Apache server"
systemctl start httpd
systemctl enable httpd

# Allow incoming traffic (http and https)
log "Allowing traffic on port 80 (HTTP)"
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# Install PHP for database connection
log "Installing PHP to run PHP scripts"
dnf install -y php php-mysqli php-mysqlnd php-json php-gd php-xml php-mbstring

# Download and install CMS
log "Downloading and installing ${CMS}"
mkdir -p "${WORDPRESS_DIR}"
curl -o /tmp/wordpress.tar.gz "${WORDPRESS_URL}"
tar -xzf /tmp/wordpress.tar.gz -C "${WORDPRESS_DIR}" --strip-components=1
chown -R apache:apache "${WORDPRESS_DIR}"
chmod -R 755 "${WORDPRESS_DIR}"

# Configure WordPress to use the database
log "Configuring WordPress to use the database"
cp "${WORDPRESS_DIR}/wp-config-sample.php" "${WORDPRESS_DIR}/wp-config.php"
sed -i "s/database_name_here/${db_name}/" "${WORDPRESS_DIR}/wp-config.php"
sed -i "s/username_here/${db_user}/" "${WORDPRESS_DIR}/wp-config.php"
sed -i "s/password_here/${db_password}/" "${WORDPRESS_DIR}/wp-config.php"
sed -i "s/localhost/${db_host}/" "${WORDPRESS_DIR}/wp-config.php"

# Restarting Web server to save changes
log "Restarting web server"
sudo systemctl restart httpd

# Genereer SELinux beleid als er denied meldingen zijn
if sudo grep denied /var/log/audit/audit.log | sudo audit2allow -M mypol; then
    log "SELinux beleid gegenereerd"
    if [ -f mypol.pp ]; then
        sudo semodule -i mypol.pp
        log "SELinux beleid geïnstalleerd"
    else
        log "SELinux beleid niet gevonden, overslaan van installatie"
    fi
else
    log "Geen SELinux aanpassingen nodig"
fi

# Voeg het SELinux-commando toe
sudo setsebool -P httpd_can_network_connect_db 1

# Creating index.html page
log "Creating index page"
touch /var/www/html/index.html
cat << 'EOF' >/var/www/html/index.html
<!DOCTYPE html>
<html>
<body>
<h1>Welcome to WordPress</h1>
<p>Click <a href="/wordpress">here</a> to access WordPress.</p>
<p> Click <a href="/info.php">here</a> to have a look at the info of the server.</p>
</body>
</html>
EOF

# Creating info.php file
log "Creating info.php"
touch /var/www/html/info.php
cat << 'EOF' >/var/www/html/info.php
<p> Click <a href="/index.html">here</a> to go back to the index.
<?php phpinfo(); ?>

EOF

# Creating test.php file
log "Creating test.php"
touch /var/www/html/test.php
cat << 'EOF' >/var/www/html/test.php
<html>
<head>
<title>Database Query Trial</title>
<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;900&display=swap" rel="stylesheet">
<style>
table, th, td {
  border-bottom: 1px solid black;
  padding: 10px;
  border-collapse: collapse;
  text-align: center;
}
.center {
  margin-left: auto;
  margin-right: auto;
}
h1 {
  text-align: center;
  font-size: 50px;
}
* {
  font-family: Montserrat;
  font-size: 20px;
}
</style>
</head>
<body>
<h1>Database Query Trial</h1>
<h2>Get back to the previous page by clicking <a href="/index.html">here</a>.</h2>

<?php
// Variables
\$db_host='${db_host}';
\$db_user='${db_user}';
\$db_password='${db_password}';
\$db_name='${db_name}';
\$db_table='${db_table}';

// Connecting, selecting database
\$connection = new mysqli(\$db_host, \$db_user, \$db_password, \$db_name);

if (\$connection->connect_error) {
    die("<p>Could not connect to database server:</p>" . \$connection->connect_error);
}

// Performing SQL query
\$query = "SELECT * FROM \$db_table";
\$result = \$connection->query(\$query);

// Printing results in HTML
echo "<table class=\"center\">\n\t<tr><th>id</th><th>name</th></tr>\n";
while (\$row = \$result->fetch_assoc()) {
    echo "\t<tr>\n";
    echo "\t\t<td>" . \$row["id"] . "</td>\n";
    echo "\t\t<td>" . \$row["name"] . "</td>\n";
    echo "\t</tr>\n";
}
echo "</table>\n";

\$result->close();
\$connection->close();
?>
</body>
</html>
EOF

sudo ip route del default
sudo ip route add default via 192.168.108.147