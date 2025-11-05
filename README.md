# Azure Hub-Spoke Network Topology with Modular Terraform

Modular Terraform solution for deploying Azure Hub-Spoke network architecture.

## Architecture

```
         ┌─────────────────┐
         │   Hub VNet      │
         │  10.0.0.0/16    │
         └────────┬────────┘
                  │
         ┌────────┴────────┐
         │                 │
    ┌────▼────┐      ┌────▼────┐
    │ Spoke 1 │      │ Spoke 2 │
    │10.1.0.0 │      │10.2.0.0 │
    │   VM1   │◄────►│   VM2   │
    └─────────┘      └─────────┘
```

## Features

- ✅ **Modular Architecture** - Separate modules for maximum reusability
- ✅ **Hub-Spoke Network Topology** - Enterprise-grade design pattern
- ✅ **Bidirectional VNet Peering** - Full mesh connectivity through hub
- ✅ **Dynamic NSG Rules** - Configurable cross-spoke communication
- ✅ **Scalable Design** - Easy to add new spokes
- ✅ **2 Linux VMs** (Ubuntu 22.04) with SSH key authentication
- ✅ **Cost-Optimized** (Standard_B1s VMs)
- ✅ **GitHub Actions CI/CD** with self-hosted runner support
- ✅ **Production-Ready** with comprehensive documentation

## Module Structure

```
modules/
├── resource-group/        # Shared resource group
├── hub-network/          # Hub VNet and subnet
├── spoke-network/        # Reusable spoke (VNet, subnet, VM, NSG)
└── vnet-peering/         # Bidirectional VNet peering
```

## Prerequisites

- Azure subscription with Contributor access
- Azure CLI installed and authenticated
- Terraform >= 1.0
- SSH key pair generated
- Git for version control

## Quick Start

### 1. Generate SSH Key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_hubspoke_key
```

### 2. Get Your Public IP
```bash
curl https://api.ipify.org
```

### 3. Configure Variables
Edit `environments/dev/terraform.tfvars`:
```hcl
resource_group_name = "rg-hubspoke-yourname"
prefix              = "yourname" 
ssh_public_key      = "YOUR_SSH_PUBLIC_KEY"
admin_source_ip     = "YOUR_IP/32"
```

### 4. Deploy Infrastructure
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 5. Test Connectivity
```bash
# SSH to VM1 (Spoke1)
terraform output -json spoke1_details | jq -r '.ssh_command'

# From VM1, ping VM2 private IP
ping $(terraform output -json spoke2_details | jq -r '.private_ip')
```

### 6. Cleanup
```bash
terraform destroy
```

## Modular Benefits

### **🎯 Separation of Concerns**
- **Hub Network:** Centralized connectivity and shared services
- **Spoke Networks:** Independent workload environments  
- **VNet Peering:** Standardized connectivity patterns
- **Resource Groups:** Shared foundational resources

### **📈 Scalability**
```hcl
# Add new spoke easily
module "spoke3_network" {
  source = "../../modules/spoke-network"
  
  spoke_name          = "spoke3"
  spoke_address_space = "10.3.0.0/16"
  # ... other variables
}

# Add peering
module "hub_spoke3_peering" {
  source = "../../modules/vnet-peering"
  
