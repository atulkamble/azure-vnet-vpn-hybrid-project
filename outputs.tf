output "vpn_gateway_public_ip" {
  value = azurerm_public_ip.vpn_gateway_pip.ip_address
}
