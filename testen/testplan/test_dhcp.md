# Testplan

- Auteur(s) testplan: Simon Erdmann, Thomas De Schepper

## Test: Is de dhcp pool correct geconfigureerd op router R1?

Testprocedure:

1. Klik op de router R1 in Packet Tracer
2. Open het venster 'CLI'
3. voer het commando `enable` uit in de CLI
4. voer het commando `show ip dhcp pool` uit in de CLI

Verwacht resultaat:

- router R1 bevat een pool 'Werkstations-en-Employees':

## Test: Zijn de juiste IP-adressen geëxclude in de dhcp pool?

Testprocedure:

1. Klik op de router R1 in Packet Tracer
2. Open het venster CLI
3. voer het commando `enable` uit in de CLI
4. voer het commando `show running-config | section dhcp` uit in de CLI

Verwacht resultaat:

- de dhcp pool heeft de correcte ip-adressen geëxclude:

## Test: Krijgt PC een ip-adres van router R1 uit de juiste range?

Testprocedure:

1. Druk win + r op Winclient
2. Typ ncpa.cpl in in de balk
3. Ga naar ipv4 en druk op dhcp
4. Open commando prompt en voer het commando `ipconfig` uit

Verwacht resultaat:

- De Winclient krijgt na een korte periode een geldig IP-adres uit de dhcp pool van router R1:
