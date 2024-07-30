# Opdrachten

## Inleiding

Met dit project probeer je aan te tonen dat je in staat bent om met je team complexe ICT-infrastructuur geautomatiseerd kan opzetten en kan laten functioneren. Doel is om een volledig functioneel netwerk op te zetten met alle typische services: DNS, centraal gebruikersbeheer, DHCP, ... .

Het is aan het team om te beslissen wie welke taken op zich zal nemen om die uit te werken, te testen en op te leveren. Elk teamlid draagt de eindverantwoordelijkheid voor minstens één deeltaak/component van het netwerk en beschrijft dit in haar/zijn logboek.

Jullie zullen merken dat jullie bij de meeste opdrachten van elkaar afhangen. Maak dus duidelijke afspraken die voor iedereen toegankelijk zijn via de technische documentatie van het project. Streef ernaar om diegenen die van jou afhangen zo goed mogelijk te helpen en hun werk zo vlot mogelijk te maken. Dat kan bestaan uit het ter beschikking stellen van een testomgeving voor de componenten onder jouw verantwoordelijkheid, hulp bij het gebruik ervan, of het vereenvoudigen van het gebruik door automatisering.

## Opgaves

Lees de opgave grondig en doe zo goed mogelijk wat gevraagd wordt. Let er op dat bij verschillende taken addertjes onder het gras zitten, of dat ze bewust vaag geformuleerd zijn. Waar er geen expliciete keuze is opgelegd, kan het team zelf beslissen in samenspraak met de begeleiders. De opgave kan in de loop van het semester, naargelang de omstandigheden, nog bijgestuurd worden. De begeleiders kunnen bijkomende requirements opleggen of desgevallend de scope beperken. Het team kan zelf ook initiatief nemen om (telkens in samenspraak met de begeleiders) extra's te implementeren.

### Situatie

Jullie werken bij een groot softwarebedrijf. Dit bedrijf gaat een nieuwe vestiging openen op een andere locatie. Jullie team is aangesteld door de directie om de infrastructuur van de nieuwe vestiging op te zetten.

Kies gerust zelf een naam voor de vestiging, een logo/kleurenpalet mag je ook maken indien gewenst. Je kan deze gebruiken tijdens de opdrachten om er een eigen persoonlijk accent aan te geven.

### Offerte

Alvorens er direct begonnen wordt met implementatie, moet er eerst eens gekeken worden naar de kost. Wat is er nodig? Hoeveel kost dit? ... ? Met andere woorden, er moet een offerte worden opgesteld. [offerte.md](./offerte.md) geeft je meer informatie over wat er verwacht wordt van de offerte en wat deze moet bevatten.

Er wordt verwacht dat de offerte wordt afgewerkt tegen week 4.

### Basisopdracht

In [basis.md](./basis.md) wordt een basisomgeving omschreven. Dit is een baseline die je moet afwerken, en waar alle andere diensten in de vestiging gebruik van zullen maken. Deze omgeving moet zo geautomatiseerd mogelijk worden opgesteld, zodat je deze snel van scratch kan opzetten.

Er wordt verwacht dat de automatisatie van deze basisomgeving wordt afgewerkt tegen week 7.

### Uitbreidingen

Let op: enkel het opzetten van de basisomgeving is **niet voldoende** om te slagen. Er is een lijst van mogelijke uitbreidingen beschikbaar in [uitbreidingen.md](./uitbreidingen.md) voor de basisomgeving. Minstens twee uitbreidingen zijn het minimum om het project als voldoende te kunnen beschouwen. Werk je als team meer uitdagingen af, dan kan je ook meer scoren in dit vak.

## Verwacht resultaat

We verwachten een werkende basisopstelling met minstens 2 uitbreiding die binnen een bepaald tijdsinterval (bv. 2 uur) vanaf scratch kan opgezet worden dankzij automatisatie.

Daarnaast verwachten we op deze GitHub repo het volgende:

- algemeen:
  - netwerkschema en IP-adrestabel;
- in een directory per deeltaak (= offerte/server):
  - resultaten van de deeltaak:
    - broncode (bv. van scripts, geautomatiseerde tests, ...);
    - Packet Tracer-bestanden;
    - ...
  - lastenboek (zie template [lastenboek.md](./templates/lastenboek.md)):
    - specificaties en requirements;
    - verantwoordelijke voor realisatie, verantwoordelijke voor testen;
    - tijdschatting voor realisatie (in manuur);
      - na realisatie: werkelijk tijdgebruik aanvullen en een verklaring voor het afwijken van de schatting.
  - testplan (zie template [testplan.md](./templates/testplan.md)): Een testplan is een **exacte** procedure van de handelingen die je moet uitvoeren om aan te tonen dat de opdracht volledig volbracht is en dat aan alle specificaties voldaan is. Een teamlid moet aan de hand van deze procedure in staat zijn om de tests uit te voeren en erover te rapporteren (zie testrapport). Geef bij elke stap het verwachte resultaat en hoe je kan verifiëren of dat resultaat ook behaald is.
    - Stel dit op terwijl je bezig bent met het opzetten van de omgeving.
    - Elke instelling die je maakt moet terug te vinden zijn in het testplan.
  - testrapport (zie template [testrapport.md](./templates/testrapport.md)): Een testrapport is het verslag van de uitvoering van het testplan door een teamlid. Dit moet iemand **anders** zijn dan de auteur van het testplan! Deze noteert bij elke stap in het testplan of het bekomen resultaat overeenstemt met wat verwacht werd. Indien niet, dan is het belangrijk om gedetailleerd op te geven wat er misloopt, wat het effectieve resultaat was, welke foutboodschappen gegenereerd werden, ... . De tester kan meteen een Github issue aanmaken en er vanuit het testrapport naar verwijzen. Wanneer het probleem opgelost werd, wordt een nieuwe test uitgevoerd, met een **nieuw** verslag.
    - In het testrapport komen alle zaken die volgens het testplan moesten getest worden terug met ernaast of de test succesvol was. Indien er iets fout liep moet er beschreven worden wat er precies mis ging zodat de verantwoordelijke voor dit onderdeel de nodige aanpassingen kan doen.
    - Je kan ook een testscript schrijven dat een aantal zaken in een keer test. Bij de beschrijving van de test omschrijf je dan de procedure om het script uit te voeren en bij het verwachte resultaat plaats je dan een gedetailleerde beschrijving van het resultaat van het testscript.
  - documentatie:
    - handleiding;
    - nodige software;
    - cheat sheets en procedurebeschrijvingen voor vaak voorkomende taken;
    - ...

VM-images en gelijkaardige grote bestanden horen niet in de GitHub repo. Vermijd ook binaire bestanden (bv. docx, pdf, ...) tenzij je niet anders kan (bv. images, Packet Tracer projecten, ...), en geef zoveel mogelijk de voorkeur aan tekstbestanden (bv. markdown, yaml, bash, powershell, ...).
