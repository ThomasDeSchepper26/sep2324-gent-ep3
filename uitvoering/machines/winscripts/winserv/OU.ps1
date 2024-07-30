# Active Directory-structuur maken

# Functie om te controleren of een OU al bestaat
function Check-OUExists {
    param (
        [string]$Path
    )
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$Path'")) {
        return $false
    }
    return $true
}

# Functie om te controleren of een groep al bestaat
function Check-GroupExists {
    param (
        [string]$GroupName
    )
    if (-not (Get-ADGroup -Filter "Name -eq '$GroupName'")) {
        return $false
    }
    return $true
}

# Nieuwe OU's maken voor elke afdeling
$BaseDomain = "DC=ad,DC=g08-systemsolutions,DC=internal"

$OUPath = "OU=IT,$BaseDomain"
if (-not (Check-OUExists -Path $OUPath)) {
    New-ADOrganizationalUnit -Name "IT" -Path $BaseDomain
}

$OUPath = "OU=Marketing,$BaseDomain"
if (-not (Check-OUExists -Path $OUPath)) {
    New-ADOrganizationalUnit -Name "Marketing" -Path $BaseDomain
}

$OUPath = "OU=HR,$BaseDomain"
if (-not (Check-OUExists -Path $OUPath)) {
    New-ADOrganizationalUnit -Name "HR" -Path $BaseDomain
}

$OUPath = "OU=Boekhouding,$BaseDomain"
if (-not (Check-OUExists -Path $OUPath)) {
    New-ADOrganizationalUnit -Name "Boekhouding" -Path $BaseDomain
}

# Gebruikersgroepen maken voor elke afdeling
$GroupName = "IT Team"
if (-not (Check-GroupExists -GroupName $GroupName)) {
    New-ADGroup -Name $GroupName -GroupCategory Security -GroupScope Global -Path "OU=IT,$BaseDomain"
}

$GroupName = "Marketing Team"
if (-not (Check-GroupExists -GroupName $GroupName)) {
    New-ADGroup -Name $GroupName -GroupCategory Security -GroupScope Global -Path "OU=Marketing,$BaseDomain"
}

$GroupName = "HR Team"
if (-not (Check-GroupExists -GroupName $GroupName)) {
    New-ADGroup -Name $GroupName -GroupCategory Security -GroupScope Global -Path "OU=HR,$BaseDomain"
}

$GroupName = "Boekhouding Team"
if (-not (Check-GroupExists -GroupName $GroupName)) {
    New-ADGroup -Name $GroupName -GroupCategory Security -GroupScope Global -Path "OU=Boekhouding,$BaseDomain"
}