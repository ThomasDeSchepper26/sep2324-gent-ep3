# -------------------------------------------------------------------------------------------------
# Author: Jelle Van Holsbeeck
# Contact: jelle.vanholsbeeck@student.hogent.be
# OLOD: SEP
# -------------------------------------------------------------------------------------------------
# This script will configure the Windows server as a backup domain controller (BDC)
# and a backup DNS server, syncing DNS zone data from the primary DNS.
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Reading VARS from JSON file
# -------------------------------------------------------------------------------------------------

$configPath = ".\server1.json"
$config = Get-Content -Raw $configPath | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# Install and Configure DHCP Role
# -------------------------------------------------------------------------------------------------

Write-Host "Installing the DHCP role on DC2 if not yet present" -ForegroundColor Magenta

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
if (-not $dhcpServers.IPAddress -contains "192.168.115.133") {
    Add-DhcpServerInDC -DnsName "dc2.ad.t01-syndus.internal" -IPAddress "192.168.115.133"
}

$dc1IpAddress = "192.168.115.132" 
$failoverName = "DHCPFailover"

# Create a failover relationship
Add-DhcpServerv4Failover -Name $failoverName -PartnerServer $dc1IpAddress -ScopeId $config.ScopeId -SharedSecret "EenKleinWachtwoordAlsSecret456" 

Restart-Service -Name 'DHCPServer'

Write-Host "Configuration of the DHCP role and failover on DC2 has finished, the script will now exit" -ForegroundColor Green
Start-Sleep -Seconds 5
