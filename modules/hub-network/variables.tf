variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "hub_address_space" {
  description = "Address space for Hub VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_subnet_prefix" {
  description = "Address prefix for Hub subnet"
  type        = string
  default     = "10.0.1.0/24"
}
