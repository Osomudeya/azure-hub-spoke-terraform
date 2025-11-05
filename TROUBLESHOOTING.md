# Troubleshooting Guide

## Terraform Issues

### Error: "Error acquiring the state lock"
```bash
# Force unlock (use carefully)
terraform force-unlock LOCK_ID
```

### Error: "Provider configuration not present"
```bash
cd environments/dev
terraform init
```

### Error: "Resource already exists"
```bash
# Option 1: Import
terraform import azurerm_resource_group.main /subscriptions/{sub-id}/resourceGroups/{rg-name}

# Option 2: Delete and recreate
# Go to Azure Portal → Delete resource → terraform apply
```

## Azure Connectivity Issues

### Cannot SSH to VMs

**Check VM status:**
```bash
az vm get-instance-view \
  --resource-group rg-name \
  --name vm-name \
  --query "instanceView.statuses[1].displayStatus"
```

**Verify NSG rules:**
- Azure Portal → VM → Networking
- Check "Inbound port rules"
- Ensure SSH (22) allowed from your IP

**Update your IP if changed:**
```bash
curl https://api.ipify.org
# Update admin_source_ip in terraform.tfvars
terraform apply
```

### VM1 Cannot Ping VM2

**Check VNet Peering:**
```bash
# Should show "Connected"
az network vnet peering list \
  --resource-group rg-name \
  --vnet-name hub-vnet \
  --output table
```

**Verify NSG allows spoke-to-spoke traffic:**
- Azure Portal → Network Security Groups
- Check rules allow traffic between spoke CIDRs

**Check effective routes:**
- Azure Portal → VM → Network Interface → Effective routes

## GitHub Actions Issues

### Runner Not Showing

```bash
# Restart runner
cd actions-runner
./run.sh  # Linux/Mac
./run.cmd  # Windows
```

### Workflow Fails with Azure Error

**Test service principal:**
```bash
az login --service-principal \
  -u CLIENT_ID \
  -p CLIENT_SECRET \
  --tenant TENANT_ID
```

**Recreate secret if needed:**
```bash
az ad sp create-for-rbac --name "github-actions-terraform" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

## Cost Issues

### Unexpected Charges

**Check running resources:**
```bash
az resource list \
  --resource-group rg-hubspoke-yourname \
  --output table
```

**Stop VMs:**
```bash
az vm stop --resource-group rg-name --name vm1
az vm stop --resource-group rg-name --name vm2
```

**Or destroy everything:**
```bash
terraform destroy
```

## Quick Fixes

### Reset Everything:
```bash
cd environments/dev
terraform destroy -auto-approve
rm -rf .terraform terraform.tfstate*
terraform init
terraform apply -auto-approve
```

### Check What's Deployed:
```bash
az resource list --resource-group rg-name --output table
```

### Force Resource Recreation:
```bash
terraform taint azurerm_linux_virtual_machine.vm1
terraform apply
```

