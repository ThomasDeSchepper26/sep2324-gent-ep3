# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# This script will promote the server to a second DC
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Reading VARS from JSON file
# -------------------------------------------------------------------------------------------------

$configPath = ".\server1.json"
$config = Get-Content -Raw $configPath | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# Setup and configuration for second domain controller
# -------------------------------------------------------------------------------------------------

Write-Host "Configuring the server as a second domain controller with replication of the first dc" -ForegroundColor Magenta
Start-Sleep -Seconds 15
Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature
Install-WindowsFeature RSAT-AD-PowerShell
Import-Module ActiveDirectory 

$domainName = $config.DomainName
$safeModeAdminPassword = $config.SafeModePassword
$siteName = $config.SiteName

$secureSafeModePassword = ConvertTo-SecureString -String $safeModeAdminPassword -AsPlainText -Force

Install-ADDSDomainController `
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$true `
    -Credential (Get-Credential) `
    -CriticalReplicationOnly:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainName $domainName `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SiteName $siteName `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true `
    -SafeModeAdministratorPassword $secureSafeModePassword `
