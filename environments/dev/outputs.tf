# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.resource_group_name
}

# Hub Network Outputs
output "hub_network" {
  description = "Hub network details"
  value = {
    vnet_id       = module.hub_network.hub_vnet_id
    vnet_name     = module.hub_network.hub_vnet_name
    address_space = module.hub_network.hub_address_space
  }
}

# Spoke 1 Outputs
output "spoke1_details" {
  description = "Spoke 1 network and VM details"
  value = {
    vnet_id       = module.spoke1_network.spoke_vnet_id
    vnet_name     = module.spoke1_network.spoke_vnet_name
    address_space = module.spoke1_network.spoke_address_space
    vm_name       = module.spoke1_network.vm_name
    public_ip     = module.spoke1_network.vm_public_ip
    private_ip    = module.spoke1_network.vm_private_ip
    ssh_command   = module.spoke1_network.ssh_command
  }
}

# Spoke 2 Outputs
output "spoke2_details" {
  description = "Spoke 2 network and VM details"
  value = {
    vnet_id       = module.spoke2_network.spoke_vnet_id
    vnet_name     = module.spoke2_network.spoke_vnet_name
    address_space = module.spoke2_network.spoke_address_space
    vm_name       = module.spoke2_network.vm_name
    public_ip     = module.spoke2_network.vm_public_ip
    private_ip    = module.spoke2_network.vm_private_ip
    ssh_command   = module.spoke2_network.ssh_command
  }
}

# VNet Peering Information
output "peering_info" {
  description = "VNet peering connection information"
  value = {
    hub_to_spoke1_name = module.hub_spoke1_peering.hub_to_spoke_peering_name
    spoke1_to_hub_name = module.hub_spoke1_peering.spoke_to_hub_peering_name
    hub_to_spoke2_name = module.hub_spoke2_peering.hub_to_spoke_peering_name
    spoke2_to_hub_name = module.hub_spoke2_peering.spoke_to_hub_peering_name
    note               = "Check peering status in Azure Portal. Peering should show as 'Connected' after deployment."
  }
}

# Quick Access Commands
output "connectivity_test" {
  description = "Commands to test connectivity between VMs"
  value = {
    vm1_ssh      = module.spoke1_network.ssh_command
    vm2_ssh      = module.spoke2_network.ssh_command
    ping_command = "ping ${module.spoke2_network.vm_private_ip}"
  }
}