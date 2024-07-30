# Testplan

- Auteur(s) testplan: Thomas De Schepper

## Test: Kunnen de netwerkapparaten de running-config ophalen?

Testprocedure:

1. Voer het commando `copy tftp running-config` in
2. Voer het ip address `192.168.108.133` in
3. Voer de naam van de config file in startend met de hostname gevolgd door _startup-config.txt bv. voor S1 `S1_startup-config.txt`

Verwacht resultaat:

- Het netwerkapparaat wordt automatisch geconfigureerd
  
  ![netwerkapparaat wordt geconfigureerd](./images/)

## Test: Kunnen de netwerkapparaten hun running-config kopiëren naar de tftp server?

Testprocedure:

1. Voer het commando `copy running-config tftp` in
2. Voer het ip address `192.168.108.133` in
3. Kies een naam voor het bestand bv. `test.txt`

Verwacht resultaat:

- Het netwerkapparaat kopieert zijn running-config naar de tftp server
- het bestand is te zien in de map /var/lib/tftpboot/ op de tftp server

  ![netwerkapparaat kopieert zijn running-config](./images/)
  ![bestand in map op tftp server](./images/)