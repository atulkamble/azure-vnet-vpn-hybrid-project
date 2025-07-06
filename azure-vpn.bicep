param location string = 'eastus'
param resourceGroupName string = 'MyVPNResourceGroup'
param vnetName string = 'MyVNet'
param vnetAddressSpace string = '10.0.0.0/16'
param subnetPrefix string = '10.0.1.0/24'
param gatewaySubnetPrefix string = '10.0.255.0/27'
param publicIpName string = 'MyVPNGatewayPublicIP'
param vpnGatewayName string = 'MyVPNGateway'
param vpnType string = 'RouteBased'
param vpnSku string = 'VpnGw1'

resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [vnetAddressSpace] }
    subnets: [
      { name: 'MySubnet' properties: { addressPrefix: subnetPrefix } }
      { name: 'GatewaySubnet' properties: { addressPrefix: gatewaySubnetPrefix } }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2024-03-01' = {
  name: publicIpName
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

resource vpngw 'Microsoft.Network/virtualNetworkGateways@2024-03-01' = {
  name: vpnGatewayName
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnType: vpnType
    sku: { name: vpnSku }
    ipConfigurations: [
      {
        name: 'vpngwconfig'
        properties: {
          publicIPAddress: { id: pip.id }
          subnet: { id: vnet.properties.subnets[1].id }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

output vpnGatewayIp string = pip.properties.ipAddress