  spoke_name      = "spoke3"
  hub_vnet_name   = module.hub_network.hub_vnet_name
  spoke_vnet_name = module.spoke3_network.spoke_vnet_name
}
```

### **🔄 Reusability**
- **Hub Module:** Reuse across environments (dev/staging/prod)
- **Spoke Module:** Deploy different workload types
- **Peering Module:** Standardize all hub-spoke connections

### **👥 Team Ownership**
- **Platform Team:** Manages hub and shared services
- **Application Teams:** Own individual spokes
- **Network Team:** Manages peering policies

## Network Configuration

| Component | Address Space | Purpose |
|-----------|--------------|---------|
| Hub VNet | 10.0.0.0/16 | Central connectivity hub |
| Hub Subnet | 10.0.1.0/24 | Hub subnet |
| Spoke 1 VNet | 10.1.0.0/16 | VM1 workload |
| Spoke 1 Subnet | 10.1.1.0/24 | VM1 subnet |
| Spoke 2 VNet | 10.2.0.0/16 | VM2 workload |
| Spoke 2 Subnet | 10.2.1.0/24 | VM2 subnet |

## Cost Estimate

| Resource | Estimated Cost |
|----------|---------------|
| 2x Standard_B1s VMs | ~$15.18/month |
| 2x Public IPs | ~$7.20/month |
| VNet Peering | ~$1.00/month |
| Storage (Standard HDD) | ~$3.00/month |
| **Total** | **~$26.38/month** |

## Advanced Usage

### Multiple Environments
```bash
# Deploy to different environments
environments/
├── dev/
├── staging/
└── prod/
```

### Custom Spoke Types
```hcl
# Web Spoke
module "web_spoke" {
  source = "../../modules/spoke-network"
  
  spoke_name         = "web"
  vm_size           = "Standard_B2s"  # Larger for web traffic
  allowed_spoke_cidrs = ["10.2.0.0/16", "10.3.0.0/16"]  # API + DB access
}

# Database Spoke  
module "db_spoke" {
  source = "../../modules/spoke-network"
  
  spoke_name         = "db"
  vm_size           = "Standard_D2s_v3"  # Optimized for database
  allowed_spoke_cidrs = ["10.1.0.0/16"]  # Only web access
}
```


## Module Documentation

### Hub Network Module
- **Purpose:** Central connectivity point for all spokes
- **Resources:** Hub VNet and subnet
- **Outputs:** VNet ID, name, address space

### Spoke Network Module  
- **Purpose:** Reusable workload environment
- **Resources:** VNet, subnet, VM, NSG, public IP
- **Parameters:** Spoke name, address space, allowed CIDRs
- **Outputs:** VNet details, VM connection info

### VNet Peering Module
- **Purpose:** Bidirectional hub-spoke connectivity
- **Resources:** Two peering connections (hub↔spoke)
- **Features:** Gateway transit support, forwarded traffic

### Resource Group Module
- **Purpose:** Shared foundational resources
- **Resources:** Resource group with consistent tagging
- **Outputs:** Resource group name and location

## Security Features

- **Network Isolation:** Spokes isolated by default
- **Controlled Communication:** Explicit NSG rules for cross-spoke traffic
- **SSH Key Authentication:** No password authentication
- **Source IP Restrictions:** SSH limited to admin IP

## Assessment Requirements Mapping

See [ASSESSMENT_REQUIREMENTS_MAPPING.md](ASSESSMENT_REQUIREMENTS_MAPPING.md) for a complete step-by-step guide showing exactly where each assessment requirement is implemented in the Terraform codebase.

This document provides:
- Exact file locations and line numbers for each requirement
- Code snippets for all key implementations
- Links to all related files
- Summary reference table for quick navigation

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.

**Common Issues:**
- **VM connectivity:** Check VNet peering status and NSG rules
- **SSH access:** Verify admin_source_ip matches your current IP
- **Module dependencies:** Ensure proper depends_on relationships

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-spoke-type`)
3. Test changes thoroughly
4. Submit pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Architecture Decisions

### Why Modular Design?
- **Enterprise Scalability:** Easy to add 10+ spokes
- **Team Autonomy:** Different teams can manage their spokes
- **Reusability:** Modules work across environments
- **Maintainability:** Changes isolated to specific modules

### Why Hub-Spoke vs Alternatives?
- **vs Full Mesh:** Exponential complexity with many networks
- **vs Flat Network:** No isolation, security concerns
- **vs Azure Virtual WAN:** Too complex/expensive for this scale

This modular approach demonstrates enterprise-grade infrastructure as code practices while maintaining simplicity for demonstration purposes.