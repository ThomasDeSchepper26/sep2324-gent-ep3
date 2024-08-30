# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# The following script will do the creation of the shared folder and add a subfolder for each user
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Reading VARS from JSON file
# -------------------------------------------------------------------------------------------------

# JSON imports as configuration file
$configPath = ".\adConfig.json"
$config = Get-Content -Raw $configPath | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# Creation and mapping shared folder
# -------------------------------------------------------------------------------------------------

$sharedFolderPath = "C:\Shared"
if (-not (Test-Path $sharedFolderPath)) {
    New-Item -ItemType Directory -Path $sharedFolderPath
}

$shareName = "SharedFolder"
if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $shareName -Path $sharedFolderPath -FullAccess "EVERYONE"
}

foreach ($user in $config.Gebruikers) {
    $userFolderPath = Join-Path -Path $sharedFolderPath -ChildPath $user.Naam
    if (-not (Test-Path $userFolderPath)) {
        New-Item -ItemType Directory -Path $userFolderPath
    }

    $acl = Get-Acl $userFolderPath
    $userAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "$($user.Naam)", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $adminAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.SetAccessRule($userAccessRule)
    $acl.SetAccessRule($adminAccessRule)
    $acl | Set-Acl -Path $userFolderPath

    $shareUser = $user.Naam + "$"
    New-SmbShare -Name $shareUser -Path $userFolderPath -FullAccess "$($user.Naam)", "Administrators"
}