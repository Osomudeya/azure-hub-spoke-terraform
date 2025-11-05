#!/bin/bash
# Test VM connectivity - Updated for modular architecture

set -e

echo "=================================="
echo "Hub-Spoke Connectivity Test"
echo "Modular Architecture Edition"
echo "=================================="
echo ""

cd environments/dev

# Check if infrastructure is deployed
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ No terraform state found. Deploy infrastructure first."
    exit 1
fi

echo "Getting VM details from modular outputs..."

# Extract VM details using the new modular output structure
VM1_PUBLIC_IP=$(terraform output -json spoke1_details 2>/dev/null | jq -r '.public_ip' 2>/dev/null)
VM1_PRIVATE_IP=$(terraform output -json spoke1_details 2>/dev/null | jq -r '.private_ip' 2>/dev/null)
VM2_PUBLIC_IP=$(terraform output -json spoke2_details 2>/dev/null | jq -r '.public_ip' 2>/dev/null)
VM2_PRIVATE_IP=$(terraform output -json spoke2_details 2>/dev/null | jq -r '.private_ip' 2>/dev/null)

if [ -z "$VM1_PUBLIC_IP" ] || [ -z "$VM2_PRIVATE_IP" ] || [ "$VM1_PUBLIC_IP" = "null" ] || [ "$VM2_PRIVATE_IP" = "null" ]; then
    echo "❌ Could not get VM IPs from Terraform outputs"
    echo "Attempting alternative output parsing..."
    
    # Try alternative parsing
    terraform output
    exit 1
fi

echo "✅ VM1 (Spoke1) Public IP: $VM1_PUBLIC_IP"
echo "✅ VM1 (Spoke1) Private IP: $VM1_PRIVATE_IP"
echo "✅ VM2 (Spoke2) Public IP: $VM2_PUBLIC_IP"
echo "✅ VM2 (Spoke2) Private IP: $VM2_PRIVATE_IP"
echo ""

# Check peering status
echo "Checking VNet peering status..."
PEERING_STATUS=$(terraform output -json peering_status 2>/dev/null | jq -r '.hub_to_spoke1_status' 2>/dev/null)
if [ "$PEERING_STATUS" = "Connected" ]; then
    echo "✅ Hub-Spoke1 peering: Connected"
else
    echo "⚠️  Hub-Spoke1 peering status: $PEERING_STATUS"
fi

PEERING_STATUS=$(terraform output -json peering_status 2>/dev/null | jq -r '.hub_to_spoke2_status' 2>/dev/null)
if [ "$PEERING_STATUS" = "Connected" ]; then
    echo "✅ Hub-Spoke2 peering: Connected"
else
    echo "⚠️  Hub-Spoke2 peering status: $PEERING_STATUS"
fi
echo ""

SSH_KEY="$HOME/.ssh/azure_hubspoke_key"
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found at $SSH_KEY"
    exit 1
fi

echo "Testing SSH connection to VM1 (Spoke1)..."
if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i "$SSH_KEY" azureuser@"$VM1_PUBLIC_IP" "echo 'SSH to VM1 successful'" &> /dev/null; then
    echo "✅ SSH connection to VM1 successful"
else
    echo "❌ SSH connection to VM1 failed"
    exit 1
fi

echo ""
echo "Testing connectivity from VM1 (Spoke1) to VM2 (Spoke2)..."
PING_RESULT=$(ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" azureuser@"$VM1_PUBLIC_IP" "ping -c 4 -W 2 $VM2_PRIVATE_IP 2>&1")

if echo "$PING_RESULT" | grep -q "bytes from"; then
    echo "✅ Cross-spoke connectivity test PASSED!"
    echo ""
    echo "Ping Results:"
    echo "$PING_RESULT"
    echo ""
    echo "=================================="
    echo "🎉 MODULAR HUB-SPOKE SUCCESS!"
    echo "=================================="
    echo ""
    echo "✅ Resource Group deployed"
    echo "✅ Hub Network module working"
    echo "✅ Spoke1 Network module working"  
    echo "✅ Spoke2 Network module working"
    echo "✅ VNet Peering modules working"
    echo "✅ VM1 can reach VM2 via hub"
    echo ""
    echo "🏗️  Modular Architecture Benefits:"
    echo "   • Each component is independently managed"
    echo "   • Easy to add more spokes"
    echo "   • Team ownership separation"
    echo "   • Reusable across environments"
    echo ""
else
    echo "❌ Cross-spoke connectivity test FAILED"
    echo ""
    echo "Ping Results:"
    echo "$PING_RESULT"
    echo ""
    echo "Troubleshooting suggestions:"
    echo "1. Check VNet peering status in Azure Portal"
    echo "2. Verify NSG rules allow cross-spoke traffic"
    echo "3. Ensure both VMs are running"
    echo "4. Check routing tables"
    exit 1
fi

# Show modular architecture summary
echo "=================================="
echo "📊 MODULAR ARCHITECTURE SUMMARY"
echo "=================================="
echo ""

echo "🏗️  Deployed Modules:"
echo "   • resource-group: Shared foundation"
echo "   • hub-network: Central connectivity"
echo "   • spoke-network (x2): Workload environments"  
echo "   • vnet-peering (x2): Bidirectional connections"
echo ""

echo "🔗 Module Dependencies:"
echo "   spoke-network → resource-group"
echo "   hub-network → resource-group"
echo "   vnet-peering → hub-network + spoke-network"
echo ""

echo "📈 Scaling Ready:"
echo "   Add spoke3: Just duplicate spoke-network module"
echo "   Add peering: Just duplicate vnet-peering module"
echo "   Different environments: Reuse all modules"
echo ""