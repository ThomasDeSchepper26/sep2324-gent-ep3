# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# The following script will finialize the configuration of the domain and add AD users
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Reading VARS from JSON file
# -------------------------------------------------------------------------------------------------

# JSON imports as configuration file
$configPath = ".\adConfig.json"
$config = Get-Content -Raw $configPath | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# AD configuratie
# -------------------------------------------------------------------------------------------------

$topOUDN = "OU=$($config.TopOU),$($config.Domein)"

if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$topOUDN'")) {
    New-ADOrganizationalUnit -Name $config.TopOU -Path "$($config.Domein)"
}

$deviceOUs = $config.DeviceOUs
foreach ($ou in $deviceOUs) {
    $deviceOUDN = "OU=$ou,OU=$($config.TopOU),$($config.Domein)"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$deviceOUDN'")) {
        New-ADOrganizationalUnit -Name $ou -Path "OU=$($config.TopOU),$($config.Domein)"
    }
}

$computersOUDN = "OU=Computers,OU=$($config.TopOU),$($config.Domein)"
redircmp $computersOUDN

$departmentsOUDN = "OU=$($config.DepartmentsOU),OU=$($config.TopOU),$($config.Domein)"

if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$departmentsOUDN'")) {
    New-ADOrganizationalUnit -Name $config.DepartmentsOU -Path $topOUDN
}

foreach ($ou in $config.SubOUs) {
    $specificOUDN = "OU=$ou,$departmentsOUDN"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$specificOUDN'")) {
        New-ADOrganizationalUnit -Name $ou -Path $departmentsOUDN
    }
}

# Function to add users to groups if they are not already members
function Add-UserToGroupIfNotMember {
    param(
        [string]$UserName,
        [string]$GroupName
    )
    
    $userDistinguishedName = (Get-ADUser -Identity $UserName).DistinguishedName
    $groupMembers = Get-ADGroupMember -Identity $GroupName | Select-Object -ExpandProperty DistinguishedName

    if ($userDistinguishedName -notin $groupMembers) {
        Add-ADGroupMember -Identity $GroupName -Members $UserName
    } else {
        Write-Host "$UserName is already a member of $GroupName."
    }
}

# Users setup
foreach ($user in $config.Gebruikers) {
    $ouPath = "OU=$($user.OU),OU=$($config.DepartmentsOU),OU=$($config.TopOU),$($config.Domein)"
    $newUserParams = @{
        SamAccountName         = $user.Naam
        UserPrincipalName      = "$($user.Naam)@t01-syndus.com"
        Name                   = $user.Naam
        GivenName              = $user.Naam
        Surname                = "Demo"
        Enabled                = $true
        AccountPassword        = (ConvertTo-SecureString "Wachtwoord123*" -AsPlainText -Force)
        Path                   = $ouPath
        PasswordNeverExpires   = $false
        ChangePasswordAtLogon  = $true
    }
    $newUser = New-ADUser @newUserParams -PassThru
    
    # Add users to group with function defined above
    if ($user.IsAdmin) {
        Add-UserToGroupIfNotMember -UserName $newUser.SamAccountName -GroupName "Domain Admins"
    } else {
        Add-UserToGroupIfNotMember -UserName $newUser.SamAccountName -GroupName "Domain Users"
    }
}