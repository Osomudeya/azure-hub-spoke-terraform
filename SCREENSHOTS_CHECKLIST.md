# Screenshots Checklist for Documentation

## Required Screenshots

### 1. Terraform Deployment
- [ ] `terraform init` output
- [ ] `terraform plan` output showing resources to create
- [ ] `terraform apply` success message
- [ ] `terraform output` showing VM IPs and connection details

### 2. Azure Portal
- [ ] Resource group showing all resources (15+ items)
- [ ] Hub VNet overview
- [ ] Spoke 1 VNet overview
- [ ] Spoke 2 VNet overview
- [ ] VNet peering status showing "Connected"
- [ ] Network Security Group inbound rules
- [ ] VM1 overview page showing running status
- [ ] VM2 overview page showing running status

### 3. Connectivity Testing
- [ ] SSH connection to VM1
- [ ] Successful ping from VM1 to VM2 (private IP)
- [ ] Terminal showing 4 successful ping responses

### 4. GitHub Actions
- [ ] GitHub repository structure
- [ ] Self-hosted runner showing as "Idle" or "Active"
- [ ] Successful workflow run
- [ ] Workflow execution logs

### 5. Network Topology
- [ ] Network Watcher topology view (optional)
- [ ] Hand-drawn or digital architecture diagram

## How to Take Screenshots

### macOS
- Full screen: `Cmd + Shift + 3`
- Selection: `Cmd + Shift + 4`
- Window: `Cmd + Shift + 4`, then `Space`

### Windows
- Full screen: `Windows + Print Screen`
- Selection: `Windows + Shift + S`

### Linux
- Use `gnome-screenshot` or `scrot`

## Screenshot Tips

1. Clean your desktop before taking screenshots
2. Increase terminal font size for readability
3. Use full screen or maximize windows
4. Crop out unnecessary content
5. Highlight important parts with arrows/boxes
6. Use consistent naming: `01-terraform-init.png`, `02-terraform-apply.png`, etc.

## Where to Store

Create a `screenshots/` folder in your repository and organize by category:

```
screenshots/
├── terraform/
│   ├── 01-init.png
│   ├── 02-plan.png
│   └── 03-apply.png
├── azure-portal/
│   ├── 01-resource-group.png
│   ├── 02-vnet-peering.png
│   └── 03-nsg-rules.png
├── connectivity/
│   ├── 01-ssh-vm1.png
│   └── 02-ping-vm2.png
└── github/
    ├── 01-runner-status.png
    └── 02-workflow-success.png
```

