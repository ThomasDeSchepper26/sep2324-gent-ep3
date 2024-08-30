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

# Installation of the root CA with values out of JSON
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