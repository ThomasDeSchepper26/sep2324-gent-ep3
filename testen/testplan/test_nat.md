# Testplan

- Auteur(s) testplan: Thomas De Schepper

## Test: Worden de ip addressen binnen het netwerk omgezet naar publieke addressen?

Testprocedure:

1. Ping van eender welk apparaat binnen het netwerk naar "buiten" met het commando `ping 8.8.8.8`
2. Voer het commando `show ip nat translations` uit in de privileged exec mode op R1
3. Voer het commando `show ip nat statistics` uit in de privileged exec mode op R1

Verwacht resultaat:

-
-

  ![nat translations](./images/)
  ![nat statistics](./images/)