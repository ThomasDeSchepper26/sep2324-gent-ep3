# Testrapport VBoxManage

- Uitvoerder(s) test: Ward
- Uitgevoerd op: 23/04/2024
- Github commit:

## Test: Vboxmanage script om Windows VMs aan te maken

Test procedure:

1. Open Powershell in de map van het VBoxManage script
2. Voeg de iso's toe ter vervanging van de dummy files
3. Voer het script uit (eventueel permissions aanpassen om de run toe te laten)

Verkregen resultaat:

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerkingen:

- Test geeft volgende error aan => na downloaden van iso en toevoegen in config.txt bestand opgelost.

![tr1](./img/wSrv-testrapport1.png)
![tr2](./img/wSrv-testrapport2.png)

### Test: Resources en bridged adapter correct ingesteld

Testprocedure:

1. Open de VirtualBox GUI
2. Valideer van de VMs dat de resources overeenkomen met het configbestand en de NIC bridged is

Verkregen resultaat:

- De resources van de VM's komen overeen met het configbestand en de NIC is bridged.

![tr3](./img/wSrv-testrapport3.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

## Test: Unattended installation

Testprocedure:

1. Open de Virtualbox GUI en "show" beide VMs
2. Laat de installatie afronden en "show" beide VMs opnieuw

Verkregen resultaat:

- Beide VM's zijn geïnstalleerd en ingelogd met administratie gebruiker

![tr5](./img/wSrv-testrapport5.png)
![tr6](./img/wSrv-testrapport6.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

## Test: Shared folder

Testprocedure:

1. Open de Windows Server VM
2. Exit naar command line met optie "15"
3. Navigeer met `cd` naar de `Z:\` drive
4. Open de Windows Client VM
5. Valideer aan de hand van de GUI of de shared drive aanwezig is

Verkregen resultaat:

-De navigatie is gelukt => de shared folder is zichtbaar

![tr4](./img/wSrv-testrapport4.png)

Test geslaagd:

- [X] Ja
- [ ] Nee
