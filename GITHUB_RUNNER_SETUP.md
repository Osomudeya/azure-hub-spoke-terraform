# GitHub Self-Hosted Runner Setup

Complete guide for setting up GitHub Actions self-hosted runner.

## Prerequisites

- GitHub account
- Local computer (Windows/Mac/Linux)
- Administrator access

## Step 1: Create GitHub Repository

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/azure-hub-spoke-terraform.git
git push -u origin main
```

## Step 2: Install Runner

### On macOS:

```bash
# Create a folder
mkdir actions-runner && cd actions-runner

# Download the latest runner package
curl -o actions-runner-osx-x64-2.329.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-osx-x64-2.329.0.tar.gz

# Optional: Validate the hash
echo "c5a14e84b358c72ca83bf14518e004a8ad195cc440322fbca2a4fec7649035c7  actions-runner-osx-x64-2.329.0.tar.gz" | shasum -a 256 -c

# Extract the installer
tar xzf ./actions-runner-osx-x64-2.329.0.tar.gz
```

### Configure Runner

```bash
# Create the runner and start the configuration experience
./config.sh --url https://github.com/Osomudeya/azure-hub-spoke-terraform --token YOUR_TOKEN

# Last step, run it!
./run.sh
```

**Note:** Get the token from GitHub: Settings → Actions → Runners → New self-hosted runner

## Step 3: Configure Azure Credentials

```bash
# Create service principal with JSON output for GitHub Actions
az ad sp create-for-rbac --name "github-actions-terraform" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth

# Note: If --sdk-auth is not available in your Azure CLI version, use:
# az ad sp create-for-rbac --name "github-actions-terraform" \
#   --role contributor \
#   --scopes /subscriptions/{subscription-id}
# Then manually format the output as JSON with clientId, clientSecret, subscriptionId, and tenantId
```

Copy the JSON output. The output should contain `clientId`, `clientSecret`, `subscriptionId`, and `tenantId`.

## Step 4: Add GitHub Secret

1. Go to GitHub: Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `AZURE_CREDENTIALS`
4. Value: Paste the JSON from Step 3
5. Click "Add secret"

## Step 5: Using Your Self-Hosted Runner

In your workflow file, use:
```yaml
runs-on: self-hosted
```

## Step 6: Test Workflow

Trigger workflow manually:
1. Go to Actions tab
2. Select "Terraform Azure Hub-Spoke"
3. Click "Run workflow"
4. Select branch: `main`
5. Click "Run workflow" button

## Troubleshooting

**Runner offline:**
- Check runner terminal for errors
- If running as service: `sudo ./svc.sh status` (Linux/macOS) or check Windows Services
- Restart service: `sudo ./svc.sh restart` (Linux/macOS) or `./svc.cmd restart` (Windows)
- If running manually: `./run.sh` (Linux/macOS) or `./run.cmd` (Windows)

**Session Conflict Error:**
```
A session for this runner already exists.
Failed to create session. Error: Conflict
```

**Solution:**
1. Stop all runner processes:
```bash
# Stop the service
./svc.sh stop

# Kill any remaining runner processes
pkill -f "Runner.Listener"
pkill -f "actions-runner"
```

2. Wait a few seconds, then restart:
```bash
# Start the runner
./run.sh
```

**Multiple Runner Instances:**
If you see "A session for this runner already exists", it means multiple instances are running:
```bash
# Check for running processes
ps aux | grep -i "actions-runner\|Runner.Listener" | grep -v grep

# Kill all runner processes
pkill -f "Runner.Listener"
pkill -f "actions-runner"

# Start fresh
./run.sh
```

**Workflow fails:**
- Verify AZURE_CREDENTIALS secret
- Check runner is online
- Review workflow logs
- Ensure only one runner instance is running

