# -------------------------------------------------------------------------------------------------
# The following script does the configuration of the DNS zone and creates all required records
# Configuration of VARs is done with the JSON file included
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Reading VARS from JSON file
# -------------------------------------------------------------------------------------------------

$configPath = ".\dns.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

# -------------------------------------------------------------------------------------------------
# DNS Configuration
# -------------------------------------------------------------------------------------------------

# Import the DNSServer module
Import-Module DNSServer

# Forwarder
Set-DnsServerForwarder -IPAddress $config.Forwarder

# Create DNS zone
if (-not (Get-DnsServerZone -Name $config.SecondZone -ErrorAction SilentlyContinue)) {
    Add-DnsServerPrimaryZone -Name $config.SecondZone -ReplicationScope "Forest"
}

# Setup Reverse Lookup Zone
Add-DnsServerPrimaryZone -NetworkID $config.NetworkID -ReplicationScope "Forest"

# DNS records
foreach ($record in $config.DNSRecords) {
    Add-DnsServerResourceRecordA -Name $record.Name -ZoneName $record.Zone -IPv4Address $record.IP -CreatePTR
    
    foreach ($alias in $record.Aliases) {
        Add-DnsServerResourceRecordCName -Name $alias -ZoneName $record.Zone -HostNameAlias "$($record.Name).$($record.Zone)"
    }
}
