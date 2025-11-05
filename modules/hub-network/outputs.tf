output "hub_vnet_id" {
  description = "ID of the Hub VNet"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the Hub VNet"
  value       = azurerm_virtual_network.hub.name
}

output "hub_subnet_id" {
  description = "ID of the Hub subnet"
  value       = azurerm_subnet.hub_subnet.id
}

output "hub_address_space" {
  description = "Address space of the Hub VNet"
  value       = azurerm_virtual_network.hub.address_space[0]
}

output "resource_group_name" {
  description = "Resource group name"
  value       = var.resource_group_name
}
