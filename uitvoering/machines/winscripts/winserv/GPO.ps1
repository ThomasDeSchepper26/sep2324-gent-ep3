# Variabelen instellen
$BaseDomain = "ad.g08-systemsolutions.internal"
$GPOName = "Disable Command Prompt voor Boekhouding"
$OUPath = "OU=Boekhouding,DC=ad,DC=g08-systemsolutions,DC=internal"

# Importeer de GroupPolicy module
Import-Module GroupPolicy

# Controleer of de GPO al bestaat in het domein
if (Get-GPO -Server $BaseDomain -Name $GPOName -ErrorAction SilentlyContinue) {
    Write-Host "De GPO '$GPOName' bestaat al"
} else {
    # Als de GPO niet bestaat, maak dan een nieuwe aan om de toegang tot de command prompt te blokkeren
    New-GPO -Domain $BaseDomain -Name $GPOName -Comment "Blokkeert toegang tot de command prompt voor compliance."
    Write-Host "Nieuwe GPO '$GPOName' is aangemaakt"

    # Implementeer de policy om de command prompt te blokkeren
    Set-GPPrefRegistryValue -Name $GPOName -Context User -Action Update -Key "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWORD -Value 2
    Write-Host "Gebruik van de command prompt is geblokkeerd voor gebruikers in de Boekhouding OU"
}

# Koppel de nieuwe of bestaande GPO aan de relevante Organizational Unit (OU)
Get-GPO -Name $GPOName | New-GPLink -Target $OUPath -LinkEnabled Yes
Write-Host "GPO '$GPOName' is nu gekoppeld aan '$OUPath'."

# Forceer een groepsbeleid-update om de instellingen direct toe te passen
Invoke-GPUpdate -Force
Write-Host "Groepsbeleid is geüpdatet in het netwerk."
