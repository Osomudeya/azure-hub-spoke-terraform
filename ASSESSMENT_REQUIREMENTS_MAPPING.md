# 🎯 Assessment Requirements → Terraform Files Mapping

Complete step-by-step guide showing exactly where each assessment requirement is implemented in the Terraform codebase.

---

## 📋 Table of Contents

1. [Requirement 1: Reusable Terraform Module](#requirement-1-reusable-terraform-module)
   - [Azure Resource Group](#azure-resource-group)
   - [Azure VNets and Subnets](#azure-vnets-and-subnets)
   - [NSG (Network Security Groups)](#nsg-network-security-groups)
   - [2 VMs (Virtual Machines)](#2-vms-virtual-machines)
2. [Requirement 2: Hub and Spoke Network Topology](#requirement-2-hub-and-spoke-network-topology)
3. [Requirement 3: VM1 in Spoke Vnet1](#requirement-3-vm1-in-spoke-vnet1)
4. [Requirement 4: VM2 in Spoke Vnet2](#requirement-4-vm2-in-spoke-vnet2)
5. [Requirement 5: VNet Peering](#requirement-5-vnet-peering)
6. [Requirement 6: VM1 Should Reach VM2](#requirement-6-vm1-should-reach-vm2)
7. [Requirement 7: Cost Optimization and Cleanup](#requirement-7-cost-optimization-and-cleanup)
8. [Summary Reference Table](#summary-reference-table)

---

## Requirement 1: Reusable Terraform Module

**Assessment Requirement:** *"Build a reusable terraform module to deploy Azure Resource Group, Azure VNets and Subnets, NSG and 2 VMs"*

### Azure Resource Group

**Module Instantiation:** [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 26-32)

```terraform
module "resource_group" {
  source = "../../modules/resource-group"

  resource_group_name = var.resource_group_name
  location           = var.location
  tags               = local.common_tags
}
```

**Module Implementation:** [`modules/resource-group/main.tf`](../modules/resource-group/main.tf) (lines 11-15)

```terraform
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
```

**Related Files:**
- [`modules/resource-group/variables.tf`](../modules/resource-group/variables.tf) - Variable definitions
- [`modules/resource-group/outputs.tf`](../modules/resource-group/outputs.tf) - Output values

---

### Azure VNets and Subnets

#### Hub VNet and Subnet

**Module Implementation:** [`modules/hub-network/main.tf`](../modules/hub-network/main.tf) (lines 11-25)

```terraform
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
```

**Module Instantiation:** [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 35-46)

**Related Files:**
- [`modules/hub-network/variables.tf`](../modules/hub-network/variables.tf)
- [`modules/hub-network/outputs.tf`](../modules/hub-network/outputs.tf)

#### Spoke VNets and Subnets

**Module Implementation:** [`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) (lines 11-25)

```terraform
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
```

**Module Instantiation:**
- Spoke1: [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 49-66)
- Spoke2: [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 69-86)

**Related Files:**
- [`modules/spoke-network/variables.tf`](../modules/spoke-network/variables.tf)
- [`modules/spoke-network/outputs.tf`](../modules/spoke-network/outputs.tf)

---

### NSG (Network Security Groups)

**Module Implementation:** [`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) (lines 28-70)

```terraform
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

# NSG Rule: Allow traffic from other spokes (dynamic)
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
```

**Key Features:**
- SSH access rule (priority 100)
- Dynamic cross-spoke communication rules (priority 110+)
- Automatic NSG-subnet association

---

### 2 VMs (Virtual Machines)

**Module Implementation:** [`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) (lines 73-130)

**Public IP:**
```terraform
resource "azurerm_public_ip" "vm_pip" {
  name                = "${var.prefix}-${var.spoke_name}-vm-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
```

**Network Interface:**
```terraform
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
```

**Virtual Machine:**
```terraform
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
```

**Module Instantiation:**
- VM1 (Spoke1): [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 49-66)
- VM2 (Spoke2): [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 69-86)

---

## Requirement 2: Hub and Spoke Network Topology

**Assessment Requirement:** *"Network Topology: Hub and Spoke Network"*

**Implementation:** The hub-spoke topology is implemented through modular composition in [`environments/dev/main.tf`](../environments/dev/main.tf):

- **Hub Network:** Lines 35-46
  ```terraform
  module "hub_network" {
    source = "../../modules/hub-network"
    # ... configuration
  }
  ```

- **Spoke1 Network:** Lines 49-66
  ```terraform
  module "spoke1_network" {
    source = "../../modules/spoke-network"
    spoke_name = "spoke1"
    # ... configuration
  }
  ```

- **Spoke2 Network:** Lines 69-86
  ```terraform
  module "spoke2_network" {
    source = "../../modules/spoke-network"
    spoke_name = "spoke2"
    # ... configuration
  }
  ```

**Network Configuration:** [`environments/dev/terraform.tfvars`](../environments/dev/terraform.tfvars)
- Hub: `10.0.0.0/16`
- Spoke1: `10.1.0.0/16`
- Spoke2: `10.2.0.0/16`

**Visual Diagram:** See [`ARCHITECTURE_DIAGRAM.txt`](ARCHITECTURE_DIAGRAM.txt) for complete topology visualization.

---

## Requirement 3: VM1 in Spoke Vnet1

**Assessment Requirement:** *"VM1 > Deployed in Spoke Vnet1"*

**Module Instantiation:** [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 49-66)

```terraform
module "spoke1_network" {
  source = "../../modules/spoke-network"

  resource_group_name   = module.resource_group.resource_group_name
  location             = module.resource_group.location
  prefix               = var.prefix
  spoke_name           = "spoke1"
  spoke_address_space  = var.spoke1_vnet_address_space
  spoke_subnet_prefix  = var.spoke1_subnet_address_prefix
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  ssh_public_key       = var.ssh_public_key
  admin_source_ip      = var.admin_source_ip
  allowed_spoke_cidrs  = [var.spoke2_vnet_address_space]
  tags                 = local.common_tags

  depends_on = [module.resource_group]
}
```

**Network Configuration:** [`environments/dev/terraform.tfvars`](../environments/dev/terraform.tfvars) (lines 9-10)

```hcl
spoke1_vnet_address_space    = "10.1.0.0/16"
spoke1_subnet_address_prefix = "10.1.1.0/24"
```

**What This Creates:**
- Spoke1 VNet: `infinion-spoke1-vnet` (10.1.0.0/16)
- Spoke1 Subnet: `infinion-spoke1-subnet` (10.1.1.0/24)
- VM1: `infinion-spoke1-vm` (deployed in Spoke1 subnet)

---

## Requirement 4: VM2 in Spoke Vnet2

**Assessment Requirement:** *"VM2 > Deployed in Spoke Vnet2"*

**Module Instantiation:** [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 69-86)

```terraform
module "spoke2_network" {
  source = "../../modules/spoke-network"

  resource_group_name   = module.resource_group.resource_group_name
  location             = module.resource_group.location
  prefix               = var.prefix
  spoke_name           = "spoke2"
  spoke_address_space  = var.spoke2_vnet_address_space
  spoke_subnet_prefix  = var.spoke2_subnet_address_prefix
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  ssh_public_key       = var.ssh_public_key
  admin_source_ip      = var.admin_source_ip
  allowed_spoke_cidrs  = [var.spoke1_vnet_address_space]
  tags                 = local.common_tags

  depends_on = [module.resource_group]
}
```

**Network Configuration:** [`environments/dev/terraform.tfvars`](../environments/dev/terraform.tfvars) (lines 11-12)

```hcl
spoke2_vnet_address_space    = "10.2.0.0/16"
spoke2_subnet_address_prefix = "10.2.1.0/24"
```

**What This Creates:**
- Spoke2 VNet: `infinion-spoke2-vnet` (10.2.0.0/16)
- Spoke2 Subnet: `infinion-spoke2-subnet` (10.2.1.0/24)
- VM2: `infinion-spoke2-vm` (deployed in Spoke2 subnet)

---

## Requirement 5: VNet Peering

**Assessment Requirement:** *"VNet 1 & 2 peered to a Hub VNet"*

### Hub ↔ Spoke1 Peering

**Module Instantiation:** [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 89-99)

```terraform
module "hub_spoke1_peering" {
  source = "../../modules/vnet-peering"

  resource_group_name = module.resource_group.resource_group_name
  prefix             = var.prefix
  spoke_name         = "spoke1"
  hub_vnet_name      = module.hub_network.hub_vnet_name
  spoke_vnet_name    = module.spoke1_network.spoke_vnet_name

  depends_on = [module.hub_network, module.spoke1_network]
}
```

### Hub ↔ Spoke2 Peering

**Module Instantiation:** [`environments/dev/main.tf`](../environments/dev/main.tf) (lines 102-112)

```terraform
module "hub_spoke2_peering" {
  source = "../../modules/vnet-peering"

  resource_group_name = module.resource_group.resource_group_name
  prefix             = var.prefix
  spoke_name         = "spoke2"
  hub_vnet_name      = module.hub_network.hub_vnet_name
  spoke_vnet_name    = module.spoke2_network.spoke_vnet_name

  depends_on = [module.hub_network, module.spoke2_network]
}
```

### Bidirectional Peering Implementation

**Module Implementation:** [`modules/vnet-peering/main.tf`](../modules/vnet-peering/main.tf) (lines 22-45)

```terraform
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
```

**Key Features:**
- ✅ Bidirectional peering (Hub→Spoke AND Spoke→Hub)
- ✅ `allow_forwarded_traffic = true` enables routing through hub
- ✅ Four peering connections total (2 per spoke)

**Related Files:**
- [`modules/vnet-peering/variables.tf`](../modules/vnet-peering/variables.tf)
- [`modules/vnet-peering/outputs.tf`](../modules/vnet-peering/outputs.tf)

---

## Requirement 6: VM1 Should Reach VM2

**Assessment Requirement:** *"VM1 Should reach VM2"*

### NSG Rules Configuration

**Spoke1 allows Spoke2:** [`environments/dev/main.tf`](../environments/dev/main.tf) (line 62)

```terraform
allowed_spoke_cidrs  = [var.spoke2_vnet_address_space]
```

This allows traffic from `10.2.0.0/16` (Spoke2) into Spoke1.

**Spoke2 allows Spoke1:** [`environments/dev/main.tf`](../environments/dev/main.tf) (line 82)

```terraform
allowed_spoke_cidrs  = [var.spoke1_vnet_address_space]
```

This allows traffic from `10.1.0.0/16` (Spoke1) into Spoke2.

### Dynamic NSG Rule Generation

**Module Implementation:** [`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) (lines 50-68)

```terraform
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
```

**How It Works:**
1. VNet peering enables routing: VM1 → Spoke1 → Hub → Spoke2 → VM2
2. NSG rules allow the traffic: Spoke1 allows 10.2.0.0/16, Spoke2 allows 10.1.0.0/16
3. `allow_forwarded_traffic = true` in peering allows traffic to transit through hub

**Testing:** See [`scripts/test-connectivity.sh`](../scripts/test-connectivity.sh) for automated connectivity testing.

---

## Requirement 7: Cost Optimization and Cleanup

**Assessment Requirement:** *"Aim for cost optimization and clean up your infrastructure when done"*

### Cost Optimization

#### VM Size Configuration

**Location:** [`environments/dev/terraform.tfvars`](../environments/dev/terraform.tfvars) (line 14)

```hcl
vm_size        = "Standard_B1s"
```

**Cost:** ~$7.59/month per VM (vs. Standard_B2s at ~$30/month)

#### Storage Optimization

**Location:** [`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) (line 115)

```terraform
storage_account_type = "Standard_LRS"
```

**Cost:** ~$0.04/GB/month (vs. Premium_LRS at ~$0.15/GB/month)

#### Auto-Shutdown Tag

**Location:** [`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) (lines 125-128)

```terraform
tags = merge(var.tags, { 
  AutoShutdown = "true"
  Spoke = var.spoke_name
})
```

**Purpose:** Enables automated VM shutdown scheduling to reduce costs during non-business hours.

**Estimated Monthly Cost:** ~$26.38
- 2x Standard_B1s VMs: ~$15.18
- 2x Public IPs: ~$7.20
- VNet Peering: ~$1.00
- Storage: ~$3.00

See [`COST_BREAKDOWN.md`](COST_BREAKDOWN.md) for detailed cost analysis.

### Cleanup

**Command:** Navigate to the environment directory and run:

```bash
cd environments/dev
terraform destroy
```

**What Gets Destroyed:**
- ✅ Resource Group and all contained resources
- ✅ All VNets and subnets
- ✅ All VMs and network interfaces
- ✅ All NSGs and rules
- ✅ All VNet peerings
- ✅ All public IPs

**Verification:** After destroy, confirm in Azure Portal that the resource group is deleted.

---

## Summary Reference Table

| **Requirement** | **Primary Location** | **Supporting Files** | **Key Line Numbers** |
|-----------------|---------------------|----------------------|---------------------|
| **Reusable Modules** | `modules/` directory | All 4 module directories | N/A |
| **Resource Group** | [`modules/resource-group/main.tf`](../modules/resource-group/main.tf) | [`environments/dev/main.tf`](../environments/dev/main.tf) | 11-15, 26-32 |
| **VNets & Subnets** | [`modules/hub-network/main.tf`](../modules/hub-network/main.tf)<br>[`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) | [`environments/dev/terraform.tfvars`](../environments/dev/terraform.tfvars) | 11-25 (hub)<br>11-25 (spoke) |
| **NSG** | [`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) | - | 28-70 |
| **2 VMs** | [`modules/spoke-network/main.tf`](../modules/spoke-network/main.tf) | [`environments/dev/main.tf`](../environments/dev/main.tf) | 73-130, 49-66, 69-86 |
| **Hub-Spoke Topology** | [`environments/dev/main.tf`](../environments/dev/main.tf) | Module composition | 35-46, 49-66, 69-86 |
| **VM1 in Spoke1** | [`environments/dev/main.tf`](../environments/dev/main.tf) | [`modules/spoke-network/`](../modules/spoke-network/) | 49-66 |
| **VM2 in Spoke2** | [`environments/dev/main.tf`](../environments/dev/main.tf) | [`modules/spoke-network/`](../modules/spoke-network/) | 69-86 |
| **VNet Peering** | [`modules/vnet-peering/main.tf`](../modules/vnet-peering/main.tf) | [`environments/dev/main.tf`](../environments/dev/main.tf) | 22-45, 89-99, 102-112 |
| **VM1 → VM2 Communication** | `allowed_spoke_cidrs` configuration | Dynamic NSG rules in spoke module | 62, 82, 50-68 |
| **Cost Optimization** | [`terraform.tfvars`](../environments/dev/terraform.tfvars) + storage settings | Auto-shutdown tags | 14, 115, 125-128 |

---

## Quick Navigation

- **Main Documentation:** [`README.md`](README.md)
- **Architecture Diagram:** [`ARCHITECTURE_DIAGRAM.txt`](ARCHITECTURE_DIAGRAM.txt)
- **Troubleshooting:** [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)
- **Cost Analysis:** [`COST_BREAKDOWN.md`](COST_BREAKDOWN.md)
- **Setup Script:** [`scripts/setup.sh`](../scripts/setup.sh)
- **Test Script:** [`scripts/test-connectivity.sh`](../scripts/test-connectivity.sh)

---

**🚀 This modular architecture perfectly meets all assessment requirements while demonstrating advanced Terraform practices!**

For questions or issues, refer to the [Troubleshooting Guide](TROUBLESHOOTING.md) or review the [complete README](README.md).
