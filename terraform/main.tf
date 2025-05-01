data "azurerm_resource_group" "this" {
  name = var.resource_group_name

}

resource "azurerm_shared_image_gallery" "this" {
  name                = "appImageGallery"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  description         = "Shared images and things."

  tags = var.tags
}

