terraform {
  backend "local" {
    
  }
  # backend "azurerm" {
  #   use_azuread_auth = true
  #   use_oidc         = true

  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}