resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = "westus2"

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
