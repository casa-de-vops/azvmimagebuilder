# Linux VM Deployment Template

This ARM template deploys a Linux virtual machine from a Shared Image Gallery with SSH key-based authentication and Azure Arc integration.

## Overview

This template creates:
- A Linux Virtual Machine from a Shared Image Gallery image
- A Network Interface attached to an existing subnet
- SSH key-based authentication using Azure stored SSH keys
- Azure Arc agent installation for hybrid management
- System-assigned managed identity for the VM

## Key Features

- **Enhanced Security**: Uses SSH key-based authentication with Azure stored public keys
- **Hybrid Management**: Automatic Azure Arc agent installation
- **Enterprise Ready**: Supports both Ubuntu/RHEL images from Shared Image Gallery
- **Monitoring**: System-assigned managed identity for Azure monitoring integration
- **Customization**: Cloud-init support through customData
- **Secure Access**: Password authentication can be disabled for improved security

## Parameters

### Required Parameters
- `vmName`: Name of the virtual machine
- `sshKeyResourceGroup`: Resource group containing the SSH key resource
- `sshKeyName`: Name of the SSH key resource in Azure

### Optional Parameters (with defaults)
- `adminUsername`: Administrator username (default: "azureuser")
- `disablePasswordAuthentication`: Disable password auth and use SSH only (default: true)
- `vmSize`: VM size (default: "Standard_DS2_v2")
- `imageName`: Image name from gallery (default: "GoldenLinuxImage")
- `imageVersion`: Image version (default: "latest")
- `arcInstallScriptUri`: Azure Arc installation script URL

### Infrastructure Parameters (with defaults)
- `gallerySubscriptionId`: Subscription containing the gallery
- `galleryResourceGroup`: Resource group containing the gallery
- `galleryName`: Name of the Shared Image Gallery
- `subnetId`: Resource ID of the target subnet

## SSH Key Requirements

This template requires an SSH public key stored as an Azure resource for secure authentication:

### SSH Key Setup
- Create an SSH key pair using `ssh-keygen -t rsa -b 4096`
- Store the public key in Azure using: `az sshkey create --name <key-name> --resource-group <rg-name> --public-key @~/.ssh/id_rsa.pub`
- The public key will be automatically configured for the admin user
- Keep your private key secure and use it to connect to the VM

### Access Requirements
- The deployment requires read access to the SSH key resource
- The deployment service principal needs `Microsoft.Compute/sshPublicKeys/read` permission

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

### Prerequisites
First, create an SSH key resource in Azure:
```bash
# Create SSH key pair locally
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vm_key

# Create Azure SSH key resource
az sshkey create \
  --name "my-vm-ssh-key" \
  --resource-group "rg-ssh-keys" \
  --public-key "$(cat ~/.ssh/vm_key.pub)"
```

### Using Azure CLI
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.linux.json \
  --parameters vmName=myLinuxVM \
               sshKeyResourceGroup="rg-ssh-keys" \
               sshKeyName="my-vm-ssh-key"
```

### Using Azure PowerShell
```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "azuredeploy.linux.json" `
  -vmName "myLinuxVM" `
  -sshKeyResourceGroup "rg-ssh-keys" `
  -sshKeyName "my-vm-ssh-key"
```

### Using Parameters File
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.linux.json \
  --parameters @azuredeploy.linux.parameters.json
```

### Connecting to the VM
After deployment, connect using SSH with your private key:
```bash
ssh -i ~/.ssh/vm_key azureuser@<vm-private-ip>
```
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.linux.json \
  --parameters @azuredeploy.linux.parameters.json \
               disablePasswordAuthentication=false
```

## Outputs

The template provides these outputs:
- `vmResourceId`: Resource ID of the created virtual machine
- `sshConnectionCommand`: SSH command to connect to the VM using private IP
- `adminUsername`: The admin username for the VM

## Security Considerations

1. **SSH Key Management**: 
   - Store SSH private keys securely and never share them
   - Use strong SSH key encryption (RSA 4096-bit recommended)
   - Implement SSH key rotation policies
   - Consider using SSH certificates for enterprise scenarios

2. **Access Control**:
   - Disable password authentication when using SSH keys (recommended)
   - Limit SSH key resource access to necessary principals only
   - Use Azure RBAC for fine-grained access control
   - Monitor SSH access logs

3. **Network Security**:
   - Deploy VMs in protected subnets
   - Configure Network Security Groups to limit SSH access
   - Consider using Azure Bastion for secure access
   - Restrict SSH access to specific source IP ranges

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
   - Check SSH key resource permissions and availability
   - Ensure subnet ID is correct and accessible
   - Validate SSH key resource group and name parameters

2. **SSH Key Issues**:
   - Verify SSH key resource exists in the specified resource group
   - Check that the SSH key resource is accessible to the deployment principal
   - Ensure SSH key format is correct (public key should start with ssh-rsa, ssh-ed25519, etc.)
   - Validate that the SSH key resource has the correct public key data

3. **Authentication Issues**:
   - If password authentication is disabled, ensure SSH key is properly configured
   - Check that the private key corresponds to the public key stored in Azure
   - Verify SSH client configuration and key file permissions (600 for private key)

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
   - Regularly rotate SSH keys and update Azure SSH key resources
   - Implement monitoring for SSH access attempts
   - Use SSH key passphrases for additional security
   - Disable password authentication in favor of SSH keys
   - Consider using SSH certificates for enterprise environments

2. **Management**:
   - Tag resources appropriately for cost management
   - Implement backup strategies for critical VMs
   - Monitor resource utilization and costs
   - Keep SSH key inventory and manage access centrally

3. **Networking**:
   - Use dedicated subnets for VM deployments
   - Implement Network Security Groups with least privilege access
   - Consider using Azure Bastion or jump boxes for SSH access
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
