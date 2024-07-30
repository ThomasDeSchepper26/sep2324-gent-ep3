# Variabelen instellen
$BaseDomain = "DC=ad,DC=g08-systemsolutions,DC=internal"
$GPOName = "Disable PowerShell voor Boekhouding"

# Importeer de GroupPolicy module
Import-Module GroupPolicy
#Install FileServerResourceManager
Install-WindowsFeature -Name FileAndStorage-Services

# Creëer een nieuw GPO
New-GPO -Name $GPOName -Comment "Deze GPO blokkeert PowerShell toegang voor de OU Boekhouding"

# Verkrijg de GPO om te bewerken
$GPO = Get-GPO -Name $GPOName

# Configureer de policy om PowerShell script uitvoering te verbieden
Set-GPRegistryValue -Name $GPO.DisplayName -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" -ValueName "EnableScripts" -Type DWord -Value 0

# Koppel het GPO aan de OU
$OUPath = "OU=Boekhouding,DC=ad,DC=g08-systemsolutions,DC=internal"
New-GPLink -Name $GPOName -Target $OUPath -Enforced Yes