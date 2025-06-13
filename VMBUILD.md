## Deploy the Golden-LINUX VM

Click to launch the Azure portal pre-loaded with this template and parameter file, then fill in or review the required parameters:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcasa-de-vops%2Fazvmimagebuilder%2Frefs%2Fheads%2Fmain%2Ftemplates%2F10_Virtual_Machine_Deployment_Template%2Fazuredeploy.linux.json)

## Deploy the Golden-RHEL VM

Click to launch the Azure portal pre-loaded with this template and parameter file, then fill in or review the required parameters:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcasa-de-vops%2Fazvmimagebuilder%2Frefs%2Fheads%2Fmain%2Ftemplates%2F10_Virtual_Machine_Deployment_Template%2Fazuredeploy.linux.json)

## Deploy the Golden-Windows VM

Click to launch the Azure portal pre-loaded with this template and parameter file, then fill in or review the required parameters:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcasa-de-vops%2Fazvmimagebuilder%2Frefs%2Fheads%2Fmain%2Ftemplates%2F10_Virtual_Machine_Deployment_Template%2Fazuredeploy.windows.json)

## Deploy with GitHub Actions 🚀

For **automated, secure deployments** using repository secrets, use the GitHub Actions workflow:

### Quick Start
1. **Set up repository secrets** - See [Repository Secrets Setup Guide](docs/Repository-Secrets-Setup.md)
2. **Navigate to Actions** → [Deploy Azure VM from Gallery](../../actions/workflows/deploy-vm.yml)
3. **Click "Run workflow"** and select your desired parameters:
   - Environment (dev/staging/prod)
   - VM Type (Linux/Windows)
   - Gallery Image Name
   - VM Size
   - Custom VM Name (optional)

### Benefits of GitHub Actions Deployment
- 🔒 **Secure**: No hardcoded credentials, uses repository secrets
- 🔄 **Repeatable**: Consistent deployments across environments
- 📋 **Auditable**: Full deployment history and logs
- 🛡️ **Validated**: Pre-deployment validation and what-if analysis
- 🧹 **Self-Healing**: Automatic cleanup on deployment failures
- 📊 **Detailed Reporting**: Comprehensive deployment summaries

### Supported Deployment Options
- **Linux VMs**: Certificate-based authentication with Azure Arc integration
- **Windows VMs**: Password authentication with optional auto-shutdown
- **Multiple Environments**: Dev, Staging, Production with environment-specific secrets
- **Flexible VM Sizing**: Choose from Standard_DS2_v2, Standard_DS3_v2, Standard_B2s, and more

---


> **Tip**  
> This repository is currently using the publicly hosted template located at `https://raw.githubusercontent.com/casa-de-vops/azvmimagebuilder/refs/heads/main/templates/10_Virtual_Machine_Deployment_Template/azuredeploy.linux.json`. If you want to use a different version of the template, you can download it and host it in your own storage account, or fork this repository and use the URL of your forked repository.

For more details on using the "Deploy to Azure" button, see the [official documentation](https://learn.microsoft.com/azure/azure-resource-manager/templates/deploy-to-azure-button). This button pre-loads the Azure portal with your template and parameter file, making it easy to deploy a VM using Azure Resource Manager templates.

See documentation for more information on how to [deploy a VM using an Azure Resource Manager template](https://docs.microsoft.com/azure/virtual-machines/linux/quick-create-portal).