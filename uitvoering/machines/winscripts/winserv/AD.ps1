Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Importeer de ADDSDeployment-module
Import-Module ADDSDeployment
# Importeer de GroupPolicy-module
Import-Module GroupPolicy

# Promoot naar DC en configureer AD DS
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "23Admin24" -Force) `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "ad.g08-systemsolutions.internal" `
    -DomainNetbiosName "g08SEP" `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true

# Herstart de computer
Restart-Computer -Force
