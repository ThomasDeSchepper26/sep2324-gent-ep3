# Testplan: Databaseserver

- Auteur(s) testplan: Thomas De Schepper

## Check basis

Testprocedure:

1. Start de vm op via `vagrant up dbserver` in de directory /uitvoering/machines en log in met `vagrant ssh dbserver`.
2. Check of selinux actief is met het commando `getenforce`.
3. Check of de MariaDB service actief is met het commando `sudo systemctl status mariadb`.
4. Check of root-login en wachtwoordauthenticatie zijn uitgeschakeld met het commando `sudo grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config`.

Verwacht resultaat:

- Selinux is actief

  ![selinux](./images/getenforce_db.png)

- De MariaDB service is actief

  ![mariadb](./images/mariadb_service.png)

- root-login en wachtwoordauthenticatie zijn uitgeschakeld

  ![sshd_config](./images/sshd_config.png)

## Check databanken

Testprocedure:

1. Open MariaDB met het commando `sudo mysql`.
2. Check of de database aanwezig is met `show databases;`

Verwacht resultaat:

- MariaDB wordt geopend en de database "g08db" is aanwezig

  ![g08db](./images/database_aanwezig.png)