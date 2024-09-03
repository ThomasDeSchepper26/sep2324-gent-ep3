$CertConfig = Get-Content -Raw -Path ".\CertConfig.json" | ConvertFrom-Json

# Map JSON to VARs (easier to work with in the command lines)
$CertName = $CertConfig.CertName
$CertPassword = ConvertTo-SecureString -String $CertConfig.CertPassword -Force -AsPlainText
$KeyLength = $CertConfig.KeyLength
$HashAlgorithm = $CertConfig.HashAlgorithm
$ValidityYears = $CertConfig.ValidityYears

# Create directory to save the cert
$CertDirectory = "C:\Certificaten"
if (-Not (Test-Path -Path $CertDirectory)) {
    New-Item -ItemType Directory -Path $CertDirectory
}

$CertFilePath = "$CertDirectory\WebCert.pfx"

$CertReq = New-SelfSignedCertificate -DnsName $CertName -CertStoreLocation "Cert:\LocalMachine\My" -KeyLength $KeyLength -HashAlgorithm $HashAlgorithm -NotAfter (Get-Date).AddYears($ValidityYears)

Export-PfxCertificate -Cert "Cert:\LocalMachine\My\$($CertReq.Thumbprint)" -FilePath $CertFilePath -Password $CertPassword
Write-Host "Certificaat te vinden in: $CertFilePath"