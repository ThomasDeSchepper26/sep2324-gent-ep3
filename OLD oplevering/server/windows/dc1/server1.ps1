# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# The following script will provision the Windows server
# This script will start by changing some basic settings, after this the AD DC role is installed and configured
# Multiple scripts will be needed for in between boots, no daisy chain to save time on scripting 
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Reading VARS from JSON file
# -------------------------------------------------------------------------------------------------

$configPath = ".\server1.json"
$config = Get-Content -Raw $configPath | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# Basic
# -------------------------------------------------------------------------------------------------

# Start with a clean terminal
Clear-Host

# NIC name for further grabbing
$NIC = Get-NetAdapter -Name "Ethernet"

# Found a similar function on documentation, changed to match our use case
function Set-AzertyKeyboard {
    $validInput = $false

    while (-not $validInput) {
        $userInput = Read-Host "Do you want to change the keyboard layout to azerty? (y/n)"
        
        switch ($userInput.ToLower()) {
            "y" {
                Set-WinUserLanguageList -Force 'en-BE'
                Write-Host "Azerty keyboard layout enabled" -ForegroundColor Green
                $validInput = $true
            }
            "n" {
                Write-Host "No changes made to keyboard layout" -ForegroundColor Green
                $validInput = $true
            }
            default {
                Write-Host "Invalid input. Please enter 'y' to enable Azerty or 'n' to do nothing" -ForegroundColor Red
            }
        }
    }
}

# Functie call
Set-AzertyKeyboard

# -------------------------------------------------------------------------------------------------
# Network configuration
# -------------------------------------------------------------------------------------------------

# Output to show user, script seems to stop shortly
Write-Host "Applying network settings" -ForegroundColor Magenta
Start-Sleep -Seconds 5

# Network settings for the server
$NIC | New-NetIPAddress -IPAddress $config.IPAddress -PrefixLength $config.PrefixLength -DefaultGateway $config.Gateway | Out-Null

# Starting with Google DNS to setup server, will later be changed to it's own IP 
Set-DnsClientServerAddress -InterfaceAlias $NIC.Name -ServerAddresses 8.8.8.8, 8.8.4.4

# Seperate line to exclude IPv6 from setup
Set-NetAdapterBinding -Name $NIC.Name -ComponentID ms_tcpip6 -Enabled $false

Write-Host "Network settings configured for initial steps" -ForegroundColor Green
Start-Sleep -Seconds 5

# -------------------------------------------------------------------------------------------------
# Setup and configuration for AD DC
# -------------------------------------------------------------------------------------------------

# Installing the AD DC role
Write-Host "Installing the AD DC role to the server, this will prompt a reboot" -ForegroundColor Green
Start-Sleep -Seconds 5
Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment

# Configure the domain
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath $config.DatabasePath `
    -DomainMode $config.DomainMode `
    -DomainName $config.DomainName `
    -DomainNetbiosName $config.DomainNetbiosName `
    -ForestMode $config.ForestMode `
    -InstallDns:$true `
    -LogPath $config.LogPath `
    -NoRebootOnCompletion:$true `
    -SysvolPath $config.SysvolPath `
    -Force:$true `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText $config.SafeModeAdministratorPassword -Force) `
    -Confirm:$false `

# Sleep is added to make sure no process is interupted and give time to abort
Write-Host "The server will reboot in 15 seconds, exit the script to abort this" -ForegroundColor Red
Start-Sleep -Seconds 15
Restart-Computer -Force