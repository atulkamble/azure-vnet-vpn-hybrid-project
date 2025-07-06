resource "azurerm_resource_group" "vpn_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "MySubnet"
  resource_group_name  = azurerm_resource_group.vpn_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix]
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.vpn_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.gateway_subnet_prefix]
}

resource "azurerm_public_ip" "vpn_gateway_pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = var.vpn_gateway_name
  location            = var.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
  type                = "Vpn"
  vpn_type            = var.vpn_type
  active_active       = false
  enable_bgp          = false
  sku                 = var.vpn_sku

  ip_configuration {
    name                          = "vpngwconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
}

resource "azurerm_local_network_gateway" "onprem" {
  name                = "MyOnPremiseGateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
  gateway_address     = var.onprem_gateway_ip
  address_space       = var.onprem_address_prefix
}

resource "azurerm_virtual_network_gateway_connection" "s2s_connection" {
  name                            = "MyS2SConnection"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.vpn_rg.name
  type                            = "IPsec"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id        = azurerm_local_network_gateway.onprem.id
  shared_key                      = var.s2s_shared_key
}
