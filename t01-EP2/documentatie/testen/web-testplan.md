# Testplan

- Auteur(s) testplan: Ward, Jelle

## Test: Uitvoeren script tftp_config.sh + ssh config

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Verifieren dat ssh configuratie juist is door command 'cat /etc/ssh/sshd_config'

Verwacht resultaat:

- PermitRootLogin = no en PasswordAuthentication = no

<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->

## Test: Checken of ip settings juist gedaan zijn

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Voer het commando ip a uit om de ingestelde config te zien

Verwacht resultaat:

- ipv4 addres = 192.168.115.130/29
- ipv4.gateway = 192.168.115.129
- ipv4.method = manual
- autoconnect = yes

<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->

## Test: Testen of nginx correct geinstalleerd is

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Voer het commando 'sudo systemctl status nginx' uit om te checken of nginx correct geïnstalleerd is en werkt

Verwacht resultaat:

- status = active(running)
- preset = enabled

## Test: Testen of de servername correct is veranderd in config bestand van nginx

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Voer het commando sudo cat /etc/nginx/nginx.conf uit
3. zoek naar 'server name ...'

Verwacht resultaat:

- server*name*; zou veranderd moeten zijn in server_name t01-netifyn.internal

## Test: Worden http en https toegelaten door de firewall?

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. voer het commando sudo firewall-cmd --list-all om alle regels van de firewall te bekijken

Verwacht resultaat:

- Bij 'services' zouden http en https toegevoegd zijn

## Test: Testen of PHP correct geïnstalleerd is

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Voer het commando sudo systemctl status php-fpm uit

Verwacht resultaat:

- Status = active(running)
- Preset = enabled

## Test: Testen of wordpress correct gedownload is

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Voer het commando sudo ls /tmp

Verwacht resultaat:

- Onder /tmp zou de file latest.tar.gz staan

## Test: Testen of de user en groep owner rechten correct zijn aangepast

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Voer het commando sudo ld /usr/share/nginx/html/

Verwacht resultaat:

- Bij zowel de user als group zou nu nginx moeten staan

## Test: Testen of het kopieren van wp-config-sample.php naar wp-config.php correct verlopen is

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Voer het commando 'sudo cat /usr/share/nginx/html/wp-config.php'

Verwacht resultaat:

- De inhoud van wp-config-sample.php is gekopieerd naar wp-config.php

## Test: Testen of de gegevens van database correct zijn ingesteld in het wp-config.php bestand

Testprocedure:

1. Uitvoeren van script webSetup.sh
2. Voer het commando 'sudo cat /usr/share/nginx/html/wp-config.php' uit

Verwacht resultaat:

- Achter database name zou nu de naam van de database staan
- Achter username zou de juiste username moeten staan
- Achter password zou nu het juiste password moeten staan
- Achter host zou nu het ip adres van de databaseserver moeten staan
