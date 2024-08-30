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

# Installeer de RSAT-functies voor Active Directory, Certificate Services, DHCP, DNS en Group Policy Management
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.CertificateServices.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0

# Instellen van de domeincontroller als het primaire authenticatiemechanisme
$RegKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $RegKey -Name "AutoAdminLogon" -Value 0
Set-ItemProperty -Path $RegKey -Name "ForceAutoLogon" -Value 0
Set-ItemProperty -Path $RegKey -Name "DefaultDomainName" -Value ""
Set-ItemProperty -Path $RegKey -Name "DefaultUserName" -Value ""
Set-ItemProperty -Path $RegKey -Name "DefaultPassword" -Value ""

# Join domain
Add-Computer -DomainName ad.g08-systemsolutions.internal -Credential Administrator -Force

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "Z:\DisableUsers.ps1"'
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "DisableUsersAtStartup" -Description "Disables all local users at every startup."

Start-Sleep -Seconds 5

Restart-Computer -Force