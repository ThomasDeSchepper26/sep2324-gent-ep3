# Leaned on official documentation: 
# https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/install-the-certification-authority
# https://learn.microsoft.com/en-us/powershell/module/adcsdeployment/install-adcscertificationauthority?view=windowsserver2022-ps
# https://learn.microsoft.com/en-us/dotnet/framework/wcf/feature-details/how-to-create-temporary-certificates-for-use-during-development
# Further documentation:
# https://sslinsights.com/self-signed-ssl-certificate-in-powershell/
# https://iceburn.medium.com/generate-self-signed-certificate-with-powershell-31c4ec91f9b6
# https://gist.github.com/jrotello/e3a744334f6324fcea32a6ec3941e0a2
# https://pleasantpasswords.com/info/pleasant-password-server/b-server-configuration/2-certificates/setting-up-a-self-signed-certificate


$CAconfig = Get-Content -Raw -Path ".\CAconfig.json" | ConvertFrom-Json

# Check if script is run as administrator and quit otherwise 
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdministrator -eq $false) {
    Write-Host ($writeEmptyLine + "# Please run PowerShell as Administrator" + $writeSeperatorSpaces + $currentTime)`
    -foregroundcolor $foregroundColor1 $writeEmptyLine
    Start-Sleep -s 5
    exit
}

Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools

Install-AdcsCertificationAuthority -CAType $CAConfig.CAType `
                                   -CACommonName $CAConfig.CACommonName `
                                   -KeyLength $CAConfig.KeyLength `
                                   -HashAlgorithmName $CAConfig.HashAlgorithmName `
                                   -ValidityPeriod $CAConfig.ValidityPeriod `
                                   -ValidityPeriodUnits $CAConfig.ValidityPeriodUnits `
                                   -DatabaseDirectory $CAConfig.DatabaseDirectory `
                                   -LogDirectory $CAConfig.LogDirectory

Start-Service ADCS

# Generation of the certificate
$webServerTemplate = Get-CATemplate | Where-Object { $_.Name -eq "Web Server" }
$customTemplate = $webServerTemplate.Duplicate()

# To move to JSON
$customTemplate.DisplayName = "InternalWebServer"
$customTemplate.ValidityPeriod = "Years"
$customTemplate.ValidityPeriodUnits = 5
$customTemplate.PublishingFlags = "AllowAutoEnroll"

$customTemplate | Add-CATemplate

$CAName = (Get-ADCSCertificationAuthority).Name

$certRequest = @{
    Subject              = "CN=web.g08-syndus.internal"
    Template             = "InternalWebServer"
    CertStoreLocation    = "Cert:\LocalMachine\My"
    DnsName              = "web.g08-syndus.internal"
}

$cert = New-SelfSignedCertificate @certRequest

$PfxPassword = ConvertTo-SecureString -String "YourP@ssw0rd" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "C:\Certs\internalwebserver.pfx" -Password $PfxPassword

Export-Certificate -Cert $CAName -FilePath "C:\Certs\RootCA.cer"

Import-Module GroupPolicy
$gpo = New-GPO -Name "Deploy Root CA Certificate"
$gpoPath = "LDAP://cn=Public Key Services,cn=Public Key Services,CN=Services,CN=Configuration,DC=yourdomain,DC=com"
Import-Certificate -FilePath "C:\Certs\RootCA.cer" -CertStoreLocation "Cert:\LocalMachine\Root"

New-GPLink -Name "Deploy Root CA Certificate" -Target "LDAP://DC=g08-syndus,DC=internal"

Write-Host "Certificate Authority setup complete, certificate issued and GPO created for deployment."

