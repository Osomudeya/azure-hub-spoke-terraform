variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "spoke_name" {
  description = "Name of the spoke being peered"
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the Hub VNet"
  type        = string
}

variable "spoke_vnet_name" {
  description = "Name of the Spoke VNet"
  type        = string  
}

variable "allow_gateway_transit" {
  description = "Allow gateway transit from hub to spoke"
  type        = bool
  default     = true
}

variable "use_remote_gateways" {
  description = "Allow spoke to use hub gateways"
  type        = bool
  default     = false
}
