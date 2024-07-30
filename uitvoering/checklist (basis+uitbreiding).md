# basis

| Opdracht Basis              | Wat                                                            | Waar testen    |
|-----------------------------|----------------------------------------------------------------|----------------|
| show vlan brief             | show vlan brief: names + gebruikte poorten                     | switch         |
| show interfaces description / copy running-config tftp | voeg een description toe op de trunk link + backup naar tftp   | switch         |
| ncpa.cpl -> ipconfig        | DHCP lease van client                                          | win client     |
| ping 8.8.8.8                | ping naar 8.8.8.8 (IP werkt)                                   | win client     |
| ping www.belnet.be          | ping naar www.belnet.be (DNS werkt)                            | win client     |
| Thomas 23log&in24 Powershell | Bewijs dat een (domain)gebruiker geen rechten heeft op een network share (en domain admin wel) | winclient |
| Thomas kan script niet uitvoeren, admin wel | Toon de werking van een GPO aan d.h.v. een demo                 | win client     |
| ping 192.168.108.164        | ping naar het IP van de reverse proxy                          | win client     |
| ping 192.168.108.150        | ping naar het IP van de webserver                              | win client     |
| nslookup g08-systemsolutions.internal | nslookup van <jouw groepsnaam>.internal                | win client     |
| https://g08-systemsolutions.internal | Surf naar https://<jouw groepsnaam>.internal (*)                | win client     |
|                             | Log in en maak een post aan op de CMS van jouw intranet        | win client     |
|                             | Access log: toon jouw request (*) in de log files              | linux HTTP     |
|                             | Access log: toon jouw request (*) in de log files              | linux proxy    |
|                             | Scan de proxy server met nmap (nmap -sV -n -p 80,443 192.168.108.164) | eender waar    |

# uitbreiding

| Uitbreiding | Wat                                                  | Waar testen |
|-------------|------------------------------------------------------|-------------|
|             | client laat je permanent pingen naar 8.8.8.8         | win client  |
|             | trek de kabel van de master router uit ping moet automatisch terug doorgaan | win client |
|             | log in op de slave router. Toon dat hij standby is;  | router      |
|             | toon dat hij master geworden is na het verbreken van de kabel naar R1 | router      |
|             | sudo nmap -sV op reverse proxy: de software mag niet zichtbaar zijn in de output | eender waar |
