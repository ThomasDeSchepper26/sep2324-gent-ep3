# Adapter naam en gewenste IP-adresinstellingen
$InterfaceName = "Ethernet"
$IPAddress = "192.168.108.4"
$SubnetMask = "24"
$Gateway = "192.168.108.1"
$PreferredDNS = "192.168.108.148"
$AlternateDNS = "8.8.8.8"

New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $IPAddress -PrefixLength $SubnetMask
New-NetRoute -InterfaceAlias $InterfaceName -DestinationPrefix 0.0.0.0/0 -NextHop $Gateway

# DNS-instellingen configureren
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $PreferredDNS, $AlternateDNS

# Installeer de RSAT-functies voor Active Directory, Certificate Services, DHCP, DNS en Group Policy Management
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.CertificateServices.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0

# Uitschakelen van lokale gebruikersaccounts
$LocalAccounts = Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.LocalAccount -eq $true }
foreach ($Account in $LocalAccounts) {
    $AccountName = $Account.Name
    if ($AccountName -ne "Administrator") {
        Write-Host "Uitschakelen van lokale gebruikersaccount: $AccountName"
        net user $AccountName /active:no
    }
}

# Instellen van de domeincontroller als het primaire authenticatiemechanisme
$RegKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $RegKey -Name "AutoAdminLogon" -Value 0
Set-ItemProperty -Path $RegKey -Name "ForceAutoLogon" -Value 0
Set-ItemProperty -Path $RegKey -Name "DefaultDomainName" -Value ""
Set-ItemProperty -Path $RegKey -Name "DefaultUserName" -Value ""
Set-ItemProperty -Path $RegKey -Name "DefaultPassword" -Value ""

# Join domain
Add-Computer -DomainName ad.g08-systemsolutions.internal -Credential Administrator -Force

# Toetsenbord instellen
Set-WinUserLanguageList -LanguageList nl-BE -Force
Set-WinUILanguageOverride -Language nl-BE