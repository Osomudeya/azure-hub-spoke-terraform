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

variable "spoke_name" {
  description = "Name of the spoke (e.g., 'spoke1', 'web', 'api')"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "spoke_address_space" {
  description = "Address space for Spoke VNet"
  type        = string
}

variable "spoke_subnet_prefix" {
  description = "Address prefix for Spoke subnet"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "admin_source_ip" {
  description = "Source IP for SSH access"
  type        = string
  default     = "*"
}

variable "allowed_spoke_cidrs" {
  description = "List of spoke CIDR ranges allowed to communicate with this spoke"
  type        = list(string)
  default     = []
}
