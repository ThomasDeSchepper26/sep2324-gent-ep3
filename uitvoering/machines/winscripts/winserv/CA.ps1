# Zorg ervoor dat de Temp-directory bestaat
if (-not (Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory
}

# Variabelen instellen
$proxyServerName = "proxy.g08-systemsolutions.internal"  # Naam van de Reverse Proxy-server
$caServerName = "ad.g08-systemsolutions.internal"  # Naam van de CA-server
$caName = "ad-AD-CA"  # Naam van de CA (Vervang dit door de naam van jouw CA)
$domain = (Get-ADDomain).DistinguishedName
$gpoName = "Distribute Root CA Certificate"
$certInf = New-Object -TypeName PSObject -Property @{
    Subject = "CN=$proxyServerName"
    FriendlyName = "Proxy Server Certificate"
    KeyLength = 2048
    HashAlgorithm = "SHA256"
    KeyUsage = "KeyEncipherment, DigitalSignature"
    EnhancedKeyUsage = "Server Authentication"
}
$csrFile = "C:\Temp\proxyserver.req"
$certIssuedFile = "C:\Temp\proxyserver.cer"
$caCertFile = "C:\Temp\RootCA.cer"

# 1. Installeren van IIS en de Certificate Authority (CA) op de CA-server
# Controleer of IIS al geïnstalleerd is
$webFeature = Get-WindowsFeature -Name Web-Server
if (-not $webFeature.Installed) {
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    Write-Host "IIS is geïnstalleerd."
} else {
    Write-Host "IIS is al geïnstalleerd."
}

# Controleer of AD Certificate Services al geïnstalleerd is
$caFeature = Get-WindowsFeature -Name AD-Certificate
if (-not $caFeature.Installed) {
    Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools
    Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -HashAlgorithmName SHA256 -KeyLength 2048 -ValidityPeriod Years -ValidityPeriodUnits 10
    Start-Service -Name ADCS
    Write-Host "AD Certificate Services is geïnstalleerd."
} else {
    Write-Host "AD Certificate Services is al geïnstalleerd."
}

# 2. Genereren van een certificaat voor de proxyserver

# Creëer een INF-bestand voor de CSR-aanvraag op de proxyserver
$infFilePath = "C:\Temp\proxyserver.inf"
$infContent = @"
[NewRequest]
Subject = "CN=$($proxyServerName)"
KeyLength = 2048
HashAlgorithm = SHA256
KeyUsage = CERT_KEY_ENCIPHERMENT_KEY_USAGE
KeyUsageProperty = 0
MachineKeySet = TRUE
[RequestAttributes]
CertificateTemplate = WebServer
"@
$infContent | Out-File -FilePath $infFilePath -Encoding ASCII

# Genereer een CSR met behulp van het INF-bestand op de proxyserver
certreq.exe -new $infFilePath $csrFile

# Controleer of de CSR is aangemaakt
if (-not (Test-Path $csrFile)) {
    Write-Error "CSR bestand niet gevonden: $csrFile"
    exit
}

# Vraag het certificaat aan bij de CA-server
certreq.exe -submit -config "$caServerName\$caName" $csrFile $certIssuedFile

# Controleer of het certificaat is uitgegeven
if (-not (Test-Path $certIssuedFile)) {
    Write-Error "Certificaat bestand niet gevonden: $certIssuedFile"
    exit
}

# Importeer het uitgegeven certificaat op de proxyserver
Import-Certificate -FilePath $certIssuedFile -CertStoreLocation "cert:\LocalMachine\My"

# Koppel het certificaat aan een HTTPS-binding in IIS op de proxyserver
Import-Module WebAdministration

# Verkrijg de Thumbprint van het certificaat
$certThumbprint = (Get-ChildItem -Path cert:\LocalMachine\My | Where-Object { $_.Subject -like "*$proxyServerName*" }).Thumbprint

if ($certThumbprint) {
    # Verwijder eventuele bestaande bindings voor HTTPS om conflicten te voorkomen
    Get-WebBinding -Name "Default Web Site" -IPAddress "*" -Port 443 -Protocol https -ErrorAction SilentlyContinue | Remove-WebBinding

    # Voeg een nieuwe HTTPS-binding toe met het certificaat
    New-WebBinding -Name "Default Web Site" -IPAddress "*" -Port 443 -Protocol https

    # Gebruik netsh om het certificaat aan de binding toe te voegen
    netsh http delete sslcert iplisten=0.0.0.0:443
    netsh http add sslcert iplisten=0.0.0.0:443 certhash=$certThumbprint appid="{00000000-0000-0000-0000-000000000000}"
} else {
    Write-Error "Certificaat niet gevonden voor $proxyServerName."
}

# 3. Distributie van het CA-Certificaat naar Clients via GPO

# Controleer of de GPO al bestaat en verwijder deze indien nodig
$existingGPO = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if ($existingGPO) {
    Remove-GPO -Name $gpoName
    Write-Host "Bestaande GPO '$gpoName' is verwijderd."
}

# Maak een nieuwe GPO en koppel aan het domein
$gpo = New-GPO -Name $gpoName
New-GPLink -Name $gpoName -Target $domain

# Voeg het CA-certificaat toe aan de Trusted Root Certification Authorities in de GPO
# Note: In het geval van aanpassingen in LDAP kan dit handmatig of via andere GPO-instellingen.

# Forceer een GPO update op alle clients
Invoke-GPUpdate -Force

# 4. Controleer of de W3SVC-service draait
$w3svcService = Get-Service W3SVC -ErrorAction SilentlyContinue
if ($w3svcService.Status -ne "Running") {
    Start-Service W3SVC
    Write-Host "W3SVC service is gestart."
} else {
    Write-Host "W3SVC service draait al."
}
