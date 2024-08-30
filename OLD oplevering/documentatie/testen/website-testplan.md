Testplan Website

- Auteur(s) testplan: Jelle

## Prerequistes

Het volgende testplan is bedoeld om te doorlopen na alle linux servers actief staan, eventueel getest met hun eigen testplan. Als de acties in dit testplan lukken, kunnen we er echter ook van uit gaan dat de servers correct geconfigureerd zijn.

## Test: Website connectivity

Testprocedure:

1. Open een webbrowser op de client
2. Surf naar `https://t01-syndus.internal`
3. Accepteer het security risico
4. Open een nieuwe tab
5. Surf in de nieuwe tab naar `https://www.t01-syndus.internal`
6. Accepteer het security risico

Verwacht resultaat:

- De setup page voor WordPress wordt weergegeven op beide domeinen.

## Test: WordPress installatie

Testprocedure:

1. Volg de WordPress procedure om de installatie af te ronden
2. Login op het WordPress admin panel
