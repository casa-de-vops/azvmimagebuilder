# VM Deployment Quick Start Guide

This guide helps you quickly get started with deploying Azure VMs from your Shared Image Gallery using GitHub Actions.

## 🚀 Quick Start (5 minutes)

### 1. Prerequisites Check
Run the validation script to check your environment:
```powershell
.\scripts\Test-RepositorySecrets.ps1 -ValidateResources -TestLinux -TestWindows
```

### 2. Configure Repository Secrets
Set up the required secrets in GitHub (Settings → Secrets and variables → Actions):

**Essential Secrets:**
- `AZURE_CREDENTIALS` - Service principal JSON
- `AZURE_SUBSCRIPTION_ID` - Your Azure subscription ID
- `AZURE_RESOURCE_GROUP` - Target resource group name
- `VM_ADMIN_USERNAME` - VM administrator username (e.g., "azureuser")
- `VM_ADMIN_PASSWORD` - Strong password (min 12 chars, complex)
- `SUBNET_ID` - Full resource ID of your subnet

**Linux VMs only:**
- `KEYVAULT_ID` - Key Vault resource ID
- `CERTIFICATE_URL` - Certificate secret URL from Key Vault

### 3. Deploy Your First VM
1. Go to **Actions** → **Deploy Azure VM from Gallery**
2. Click **Run workflow**
3. Choose your parameters:
   - Environment: `dev`
   - VM Type: `linux` or `windows`
   - Image Name: `GoldenLinuxImage` or `GoldenWindowsImage`
   - VM Size: `Standard_B2s` (for testing)

## 📁 Files Overview

### Templates
```
templates/10_Virtual_Machine_Deployment_Template/
├── azuredeploy.linux.json           # Linux VM ARM template
├── azuredeploy.windows.json         # Windows VM ARM template
├── azuredeploy.linux.parameters.json    # Linux parameters example
├── azuredeploy.windows.parameters.json  # Windows parameters example
├── README-linux.md                  # Linux template documentation
└── README-windows.md                # Windows template documentation
```

### Workflows
```
.github/workflows/
├── deploy-vm.yml                    # Main VM deployment workflow
├── GoldenLinuxImage.yml            # Linux image building
├── GoldenWindowsImage.yml          # Windows image building
└── README.md                       # Workflow documentation
```

### Documentation
```
docs/
├── Repository-Secrets-Setup.md     # Detailed secrets setup guide
└── GitHub-Environment-Setup.md     # GitHub environment configuration
```

### Scripts
```
scripts/
└── Test-RepositorySecrets.ps1      # Validation script for setup
```

## 🔄 Deployment Options

### Option 1: GitHub Actions (Recommended)
- **Secure**: Uses repository secrets
- **Auditable**: Full deployment history
- **Automated**: Validation and cleanup
- **Multi-environment**: Dev/staging/prod support

### Option 2: Deploy to Azure Button
- **Quick**: One-click deployment
- **Manual**: Fill parameters in Azure portal
- **Simple**: No setup required

### Option 3: Manual CLI Deployment
```powershell
# Example Linux deployment
az deployment group create `
  --resource-group "myResourceGroup" `
  --template-file "templates/10_Virtual_Machine_Deployment_Template/azuredeploy.linux.json" `
  --parameters vmName="my-linux-vm" adminPassword="YourPassword123!" `
              keyVaultId="/subscriptions/.../vaults/myKeyVault" `
              certificateUrl="https://mykeyvault.vault.azure.net/secrets/cert/abc123"
```

## 🔧 Configuration Examples

### Development Environment
```yaml
# GitHub Actions workflow parameters
environment: dev
vmType: linux
imageName: GoldenLinuxImage
vmSize: Standard_B2s
enableAutoShutdown: true  # Windows only
customVmName: dev-test-vm
```

### Production Environment
```yaml
# GitHub Actions workflow parameters
environment: prod
vmType: windows
imageName: GoldenWindowsImage
vmSize: Standard_DS2_v2
enableAutoShutdown: false
```

## 🏗️ Architecture

```
GitHub Repository
├── GitHub Actions Workflow
│   ├── Input Validation
│   ├── Azure Authentication
│   ├── Template Validation
│   ├── What-If Analysis
│   ├── VM Deployment
│   └── Cleanup on Failure
│
└── ARM Templates
    ├── Linux Template
    │   ├── Certificate Auth
    │   ├── Azure Arc Integration
    │   └── SSH Access
    │
    └── Windows Template
        ├── Password Auth
        ├── RDP Access
        ├── Auto-Shutdown
        └── Network Security
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Authentication Failures
```powershell
# Check service principal
az ad sp show --id "your-client-id"

# Test login
az login --service-principal -u "client-id" -p "client-secret" --tenant "tenant-id"
```

#### 2. Resource Not Found
- Verify resource group exists
- Check subnet ID format and permissions
- Ensure Key Vault is accessible (Linux VMs)

#### 3. Template Validation Errors
- Check parameter compatibility
- Verify VM size availability in region
- Ensure image exists in gallery

#### 4. Deployment Failures
- Review Azure quotas and limits
- Check network configuration
- Validate ARM template error messages

### Getting Help

1. **Check workflow logs** in GitHub Actions
2. **Review deployment outputs** for resource details
3. **Use the validation script** to check prerequisites
4. **Consult documentation** in the `docs/` folder

## 📊 Monitoring & Management

### Deployment Tracking
- **GitHub Actions UI**: Real-time progress
- **Azure Portal**: Resource deployment status
- **Workflow Summaries**: Detailed deployment reports

### Post-Deployment
- **Linux VMs**: SSH access, Azure Arc management
- **Windows VMs**: RDP access, auto-shutdown management
- **Monitoring**: Azure Monitor integration
- **Cost Management**: Resource tagging and optimization

## 🎯 Next Steps

1. **Test the deployment** with a development VM
2. **Set up environments** for staging and production
3. **Configure approval workflows** for production deployments
4. **Implement monitoring** and alerting
5. **Explore advanced features** like custom extensions

## 📚 Additional Resources

- [Azure VM Image Builder Documentation](https://docs.microsoft.com/azure/virtual-machines/image-builder-overview)
- [ARM Template Reference](https://docs.microsoft.com/azure/templates/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)

---

**Happy Deploying! 🚀**

> 💡 **Tip**: Start with a small development VM to test your setup before deploying production workloads.
