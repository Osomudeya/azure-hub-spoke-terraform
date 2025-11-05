output "spoke_vnet_id" {
  description = "ID of the Spoke VNet"
  value       = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  description = "Name of the Spoke VNet"
  value       = azurerm_virtual_network.spoke.name
}

output "spoke_subnet_id" {
  description = "ID of the Spoke subnet"
  value       = azurerm_subnet.spoke_subnet.id
}

output "spoke_address_space" {
  description = "Address space of the Spoke VNet"
  value       = azurerm_virtual_network.spoke.address_space[0]
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "vm_name" {
  description = "Name of the VM"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i ~/.ssh/azure_hubspoke_key ${var.admin_username}@${azurerm_public_ip.vm_pip.ip_address}"
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.spoke_nsg.id
}
