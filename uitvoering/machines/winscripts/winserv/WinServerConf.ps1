# Adapter naam en gewenste IP-adresinstellingen
$InterfaceName = "Ethernet"
$IPAddress = "192.168.108.148"
$SubnetMask = "24"
$Gateway = "192.168.108.1"

# Ip address en default gateway instellen
New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $IPAddress -PrefixLength $SubnetMask
New-NetRoute -InterfaceAlias $InterfaceName -DestinationPrefix 0.0.0.0/0 -NextHop $Gateway

# Toetsenbord instellen
Set-WinUserLanguageList -LanguageList nl-BE -Force
Set-WinUILanguageOverride -Language nl-BE