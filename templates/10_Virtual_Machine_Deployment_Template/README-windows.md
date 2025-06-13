# Windows VM Deployment Template

This ARM template deploys a Windows virtual machine from a Shared Image Gallery using password authentication only.

## Overview

This template creates:
- A Windows Virtual Machine from a Shared Image Gallery image
- A Network Security Group with RDP access allowed
- A Network Interface attached to an existing subnet
- Optional auto-shutdown schedule for cost optimization
- System-assigned managed identity for the VM

## Key Features

- **Simplified Authentication**: Uses only username/password (no certificates required)
- **Security**: Includes Network Security Group with RDP access
- **Cost Optimization**: Optional auto-shutdown feature
- **Monitoring**: Boot diagnostics enabled
- **Windows-Optimized**: Automatic updates and VM agent enabled

## Parameters

### Required Parameters
- `vmName`: Name of the virtual machine
- `adminPassword`: Administrator password (must meet Windows complexity requirements)

### Optional Parameters (with defaults)
- `adminUsername`: Administrator username (default: "azureuser")
- `vmSize`: VM size (default: "Standard_DS2_v2")
- `imageName`: Image name from gallery (default: "GoldenWindowsImage")
- `imageVersion`: Image version (default: "latest")
- `enableAutoShutdown`: Enable auto-shutdown (default: false)
- `autoShutdownTime`: Shutdown time in 24-hour format (default: "19:00")
- `autoShutdownTimeZone`: Time zone for shutdown (default: "UTC")

### Infrastructure Parameters (with defaults)
- `gallerySubscriptionId`: Subscription containing the gallery
- `galleryResourceGroup`: Resource group containing the gallery
- `galleryName`: Name of the Shared Image Gallery
- `subnetId`: Resource ID of the target subnet

## Password Requirements

The Windows VM requires a complex password that meets these criteria:
- Minimum 12 characters
- Contains uppercase letters
- Contains lowercase letters
- Contains numbers
- Contains special characters

## Deployment Examples

### Using Azure CLI
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.windows.json \
  --parameters vmName=myWindowsVM adminPassword='YourSecurePassword123!'
```

### Using Azure PowerShell
```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "azuredeploy.windows.json" `
  -vmName "myWindowsVM" `
  -adminPassword (ConvertTo-SecureString "YourSecurePassword123!" -AsPlainText -Force)
```

### Using Parameters File
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.windows.json \
  --parameters @azuredeploy.windows.parameters.json
```

## Outputs

The template provides these outputs:
- `vmResourceId`: Resource ID of the created VM
- `vmName`: Name of the created VM
- `privateIPAddress`: Private IP address assigned to the VM
- `networkInterfaceId`: Resource ID of the network interface

## Security Considerations

1. **Password Security**: Use a strong, unique password and consider using Azure Key Vault for password management
2. **Network Access**: The template allows RDP access from any source. Consider restricting the source IP range in production
3. **System Updates**: Automatic updates are enabled by default
4. **Monitoring**: Boot diagnostics are enabled for troubleshooting

## Differences from Linux Template

This Windows template differs from the Linux template in several ways:
- Removes certificate-based authentication (Key Vault and certificate parameters)
- Removes Azure Arc installation script
- Adds Windows-specific configuration (automatic updates, VM agent)
- Includes RDP access in the Network Security Group
- Adds auto-shutdown functionality for cost optimization
- Enhanced outputs for better monitoring

## Cost Optimization

- Consider enabling auto-shutdown for development/test environments
- Use appropriate VM sizes for your workload
- Premium SSD is used for better performance but consider Standard SSD for cost savings if performance requirements are lower

## Troubleshooting

1. **Deployment Failures**: Check that the Shared Image Gallery image exists and is accessible
2. **Network Connectivity**: Verify the subnet ID is correct and the subnet exists
3. **Password Issues**: Ensure the password meets Windows complexity requirements
4. **RDP Access**: Verify the Network Security Group rules allow access from your IP range
