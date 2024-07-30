# Testplan: ACL's

- Auteur(s) testplan: Thomas De Schepper

## Test: Kan client pingen naar proxy?

Testprocedure:

1. Voer het commando `ping 192.168.108.164` uit op de winclient.

Verwacht resultaat:

- De ping faalt omdat de proxy enkel op poort 80 en 443 bereikbaar is.

## Test: Kan client nogsteeds surfen naar de website?

Testprocedure:

1. Surf op de winclient naar `http://ad.g08-systemsolutions`.

Verwacht resultaat:

- Verwachte connecties kunnen nogsteeds gemaakt worden en de website komt tevoorschijn.