# Linux VM Deployment Template

This ARM template deploys a Linux virtual machine from a Shared Image Gallery with certificate-based authentication and Azure Arc integration.

## Overview

This template creates:
- A Linux Virtual Machine from a Shared Image Gallery image
- A Network Interface attached to an existing subnet
- Certificate-based authentication using Azure Key Vault
- Azure Arc agent installation for hybrid management
- System-assigned managed identity for the VM

## Key Features

- **Enhanced Security**: Uses certificate-based authentication from Azure Key Vault
- **Hybrid Management**: Automatic Azure Arc agent installation
- **Enterprise Ready**: Supports both Ubuntu/RHEL images from Shared Image Gallery
- **Monitoring**: System-assigned managed identity for Azure monitoring integration
- **Customization**: Cloud-init support through customData

## Parameters

### Required Parameters
- `vmName`: Name of the virtual machine
- `keyVaultId`: Resource ID of the Key Vault containing the certificate
- `certificateUrl`: Key Vault secret URI for the certificate

### Optional Parameters (with defaults)
- `adminUsername`: Administrator username (default: "azureuser")
- `adminPassword`: Administrator password (default: "<yourPasswordHere>")
- `vmSize`: VM size (default: "Standard_DS2_v2")
- `imageName`: Image name from gallery (default: "GoldenLinuxImage")
- `imageVersion`: Image version (default: "latest")
- `arcInstallScriptUri`: Azure Arc installation script URL

### Infrastructure Parameters (with defaults)
- `gallerySubscriptionId`: Subscription containing the gallery
- `galleryResourceGroup`: Resource group containing the gallery
- `galleryName`: Name of the Shared Image Gallery
- `subnetId`: Resource ID of the target subnet

## Certificate Requirements

This template requires a certificate stored in Azure Key Vault for enhanced security:

### Certificate Format
- The certificate must be stored as a secret in Azure Key Vault
- Certificate URL format: `https://<keyvaultname>.vault.azure.net/secrets/<secretname>/<secretidentifier>`
- The certificate will be automatically installed in the VM's certificate store

### Key Vault Access
- The deployment service principal must have `Get` and `List` permissions on Key Vault secrets
- The VM's system-assigned managed identity can be granted access for runtime operations

## Supported Images

The template supports these pre-built images from the Shared Image Gallery:
- **GoldenLinuxImage**: Ubuntu-based golden image
- **GoldenRHELImage**: Red Hat Enterprise Linux golden image

## Azure Arc Integration

The template automatically installs the Azure Arc agent, enabling:
- **Hybrid Management**: Manage the VM through Azure Resource Manager
- **Policy Compliance**: Apply Azure Policy to on-premises or multi-cloud VMs
- **Extensions**: Install and manage Azure VM extensions
- **Monitoring**: Integrate with Azure Monitor and Azure Security Center

## Deployment Examples

### Using Azure CLI
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.linux.json \
  --parameters vmName=myLinuxVM \
               keyVaultId="/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/myKeyVault" \
               certificateUrl="https://mykeyvault.vault.azure.net/secrets/mycert/abc123"
```

### Using Azure PowerShell
```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "azuredeploy.linux.json" `
  -vmName "myLinuxVM" `
  -keyVaultId "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/myKeyVault" `
  -certificateUrl "https://mykeyvault.vault.azure.net/secrets/mycert/abc123"
```

### Using Parameters File
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.linux.json \
  --parameters @azuredeploy.linux.parameters.json
```

### Deployment with Custom Password
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.linux.json \
  --parameters @azuredeploy.linux.parameters.json \
               adminPassword='YourSecurePassword123!'
```

## Outputs

The template provides this output:
- `vmResourceId`: Resource ID of the created virtual machine

## Security Considerations

1. **Certificate Management**: 
   - Store certificates securely in Azure Key Vault
   - Implement certificate rotation policies
   - Use appropriate certificate types (RSA 2048-bit minimum)

2. **Access Control**:
   - Limit Key Vault access to necessary principals only
   - Use Azure RBAC for fine-grained access control
   - Monitor Key Vault access logs

3. **Network Security**:
   - Deploy VMs in protected subnets
   - Configure Network Security Groups appropriately
   - Consider using Azure Bastion for secure access

4. **Identity Management**:
   - System-assigned managed identity is enabled by default
   - Consider user-assigned managed identities for shared scenarios
   - Implement least-privilege access principles

## Monitoring and Management

1. **Azure Arc Benefits**:
   - Centralized management through Azure portal
   - Consistent policy application across hybrid infrastructure
   - Azure Monitor integration for comprehensive monitoring

2. **System Identity**:
   - Enables secure access to Azure resources without stored credentials
   - Supports Azure Monitor, Azure Security Center integration
   - Facilitates automated backup and disaster recovery

## Troubleshooting

1. **Deployment Failures**:
   - Verify Shared Image Gallery image exists and is accessible
   - Check Key Vault permissions and certificate availability
   - Ensure subnet ID is correct and accessible

2. **Certificate Issues**:
   - Verify certificate URL format and accessibility
   - Check Key Vault access policies
   - Ensure certificate is properly formatted

3. **Azure Arc Installation**:
   - Check network connectivity to Azure Arc service endpoints
   - Verify the Arc installation script URL is accessible
   - Review VM boot diagnostics for installation logs

4. **Network Connectivity**:
   - Verify subnet configuration and routing
   - Check Network Security Group rules
   - Ensure DNS resolution is working

## Best Practices

1. **Security**:
   - Regularly rotate certificates stored in Key Vault
   - Implement monitoring for Key Vault access
   - Use strong, unique passwords for local accounts

2. **Management**:
   - Tag resources appropriately for cost management
   - Implement backup strategies for critical VMs
   - Monitor resource utilization and costs

3. **Networking**:
   - Use dedicated subnets for VM deployments
   - Implement proper network segmentation
   - Configure monitoring for network traffic

## Prerequisites

Before deploying this template, ensure you have:
- An existing Shared Image Gallery with Linux images
- An Azure Key Vault with appropriate certificates
- A virtual network with subnets configured
- Proper RBAC permissions for deployment
- Network connectivity for Azure Arc agent installation

## Related Templates

- **Windows VM Template**: `azuredeploy.windows.json` - Windows VMs with simplified password authentication
- **Custom Image Templates**: Located in `../1_Creating_a_Custom_Linux_Shared_Image_Gallery_Image/` for building custom images
