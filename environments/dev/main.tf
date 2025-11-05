terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Local values for common configuration
locals {
  common_tags = {
    Environment = "Development"
    Project     = "Hub-Spoke-Demo"
    ManagedBy   = "Terraform"
    Owner       = var.prefix
  }
}

# Resource Group - Shared foundation
module "resource_group" {
  source = "../../modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.common_tags
}

# Hub Network - Central connectivity
module "hub_network" {
  source = "../../modules/hub-network"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  prefix              = var.prefix
  hub_address_space   = var.hub_vnet_address_space
  hub_subnet_prefix   = var.hub_subnet_address_prefix
  tags                = local.common_tags

  depends_on = [module.resource_group]
}

# Spoke 1 Network - First workload
module "spoke1_network" {
  source = "../../modules/spoke-network"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  prefix              = var.prefix
  spoke_name          = "spoke1"
  spoke_address_space = var.spoke1_vnet_address_space
  spoke_subnet_prefix = var.spoke1_subnet_address_prefix
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  admin_source_ip     = var.admin_source_ip
  allowed_spoke_cidrs = [var.spoke2_vnet_address_space]
  tags                = local.common_tags

  depends_on = [module.resource_group]
}

# Spoke 2 Network - Second workload  
module "spoke2_network" {
  source = "../../modules/spoke-network"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  prefix              = var.prefix
  spoke_name          = "spoke2"
  spoke_address_space = var.spoke2_vnet_address_space
  spoke_subnet_prefix = var.spoke2_subnet_address_prefix
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  admin_source_ip     = var.admin_source_ip
  allowed_spoke_cidrs = [var.spoke1_vnet_address_space]
  tags                = local.common_tags

  depends_on = [module.resource_group]
}

# Hub to Spoke1 Peering
module "hub_spoke1_peering" {
  source = "../../modules/vnet-peering"

  resource_group_name = module.resource_group.resource_group_name
  prefix              = var.prefix
  spoke_name          = "spoke1"
  hub_vnet_name       = module.hub_network.hub_vnet_name
  spoke_vnet_name     = module.spoke1_network.spoke_vnet_name

  depends_on = [module.hub_network, module.spoke1_network]
}

# Hub to Spoke2 Peering
module "hub_spoke2_peering" {
  source = "../../modules/vnet-peering"

  resource_group_name = module.resource_group.resource_group_name
  prefix              = var.prefix
  spoke_name          = "spoke2"
  hub_vnet_name       = module.hub_network.hub_vnet_name
  spoke_vnet_name     = module.spoke2_network.spoke_vnet_name

  depends_on = [module.hub_network, module.spoke2_network]
}

# Direct Spoke1 to Spoke2 Peering (enables VM-to-VM communication)
resource "azurerm_virtual_network_peering" "spoke1_to_spoke2" {
  name                      = "${var.prefix}-spoke1-to-spoke2"
  resource_group_name       = module.resource_group.resource_group_name
  virtual_network_name      = module.spoke1_network.spoke_vnet_name
  remote_virtual_network_id = module.spoke2_network.spoke_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [module.spoke1_network, module.spoke2_network]
}

# Direct Spoke2 to Spoke1 Peering (bidirectional)
resource "azurerm_virtual_network_peering" "spoke2_to_spoke1" {
  name                      = "${var.prefix}-spoke2-to-spoke1"
  resource_group_name       = module.resource_group.resource_group_name
  virtual_network_name      = module.spoke2_network.spoke_vnet_name
  remote_virtual_network_id = module.spoke1_network.spoke_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [module.spoke1_network, module.spoke2_network]
}