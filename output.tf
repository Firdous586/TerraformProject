output"tf-subnet_id" {
  value = azurerm_subnet.tf-subnet.id
}
output"tf-nic_id" {
  value = azurerm_network_interface.tf-nic.id
}
output"tfpub-ip_id" {
  value = azurerm_public_ip.tfpub-ip.id
}
