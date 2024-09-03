$GPOConfig = Get-Content -Raw -Path ".\GPOConfig.json" | ConvertFrom-Json

$GPOName = $GPOConfig.GPOName
$CertFilePath = $GPOConfig.CertFilePath
$Domain = $GPOConfig.Domain
$GPOPathTemplate = $GPOConfig.GPOPath

New-GPO -Name $GPOName -Domain $Domain
New-GPLink -Name $GPOName -Target "DC=$Domain,DC=internal"

$GPO = Get-GPO -Name $GPOName
$GPOID = $GPO.Id
$GPOPath = $GPOPathTemplate -replace "{GPOID}", $GPOID

if (-Not (Test-Path -Path $GPOPath)) {
    New-Item -ItemType Directory -Path $GPOPath -Force
}

Copy-Item -Path $CertFilePath -Destination $GPOPath
Invoke-GPUpdate -Force

Write-Host "GPO aangemaakt"
