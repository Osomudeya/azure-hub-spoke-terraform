terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Hub VNet - Central connectivity point
resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-hub-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.hub_address_space]
  tags                = var.tags
}

# Hub Subnet
resource "azurerm_subnet" "hub_subnet" {
  name                 = "${var.prefix}-hub-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnet_prefix]
}
