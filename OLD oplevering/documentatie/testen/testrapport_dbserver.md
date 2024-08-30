# Testrapport

- Uitvoerder(s) test: Ward
- Uitgevoerd op: 25/03/2024
- Github commit:SEP2024T01-108 Aanmaken testrapport dbserver

## Test: Is de rootlogin en password authenticatie disabled?

Test procedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo cat /etc/ssh/sshd_config` uit.
3. Zoek naar 'PermitRootLogin' en 'PasswordAuthentiaction'.

Verkregen resultaat:

- Achter beiden zou er 'no' moeten staan.

  <img src="img/rootlogin.PNG>
  <img src="img/password.PNG>

  Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Is het ip adres van de database server correct ingesteld?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `ip a` uit in cmd.

Verkregen resultaat:

- Het IPv4-adres is `192.168.115.131/29`:

  <img src="img/ipadres.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Is MariaDB geïnstalleerd en enabled bij opstarten?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo systemctl status mariadb` uit in cmd.

Verkregen resultaat:

- Loaded: 'enabled' en Active: 'active (running)'

  <img src="img/statusmariadb.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Is de database correct gemaakt?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Open cmd en login in mariadb door het commando `sudo mysql -u root -ppassword`.
3. voer het commando `show databases;`.

Verkregen resultaat:

- De database is gemaakt:

  <img src="img/database.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Is de firewall actief en enabled bij opstarten?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo systemctl status firewalld` uit in cmd.

Verkregen resultaat:

- Loaded: 'enabled' en Active: 'active (running)'.

  <img src="img/statusfirewall.PNG>

Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...

## Test: Heeft de webserver toegang tot de databse?

Testprocedure:

1. Voer script dbSetup.sh uit.
2. Voer het commando `sudo firewall-cmd --list-all` uit in cmd.

Verkregen resultaat:

- De regels is toegevoegd bij 'rich rules'.

  <img src="img/firewallrules.PNG>
  
Test geslaagd:

- [X] Ja
- [ ] Nee

Opmerkingen:

- ...
