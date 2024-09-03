# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# This script will do the base settings of DC2 and join the domain
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Reading VARS from JSON file
# -------------------------------------------------------------------------------------------------

$configPath = ".\server1.json"
$config = Get-Content -Raw $configPath | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# Basic Configuration
# -------------------------------------------------------------------------------------------------

Clear-Host

$NIC = Get-NetAdapter -Name "Ethernet"

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

Set-AzertyKeyboard

# -------------------------------------------------------------------------------------------------
# Network Configuration
# -------------------------------------------------------------------------------------------------

Write-Host "Applying network settings" -ForegroundColor Magenta
Start-Sleep -Seconds 5

$NIC | New-NetIPAddress -IPAddress $config.IPAddress -PrefixLength $config.PrefixLength -DefaultGateway $config.Gateway | Out-Null
Set-DnsClientServerAddress -InterfaceAlias $NIC.Name -ServerAddresses 192.168.115.132, 127.0.0.1
Set-NetAdapterBinding -Name $NIC.Name -ComponentID ms_tcpip6 -Enabled $false

Write-Host "Network settings configured for initial steps" -ForegroundColor Green
Start-Sleep -Seconds 5

Add-Computer -DomainName "ad.t01-syndus.internal"