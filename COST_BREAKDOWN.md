# COST_BREAKDOWN.md

## Detailed Cost Analysis

### Virtual Machines (2x Standard_B1s)

**Specifications:**
- vCPUs: 1
- RAM: 1 GB
- Temporary storage: 4 GB
- Max data disks: 2

**Cost per VM:**
- Pay-as-you-go: ~$7.59/month
- With Reserved Instance (1 year): ~$4.50/month
- With Reserved Instance (3 year): ~$2.80/month

**Total for 2 VMs:**
- Pay-as-you-go: ~$15.18/month
- 1-year RI: ~$9.00/month
- 3-year RI: ~$5.60/month

### Storage

**OS Disks (2x 30 GB Standard HDD):**
- $0.04 per GB/month
- 30 GB × 2 = 60 GB
- Cost: ~$2.40/month

**Transactions:**
- Standard HDD: $0.002 per 10,000 transactions
- Estimated: ~$0.50/month

**Total Storage: ~$2.90/month**

### Networking

**Public IP Addresses (2x Standard):**
- Standard Public IP: ~$3.60/month each
- Total: ~$7.20/month

**VNet Peering:**
- Ingress: $0.01 per GB
- Egress: $0.01 per GB
- Estimated for demo: ~$1.00/month

**Bandwidth:**
- First 100 GB outbound: Free
- Additional: $0.087 per GB
- Estimated: Included in free tier for demo

**Total Networking: ~$8.20/month**

### Resource Group & Other Resources

**No additional costs for:**
- Resource Group
- Virtual Networks
- Subnets
- Network Security Groups
- Network Interfaces

## Total Monthly Cost Estimate

| Scenario | Monthly Cost |
|----------|--------------|
| **Pay-as-you-go (Demo)** | **~$26.38** |
| With 1-year Reserved Instances | ~$21.10 |
| With 3-year Reserved Instances | ~$16.70 |

## Cost Optimization Strategies

### 1. VM Size Optimization
Current: Standard_B1s (~$7.59/month)
- For production with higher load: Standard_B2s (~$30/month)
- For dev/test: Keep B1s
- For production critical: Standard_D2s_v3 (~$70/month)

### 2. Reserved Instances
- 1-year commitment: Save ~40%
- 3-year commitment: Save ~63%
- Good for production, not for demo

### 3. Auto-Shutdown
Configure auto-shutdown schedules:
- Shut down at 19:00 daily
- Save ~50% if running 12 hours/day
- Monthly savings: ~$7-8

### 4. Spot Instances
- For non-critical workloads
- Save up to 90%
- Not recommended for production

### 5. Storage Optimization
- Use Standard HDD (current choice) ✅
- Archive old snapshots
- Delete unused disks

### 6. Remove Public IPs
For production:
- Use Azure Bastion instead (~$140/month but shared)
- Remove individual public IPs (-$7.20/month)
- Net: More expensive but more secure

## Cost Monitoring

### Set Up Budget Alerts

```bash
# Create budget
az consumption budget create \
  --budget-name "hub-spoke-demo" \
  --amount 50 \
  --time-grain Monthly \
  --start-date 2025-11-01 \
  --end-date 2025-12-31 \
  --resource-group rg-hubspoke-demo
```

### Daily Cost Check

```bash
# Check current costs
az consumption usage list \
  --start-date 2025-11-01 \
  --end-date 2025-11-30 \
  --query "[].{Date:usageStart, Cost:pretaxCost}" \
  --output table
```

### Resource Cost by Tag

```bash
# View costs by resource
az resource list \
  --resource-group rg-hubspoke-demo \
  --query "[].{Name:name, Type:type}" \
  --output table
```

## Cost Comparison: Hub-Spoke vs Alternatives

### Option 1: Hub-Spoke (Current)
- Monthly: ~$26.38
- Benefits: Centralized, scalable, enterprise-ready
- Best for: Production, multiple environments

### Option 2: Flat Network (Single VNet)
- Monthly: ~$18.00
- Benefits: Simpler, cheaper
- Best for: Small demos, single environment
- Drawbacks: No isolation, doesn't scale

### Option 3: Full Mesh Peering
- Monthly: ~$35+ (grows exponentially)
- Benefits: Direct spoke-to-spoke connectivity
- Best for: Never (too complex)
- Drawbacks: Unmanageable, expensive

### Option 4: Azure Virtual WAN
- Monthly: ~$500+
- Benefits: Global transit, built-in redundancy
- Best for: Enterprise with many locations
- Drawbacks: Overkill for demo

## Production Cost Estimate

For a production hub-spoke with:
- Hub: Azure Firewall, VPN Gateway, Bastion
- 3 Spokes with Standard_D2s_v3 VMs
- Load Balancers
- 1-year Reserved Instances

**Estimated: $800-1,200/month**

## Demo Cleanup

**IMPORTANT: Destroy resources when done!**

```bash
cd environments/dev
terraform destroy
```

Estimated time to destroy: 5-10 minutes
Cost after destruction: $0

## Cost Tracking Spreadsheet

| Date | Action | Duration | Cost |
|------|--------|----------|------|
| Nov 6 | Deploy | 8 hours | ~$0.70 |
| Nov 7 | Interview Day | 4 hours | ~$0.35 |
| Nov 7 | Destroy | - | $0 |
| **Total** | | **12 hours** | **~$1.05** |

**For interview demo: Total cost under $2!**

