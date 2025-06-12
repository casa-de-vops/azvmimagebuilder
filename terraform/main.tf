resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

}

resource "azurerm_resource_group" "linux" {
  name     = var.linux_resource_group_name
  location = var.location

}

resource "azurerm_resource_group" "windows" {
  name     = var.windows_resource_group_name
  location = var.location

}

resource "azurerm_shared_image_gallery" "this" {
  name                = "appImageGallery"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  description         = "Shared images and things."

  tags = var.tags
}

resource "azurerm_shared_image" "linux" {
  name                = "GoldenLinuxImage"
  gallery_name        = azurerm_shared_image_gallery.this.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"

  identifier {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
  }
}

resource "azurerm_shared_image" "rhel" {
  name                = "GoldenRHELImage"
  gallery_name        = azurerm_shared_image_gallery.this.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"

  identifier {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "94_gen2"
  }
}

resource "azurerm_shared_image" "windows" {
  name                = "GoldenWindowsImage"
  gallery_name        = azurerm_shared_image_gallery.this.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Windows"

  identifier {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
  }
}

# Sample Linux VM for demonstration
# resource "azurerm_linux_virtual_machine" "example" {
#   name                = "example-vm"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = azurerm_resource_group.this.location
#   size                = "Standard_D2s_v3"
#   admin_username      = "azureuser"
#   network_interface_ids = [azurerm_network_interface.example.id]
#   admin_password      = "P@ssw0rd1234!" # Use a secure method in production
#   disable_password_authentication = false

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#     name                 = "example-osdisk"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts-gen2"
#     version   = "latest"
#   }
# }

# resource "azurerm_network_interface" "example" {
#   name                = "example-nic"
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = "<your-subnet-id>" # Replace with your subnet id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# # Azure Monitor Agent (AMA) extension
# resource "azurerm_virtual_machine_extension" "ama" {
#   name                 = "AzureMonitorLinuxAgent"
#   virtual_machine_id   = azurerm_linux_virtual_machine.example.id
#   publisher            = "Microsoft.Azure.Monitor"
#   type                 = "AzureMonitorLinuxAgent"
#   type_handler_version = "1.0"
#   settings             = "{}"
#   depends_on           = [azurerm_linux_virtual_machine.example]
# }

# # Azure Arc agent (Custom Script Extension)
# resource "azurerm_virtual_machine_extension" "arc" {
#   name                 = "InstallArcAgent"
#   virtual_machine_id   = azurerm_linux_virtual_machine.example.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.1"
#   settings = <<SETTINGS
# {
#   "fileUris": ["https://aka.ms/azcmagent-install.sh"]
# }
# SETTINGS
#   protected_settings = <<PROTECTED
# {
#   "commandToExecute": "bash azcmagent-install.sh"
# }
# PROTECTED
#   depends_on           = [azurerm_linux_virtual_machine.example]
# }
