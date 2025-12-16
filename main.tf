resource"azurerm_resource_group" "tf-rg" {
  name     = "tf-rg"
  location = "East US"

tags = {
         environment = "dev"
         project     = "terraform-demo"
  }
}

resource"azurerm_virtual_network" "tf-vnet" {
  name                = local.resource_network_name
  location            = local.resource_location
  resource_group_name = local.resource_group_name
  address_space       = local.subnet_address_prefixes

  
}

resource"azurerm_subnet" "tf-subnet" {  
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.resource_network_name
  address_prefixes     = local.subnets[0].address_prefixes
}
resource"azurerm_subnet" "tf-subnet2"{
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.resource_network_name
  address_prefixes     = local.subnets[1].address_prefixes
}   
resource"azurerm_network_interface" "tf-nic" {
  name                = "tf-nic"
  location            = local.resource_location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfpub-ip.id
  }
}
resource"azurerm_public_ip" "tfpub-ip" {
name = "tfpub-ip"
resource_group_name = local.resource_group_name
location = local.resource_location
allocation_method = "Static"
}
resource"azurerm_network_security_group" "tf-nsg" {
  name                = "tf-nsg"
  location            = local.resource_location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource"azurerm_subnet_network_security_group_association" "tf-subnet-nsg-assoc" {
  subnet_id                 = azurerm_subnet.tf-subnet.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}
resource"azurerm_subnet_network_security_group_association" "tf-subnet2-nsg-assoc" {
  subnet_id                 = azurerm_subnet.tf-subnet2.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}
resource"azurerm_windows_virtual_machine" "tf-vm" {
  name                  = var.vm_name
  resource_group_name   = local.resource_group_name
  location              = local.resource_location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.tf-nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
resource"azurerm_managed_disk" "tf-managed-disk" {
  name                 = "tf-managed-disk"
  location             = local.resource_location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1024
}
resource"azurerm_virtual_machine_data_disk_attachment" "tf-data-disk-attach" {
  managed_disk_id    = azurerm_managed_disk.tf-managed-disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.tf-vm.id
  lun                = 0
  caching            = "ReadOnly"
}