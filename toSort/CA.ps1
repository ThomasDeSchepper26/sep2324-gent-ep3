# Leaned on official documentation: 
# https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/install-the-certification-authority
# https://learn.microsoft.com/en-us/powershell/module/adcsdeployment/install-adcscertificationauthority?view=windowsserver2022-ps

$config = Get-Content -Raw -Path ".\CA.json" | ConvertFrom-Json

$activeUser = (Get-WMIObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
$activeUserProfile = (Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.LocalPath -like "*$activeUser*" }).LocalPath
$desktopPath = [System.IO.Path]::Combine($activeUserProfile, "Desktop")

$certExportPath = [System.IO.Path]::Combine($desktopPath, "RootCA.cer")
$pfxExportPath = [System.IO.Path]::Combine($desktopPath, "webCert.pfx")
$gpoBackupPath = [System.IO.Path]::Combine($desktopPath, "GPOBackup")

Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

$caConfig = @{
    CACommonName = $config.CAName
    CAType = 'EnterpriseRootCA'
}

Install-AdcsCertificationAuthority @caConfig

$certTemplate = $config.WebServerCertTemplate
$certName = $config.WebServerCertName
$webServer = $config.WebServerName
$validityYears = $config.WebServerCertValidityYears

$webServerCert = New-SelfSignedCertificate -DnsName $webServer -CertStoreLocation "Cert:\LocalMachine\My" -FriendlyName $certName -NotAfter (Get-Date).AddYears($validityYears)

$pfxPassword = ConvertTo-SecureString -String $config.PfxPassword -Force -AsPlainText
Export-PfxCertificate -Cert $webServerCert -FilePath $pfxExportPath -Password $pfxPassword

Write-Host "Web server certificate exported to $pfxExportPath"

$caCert = Get-ChildItem -Path Cert:\LocalMachine\CA | Where-Object { $_.Issuer -eq $_.Subject }
Export-Certificate -Cert $caCert -FilePath $certExportPath

Write-Host "Root CA certificate exported to $certExportPath"

New-GPO -Name $config.GPOName -Comment $config.GPODescription

$domain = Get-ADDomain
New-GPLink -Name $config.GPOName -Target $domain.DistinguishedName

$gpo = Get-GPO -Name $config.GPOName
Backup-GPO -Guid $gpo.Id -Path $gpoBackupPath

Write-Host "GPO backed up to $gpoBackupPath"

Write-Host "All files have been saved to the desktop of the active user ($activeUser)."

