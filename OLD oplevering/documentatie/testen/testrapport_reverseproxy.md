# Testrapport

- Uitvoerder(s) test: Ward
- Uitgevoerd op: 25/03/2024
- Github commit: SEP2024T01-110 Aanmaken testrapport reverseproxy

## Test: Heeft de reverseproxy server het juiste ip adres?

Test procedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `ip a` uit.

Verwacht resultaat:

- Het IPv4-adres is `192.168.115.146/30`.

<img src="img/ip_proxy.PNG

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Is nginx goed geïnstalleerd en enabled?

Test procedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo systemctl status nginx` uit.

Verkregen resultaat:

- Loaded: 'enabled'.
- Active: 'active (running)'.

<img src="img/nginx.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Is de firewall actief en enabled?

Testprocedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo systemctl status firewalld` uit in cmd.

Verkregen resultaat:

- Loaded: 'enabled'.
- Active: 'active (running)'.

<img src="img/firewall.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Worden http en https toegestaan door de firewall?

Testprocedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo firewall-cmd --list-all` uit in cmd.

Verkregen resultaat:

- services: "http https".

<img src="img/firewallregel.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Luistert server naar zowel naar http als https?

Testprocedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo cat /etc/nginx/conf.d/t01-netifyn.internal.conf` uit in cmd.

Verkregen resultaat:

- listen => 80 en 443.

<img src="img/http.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Laat Selinux connecteren van Proxy toe?

Testprocedure:

1. Voer script reverseproxySetup.sh uit.
2. Voer het commando `sudo getsebool -a | grep http` uit in cmd.

Verkregen resultaat:

- "httpd_can_network_connect --> on".

<img src="img/selinux.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...
