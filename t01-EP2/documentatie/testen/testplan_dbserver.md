# Testplan

- Auteur(s) testplan: Ward

## Test: Is de rootlogin en password authenticatie disabled?

Test procedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo cat /etc/ssh/sshd_config` uit.
3. Zoek naar 'PermitRootLogin' en 'PasswordAuthentiaction'.

Verwacht resultaat:

- Achter beiden zou er 'no' moeten staan.

## Test: Is het ip adres van de database server correct ingesteld?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `ip a` uit in cmd.

Verwacht resultaat:

- Het IPv4-adres is `192.168.115.131/29`.

## Test: Is MariaDB geïnstalleerd en enabled bij opstarten?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo systemctl status mariadb` uit in cmd.

Verwacht resultaat:

- Loaded: 'enabled' en Active: 'active (running)'.

## Test: Is de database correct gemaakt?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo systemctl status mariadb` uit in cmd.

Verwacht resultaat:

- De database is gemaakt.

## Test: Is de firewall actief en enabled bij opstarten?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo systemctl status firewalld` uit in cmd.

Verwacht resultaat:

- Loaded: 'enabled' en Active: 'active (running)'.

## Test: Heeft de webserver toegang tot de databse?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo firewall-cmd --list-all` uit in cmd.

Verwacht resultaat:

- De regel is toegevoegd bij 'rich rules'.
