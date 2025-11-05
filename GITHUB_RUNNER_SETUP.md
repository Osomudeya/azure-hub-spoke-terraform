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

### On Linux:

```bash
# Create directory
mkdir actions-runner && cd actions-runner

# Download runner (check https://github.com/actions/runner/releases for latest version)
curl -o actions-runner-linux-x64-2.329.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64-2.329.0.tar.gz

# Configure (get token from GitHub Settings → Actions → Runners)
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN

# Install as service (recommended for production)
sudo ./svc.sh install
sudo ./svc.sh start

# Or run manually (for testing)
# ./run.sh
```

### On macOS:

```bash
# Create directory
mkdir actions-runner && cd actions-runner

# Download runner for Intel Mac (check https://github.com/actions/runner/releases for latest version)
curl -o actions-runner-osx-x64-2.329.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-osx-x64-2.329.0.tar.gz

# OR for Apple Silicon (ARM64) Mac:
# curl -o actions-runner-osx-arm64-2.329.0.tar.gz -L \
#   https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-osx-arm64-2.329.0.tar.gz

# Extract
tar xzf ./actions-runner-osx-x64-2.329.0.tar.gz

# Configure (get token from GitHub Settings → Actions → Runners)
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN

# Install as service (recommended for production)
sudo ./svc.sh install
sudo ./svc.sh start

# Or run manually (for testing)
# ./run.sh
```

### On Windows (PowerShell):

```powershell
# Create directory
mkdir actions-runner ; cd actions-runner

# Download (check https://github.com/actions/runner/releases for latest version)
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-win-x64-2.329.0.zip -OutFile actions-runner-win-x64-2.329.0.zip

# Extract
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.329.0.zip", "$PWD")

# Configure
./config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN

# Install as service (recommended for production - run as Administrator)
./svc.cmd install
./svc.cmd start

# Or run manually (for testing)
# ./run.cmd
```

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

## Step 5: Test Workflow

Trigger workflow manually:
1. Go to Actions tab
2. Select "Terraform Azure Hub-Spoke"
3. Click "Run workflow"

## Troubleshooting

**Runner offline:**
- Check runner terminal for errors
- If running as service: `sudo ./svc.sh status` (Linux/macOS) or check Windows Services
- Restart service: `sudo ./svc.sh restart` (Linux/macOS) or `./svc.cmd restart` (Windows)
- If running manually: `./run.sh` (Linux/macOS) or `./run.cmd` (Windows)

**Workflow fails:**
- Verify AZURE_CREDENTIALS secret
- Check runner is online
- Review workflow logs

