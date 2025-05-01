variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  
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