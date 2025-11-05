variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "prefix" {
  type = string
}

variable "hub_vnet_address_space" {
  type = string
}

variable "hub_subnet_address_prefix" {
  type = string
}

variable "spoke1_vnet_address_space" {
  type = string
}

variable "spoke1_subnet_address_prefix" {
  type = string
}

variable "spoke2_vnet_address_space" {
  type = string
}

variable "spoke2_subnet_address_prefix" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "admin_source_ip" {
  type = string
}

