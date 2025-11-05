terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Data sources to get VNet details
data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_network" "spoke" {
  name                = var.spoke_vnet_name
  resource_group_name = var.resource_group_name
}

# Hub to Spoke Peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "${var.prefix}-hub-to-${var.spoke_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = data.azurerm_virtual_network.spoke.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways         = false
}

# Spoke to Hub Peering
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${var.prefix}-${var.spoke_name}-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.spoke.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways         = var.use_remote_gateways
}
