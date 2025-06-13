variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  
}

variable "linux_resource_group_name" {
  description = "Name of the resource group for Linux images"
  type        = string
  default     = "rg-example-westus2-linux-001"
}

variable "windows_resource_group_name" {
  description = "Name of the resource group for Windows images"
  type        = string
  default     = "rg-example-westus2-windows-001"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "westus2"
  
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
  
}

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {
    environment = "dev"
    owner       = "casadevops"
    project     = "azvmimagebuilder"
  }
}