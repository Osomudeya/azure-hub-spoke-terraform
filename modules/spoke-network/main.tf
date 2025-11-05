terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Spoke VNet
resource "azurerm_virtual_network" "spoke" {
  name                = "${var.prefix}-${var.spoke_name}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.spoke_address_space]
  tags                = var.tags
}

# Spoke Subnet
resource "azurerm_subnet" "spoke_subnet" {
  name                 = "${var.prefix}-${var.spoke_name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.spoke_subnet_prefix]
}

# Network Security Group for Spoke
resource "azurerm_network_security_group" "spoke_nsg" {
  name                = "${var.prefix}-${var.spoke_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# NSG Rule: Allow SSH from admin IP
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.admin_source_ip
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.spoke_nsg.name
}

# NSG Rule: Allow traffic from other spokes
resource "azurerm_network_security_rule" "allow_other_spokes" {
  for_each = toset(var.allowed_spoke_cidrs)
  
  name                        = "Allow${replace(replace(each.value, ".", ""), "/", "")}"
  priority                    = 110 + index(var.allowed_spoke_cidrs, each.value)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.spoke_nsg.name
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "spoke" {
  subnet_id                 = azurerm_subnet.spoke_subnet.id
  network_security_group_id = azurerm_network_security_group.spoke_nsg.id
}

# Public IP for VM
resource "azurerm_public_ip" "vm_pip" {
  name                = "${var.prefix}-${var.spoke_name}-vm-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Network Interface for VM
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.prefix}-${var.spoke_name}-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
  tags = var.tags
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-${var.spoke_name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = merge(var.tags, { 
    AutoShutdown = "true"
    Spoke = var.spoke_name
  })
}
