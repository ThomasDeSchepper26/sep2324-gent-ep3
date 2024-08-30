# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# The following script will provision the Windows client of our setup and the RSAT tools
# This script is also used to join our domain
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# VARS
# -------------------------------------------------------------------------------------------------

$configPath = ".\client1.json"
$config = Get-Content -Raw $configPath | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# Basic checks and configurations
# -------------------------------------------------------------------------------------------------

Clear-Host

# Administator check
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You require admin privileges to run this script, please rerun the script with admin privileges" 
    Start-Sleep 10
    Break
}

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

$NIC = Get-NetAdapter -Name "Ethernet"

Set-NetAdapterBinding -Name $NIC.Name -ComponentID ms_tcpip6 -Enabled $false

# -------------------------------------------------------------------------------------------------
# Install RSAT
# -------------------------------------------------------------------------------------------------

Write-Host "Installing the missing RSAT tools" -ForegroundColor Magenta

# https://www.pdq.com/blog/how-to-install-remote-server-administration-tools-rsat/
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online | Out-Null
Start-Sleep -Seconds 5

# -------------------------------------------------------------------------------------------------
# Join domain
# -------------------------------------------------------------------------------------------------

Write-Host "Joining the domain with values out of config file" -ForegroundColor Magenta

$domain = $config.Domain
$username = $config.Username
$password = $config.Password | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Add-Computer -DomainName $domain -Credential $credential -Force

# To catch an error in case it's needed 
Start-Sleep -Seconds 5

# -------------------------------------------------------------------------------------------------
# Set up AutoLogon for Domain Administrator
# -------------------------------------------------------------------------------------------------

Write-Host "Setting up the autologin" -ForegroundColor Magenta

$autoLogonUsername = $config.Username
$autoLogonDomain = $config.Domain
$autoLogonPassword = $config.Password

# Set AutoLogon registry keys
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $autoLogonUsername
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value $autoLogonDomain
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $autoLogonPassword

Write-Host "Autologin has been configured. The system will automatically log in as $autoLogonDomain\$autoLogonUsername on next restart." -ForegroundColor Green

Start-Sleep -Seconds 5

Restart-Computer -Force
