# Testplan

- Auteur(s) testplan: Ward

## Test: Heeft de reverseproxy server het juiste ip adres?

Test procedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `ip a` uit.

Verwacht resultaat:

- Het IPv4-adres is `192.168.115.146/30`.

## Test: Is nginx goed geïnstalleerd en enabled?

Test procedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo systemctl status nginx` uit.

Verwacht resultaat:

- Loaded: 'enabled'.
- Active: 'active (running)'.

## Test: Is de firewall actief en enabled?

Testprocedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo systemctl status firewalld` uit in cmd.

Verwacht resultaat:

- Loaded: 'enabled'.
- Active: 'active (running)'.

## Test: Worden http en https toegestaan door de firewall?

Testprocedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo firewall-cmd --list-all` uit in cmd.

Verwacht resultaat:

- services: "http https".

## Test: Luistert server naar zowel naar http als https?

Testprocedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo cat /etc/nginx/conf.d/t01-netifyn.internal.conf` uit in cmd.

Verwacht resultaat:

- listen => 80 en 443.

## Test: Laat Selinux connecteren van Proxy toe?

Testprocedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo getsebool -a | grep http` uit in cmd.

Verwacht resultaat:

- "httpd_can_network_connect --> on".
