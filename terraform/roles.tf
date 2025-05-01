resource "azurerm_role_definition" "this" {
  name        = "Image Creation Role"
  scope       = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  description = "Azure Image Builder access to create resources for the image build"

  permissions {
    actions = [
        "Microsoft.Compute/galleries/read",
        "Microsoft.Compute/galleries/images/read",
        "Microsoft.Compute/galleries/images/versions/read",
        "Microsoft.Compute/galleries/images/versions/write",
        "Microsoft.Compute/images/write",
        "Microsoft.Compute/images/read",
        "Microsoft.Compute/images/delete"
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}", # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}

resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  name                = "rai-identity"
}

resource "azurerm_role_assignment" "this" {
  principal_id   = azurerm_user_assigned_identity.this.principal_id
  role_definition_name = azurerm_role_definition.this.name
  scope          = data.azurerm_resource_group.this.id
}