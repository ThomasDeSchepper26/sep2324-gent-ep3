# Professioneel gebruik van Git

Wanneer je met meerdere personen samenwerkt aan een gemeenschappelijke codebase, vergroot de kans op merge-conflicten. Er zijn verschillende strategieën om dit te vermijden. Je kan als team zelf beslissen hoe je dit gaat aanpakken.

## Voorbereiding

- Gebruik een geschikte GitHub-gebruikersnaam die je ook na je afstuderen nog kan gebruiken. Je HOGENT-login (van de vorm `123456ab`) is niet geschikt. Ook puberale of aanstootgevende nicknames vermijd je best. Je kan indien nodig een nieuw account aanmaken of in je bestaande account je gebruikersnaam wijzigen (klik op je avatar rechtsboven > `Settings` > `Account` > `Change username`).
- Registreer je HOGENT studenten-emailadres in je GitHub account (en voor na je afstuderen liefst ook een privé-adres). Via je studenten-emailadres kan je aanspraak maken op het [GitHub Student Developer Pack](https://education.GitHub.com/pack).
- Genereer een SSH sleutelpaar als je dat nog niet gedaan hebt, en registreer de publieke sleutel op GitHub zodat je op een eenvoudigere manier kan synchroniseren met GitHub.
- Zorg dat je naam en HOGENT-emailadres zeker geconfigureerd zijn in de Git client. Als je dit niet doet, dan wordt het ook moeilijk je commits terug te vinden in de historiek en kan je je bijdrage aan het project niet aantonen. Het is dus erg belangrijk om al van in het begin correct te doen!

  ```console
  git config --global user.name "An Pieters"
  git config --global user.email "an.pieters@student.hogent.be"
  ```

## Algemene richtlijnen

Eerst en vooral is een goede, **overzichtelijke directorystructuur** belangrijk. Mergeconflicten komen vooral voor wanneer verschillende personen tegelijk hetzelfde bestand bewerken. Als je goede afspraken maakt over wie welke bestanden bewerkt, vermijd je al veel problemen.

**Goede commit-boodschappen** zijn ook des te belangrijker om aan je teamleden te communiceren wat je precies gedaan hebt ( https://chris.beams.io/posts/git-commit/ ). Aan boodschappen als "wijzigingen", "fix", "herwerken", "brol", "plz work", enz. heeft niemand iets: noch de begeleiders, noch je teamleden, noch je toekomstige zelf. Je kan afspraken maken over prefixen die aangeven aan welke taak je gewerkt hebt, bv. de hostnaam van de server waaraan je gewerkt hebt: "[bravo]", of algemene aanduidingen als "[doc]", "[fix]", enz. Het nummer van de Git issue kan ook informatief zijn, bv. "[bravo #13]", "[doc #36]", "[fix #42]", enz. Het laatste voorbeeld zal ook Issue #42 sluiten (zorg dus dat je zeker bent dat de issue wel degelijk opgelost is!).

Hou **commits zo klein mogelijk**. Maak zeker niet de fout om slechts één of enkele keren per week een grote commit uit te voeren. Wacht ook niet tot je een component volledig afgewerkt hebt, maar registreer ook deelresultaten. Hoe groter een commit en hoe langer je code niet gesynchroniseerd is met de centrale Git repository, des te meer kansen op merge-conflicten. Commit dus meerdere keren per werksessie, en telkens je één concrete stap vooruit raakt.

**Synchroniseer** ook **heel regelmatig** met de centrale Git repository. Minstens aan het einde van elke sessie dat je aan het project werkt, maar vaker mag zeker.

**Overschrijf nooit publieke historiek**, en gebruik dus **nooit** de volgende commando's:

```console
# Doe het volgende NOOIT!
git reset --hard
git push --force
```

Dit zal voor alle teamleden leiden tot conflicten en mogelijks tot **verlies** van geleverd werk. Als je in je eigen werkkopie van de repository terug wil naar de toestand in
een vorige commit, gebruik je `git revert`.

## Branching & merging, Pull Requests

In vele teams wordt gebruik gemaakt van branches om individuele bijdragen van teamleden gecontroleerd toe te voegen aan de gemeenschappelijke code base. Teamleden werken dan typisch _nooit_ op de main branch. De werkwijze is dan zo:

```console
git pull
git checkout --branch feature/newstuff
# ... wijzigingen ...
git add .
git commit --message "Beschrijvende boodschap"
git push origin feature/newstuff
```

Op de tweede lijn wordt een nieuwe zgn. _topic branch_ gemaakt met de naam "feature/newstuff". Over branch-namen worden typisch ook goede afspraken gemaakt binnen een team. Bijvoorbeeld dat de branch-naam begint met een prefix dat aangeeft wat voor soort wijziging het betreft, bv. "feature/", "fix/" (bug oplossen), "doc/", enz. Vaak wordt er ook verplicht om het nummer van de issue/ticket toe te voegen aan de branch-naam, bv. "feature/22", "feature/22-dns-server", of "fix/56-dhcp-wont-start".

Na het pushen naar de centrale Git repository, kan dan verder gewerkt worden aan een ander ticket. De volgende stap is er dan voor zorgen dat alle wijzigingen in de centrale repository samengevoegd worden (_merge_) met de main branch. In de praktijk worden enkele teamleden verantwoordelijk gesteld voor het integreren van de code. GitHub kan daarbij helpen en zal typisch aangeven of een branch kan samengevoegd worden met main. Het mergen is dan kwestie van op een knop te klikken, een beschrijving toe te voegen en een commitboodschap toe te voegen.

De voordelen van deze werkwijze zijn o.a.:

- Het is makkelijker te garanderen dat de main branch steeds een werkende versie van het project bevat.
- Aan het mergen kan er een Q/A-proces gekoppeld worden dat introductie van fouten vermijdt. Een tester kan het testplan uitvoeren en pas als dit slaagt de branch mergen (met toevoeging van het testrapport, uiteraard). Je kan ook "commit hooks" toevoegen die bij elke commit geautomatiseerde testen uitvoeren, een linter om codestijl te controleren, of een andere Q/A-tool.
- Wanneer verschillende teamleden tegelijk wijzigingen willen pushen (bv. op het einde van een van de contactmomenten), is het makkelijker deze gecontroleerd en één voor één te mergen.

Ook hier zijn echter gevaren aan verbonden:

- Deze werkwijze is een stuk complexer, en elk teamlid moet zich strikt aan de afspraken houden.
- De verantwoordelijke(n) voor de integratie van code is/zijn een bottleneck op de vooruitgang van het project als geheel.
- Er kunnen zich merge-conflicten voordoen bij het samenvoegen die enkel opgelost kunnen worden door communicatie tussen de integratoren en de auteur van de branch-dit kan misverstanden en tijdverlies opleveren.
- Hoe langer een branch een onafhankelijk leven leidt, hoe moeilijker de integratie zal verlopen. Intussen zijn er immers nog wijzigingen door andere teamleden geïntegreerd die impact kunnen hebben op nieuwe toevoegingen.

_Pull-requests_ (PR's) zijn eigenlijk hetzelfde als branches die aangeboden worden om samen te voegen met de main branch. Bij deze werkwijze is het zo dat elk teamlid op een aparte repository werkt, een zgn. fork. Zij maken dan topic-branches aan op de eigen fork waar ze wijzigingen aanbrengen. Als dit werk klaar is, kan je via GitHub deze wijzigingen als een Pull Request naar de originele repository sturen. Dit heeft als voordeel dat wijzigingen gecontroleerd kunnen geïntegreerd worden met de main branch. Het wordt ook gebruikt in projecten waar slechts een kernteam schrijftoegang heeft op de centrale repository, wat voor ons niet van toepassing is. Werken met forks en pull-requests geeft echter nog een extra laag van complexiteit, zoals het synchroniseren van wijzigingen in de centrale repository naar alle forks. Voor dit project is het gebruik van forks en pull requests als werkwijze dan ook af te raden. Het gebruik van branches is voor een project als deze met een beperkt aantal vaste ontwikkelaars voldoende.

## Trunk based development

Onder [_trunk based_ development](https://trunkbaseddevelopment.com/) verstaan we de werkwijze waarbij er geen branches aangemaakt worden, maar elk teamlid rechtstreeks op de _trunk_, de main branch commit.

De eenvoudigste (maar gevaarlijke) werkwijze is:

```console
git pull
# ... wijzigingen ...
git add .
git commit --message "Beschrijvende boodschap"
git push
```

Je haalt de laatste code binnen van de centrale Git repository, maakt lokaal wijzigingen die je registreert (bij voorkeur in verschillende kleine commits) en terug pusht. Er zijn echter enkele gevaren:

- Op het moment dat je een push uitvoert, kunnen er al andere wijzigingen gebeurd zijn. Je moet dan opnieuw een pull uitvoeren en alle wijzigingen samenvoegen (merge) met je lokale wijzigingen.
- Een merge maakt de historiek van de code complexer: het "pad" tussen commits splitst op en komt opnieuw samen. Als dit vaak gebeurt, wat in een groot team waarschijnlijk is, dan wordt het moeilijker de historiek te begrijpen.

Je kan dit vermijden door volgende werkwijze toe te passen:

```console
git pull
# ... wijzigingen ...
git add .
git commit --message "Beschrijvende boodschap"
git pull --rebase
git push
```

Het rebase commando op lijn 5 haalt alle wijzigingen op GitHub binnen, maar zal eerst alle externe wijzigingen toepassen en pas daarna je eigen commit(s). Het zal dus lijken alsof jouw wijzigingen slechts gedaan zijn na de laatste externe commit. Er zal dus geen opsplitsing in het pad tussen commits gebeuren en de historiek blijft lineair.

Als je de globale optie `pull.rebase` aangezet hebt, dan is het niet nodig de optie `--rebase` te specifiëren. Pas daarvoor de volgende aanbevolen basisinstellingen toe:

```console
git config --global pull.rebase true
git config --global rebase.autoStash true
```

Wanneer bij een rebase merge-conflicten optreden, moet je die eerst oplossen door de getroffen bestanden te bewerken en de wijzigingen te committen. Gebruik `git status` om een overzicht te krijgen van bestanden met conflicten. Gebruik na de nodige aanpassingen `git add` om aan te duiden dat het conflict is opgelost en tenslotte `git rebase --continue` om de rebase af te werken.

Als je over dit onderwerp leest in de vakliteratuur, zal je merken dat trunk based development vaak wordt afgeraden omdat het op die manier moeilijker is de kwaliteit van de main branch te garanderen. Elke commit van elk teamlid introduceert potentieel fouten, terwijl je er wil voor zorgen dat de main branch ten allen tijde klaar is om in productie te brengen. Nochtans is in omgevingen waar _Continuous Integration_ toegepast wordt trunk based development de regel. Daar is men van mening dat de introductie van branches teveel complexiteit met zich meebrengt en teveel kans op merge-conflicten, zodat dit niet opweegt tegen de voordelen. Men gebruikt in dat geval andere strategieën om code die nog niet productiewaardig is uit te schakelen (bv. _feature flags_).
Je hebt nu verschillende werkwijzen gezien om met Git te werken. Kies er een van dat het best bij het team past en zorg ervoor dat je met het hele team dezelfde werkwijze hanteert.
