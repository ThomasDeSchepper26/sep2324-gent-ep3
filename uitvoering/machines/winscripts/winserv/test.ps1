Remove-NetIPAddress -InterfaceAlias Ethernet -confirm:$False
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.108.148 -PrefixLength 28 -DefaultGateway 192.168.108.147