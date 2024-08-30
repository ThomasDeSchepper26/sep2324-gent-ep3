# Procedure voor GPO setup

## Disable lokale gebruiker accounts

1. Op de client, open de "Group Policy Management Console" via `gpmc.msc` in het Windows runscreen
2. Navigaar naar de "Computers" OU onder ons domein en kies de optie "Create a GPO in this domain, and Link it here..."
3. Geef een gepaste naam aan de GPO
4. Right click de nieuw aangemaakte entry uit de lijst en kies voor "Edit"
5. Volg het volgende path "Computer Configuration > Policies > Windows Settings > Scripts"
6. Right click de "Startup" optie en selecteer "Properties"
7. Klik de "PowerShell Scripts" en voeg het script toe dat te vinden is onder de shared folder, client map met de naam "disableLocal.ps1"
8. Klik op Apply en sluit het venster

## Disable users voor bepaalde machines

1. Op de client, open de "Group Policy Management Console" via `gpmc.msc` in het Windows runscreen
2. Navigeer naar de "Domain Controllers" default OU en kies de optie "Create a GPO in this domain, and Link it here..."
3. Geef een gepaste naam aan de GPO
4. Right click de nieuw aangemaakte entry uit de lijst en kies voor "Edit"
5. Volg het volgende path "Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Right Assignment"
6. Zoek naar de "Allow log on locally" entry en right click deze en kies "Properties"
7. Voeg de volgende groep toe "T01SYNDUS\Domain Admins" en "Administrators"
8. Klik "OK" en "Apply"
9. Sluit het venster

## Opvolging

1. Open een powershell window op de client
2. Run het commando `gpupdate /force"
3. Restart de client
