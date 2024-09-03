# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# The following script will install and setup the DHCP role on the server
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Reading VARS from JSON file
# -------------------------------------------------------------------------------------------------

$configPath = ".\dhcp.json"
$config = Get-Content -Raw $configPath | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# Installation and configuration of the DHCP role
# -------------------------------------------------------------------------------------------------

Write-Host "Installing the DHCP role if not yet present and do the initial configuration" -ForegroundColor Magenta

if (-not (Get-WindowsFeature -Name DHCP).Installed) {
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
}

if ($config) {
    Start-Service -Name 'DHCPServer'
    Add-DhcpServerv4Scope -Name $config.ScopeName -StartRange $config.StartRange -EndRange $config.EndRange -SubnetMask $config.SubnetMask

    if ($config.DnsServer) {
        Write-Output "DNS Servers being set to: $config.dnsServer"
        Set-DhcpServerv4OptionValue -DnsServer $config.DnsServer
        Set-DhcpServerv4OptionValue -DnsServer $config.DnsServer2
    }

    if ($config.DnsDomain) {
        Set-DhcpServerv4OptionValue -DnsDomain $config.DnsDomain
    }
    
}

$dhcpServers = Get-DhcpServerInDC
if (-not $dhcpServers.IPAddress -contains "192.168.115.132") {
    Add-DhcpServerInDC -DnsName "dc1.ad.t01-syndus.internal" -IPAddress "192.168.115.132"
}

Restart-Service -Name 'DHCPServer'

Write-Host "Configuration of the DHCP role has finished, the script will now exit" -ForegroundColor Green
Start-Sleep -Seconds 5