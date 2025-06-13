# Repository Secrets Setup Guide

This document provides a comprehensive guide for setting up all required GitHub repository secrets for the Azure VM Image Builder workflows.

## Overview

The Azure VM Image Builder workflows require several secrets to authenticate with Azure and access necessary resources. These secrets must be configured in your GitHub repository before running any workflows.

## Required Secrets

### 1. Azure Authentication Secrets

These secrets are used for authenticating with Azure using OpenID Connect (OIDC) or service principal authentication:

| Secret Name | Description | Required | Example Value |
|-------------|-------------|----------|---------------|
| `AZURE_CLIENT_ID` | The Application (client) ID of your Azure AD app registration | ✅ | `12345678-1234-1234-1234-123456789012` |
| `AZURE_TENANT_ID` | The Directory (tenant) ID of your Azure AD tenant | ✅ | `87654321-4321-4321-4321-210987654321` |
| `AZURE_SUBSCRIPTION_ID` | The ID of your Azure subscription | ✅ | `abcdef12-3456-7890-abcd-ef1234567890` |

### 2. Network Configuration Secrets

| Secret Name | Description | Required | Example Value |
|-------------|-------------|----------|---------------|
| `SUBNET_ID` | The full Azure resource ID of the subnet for deploying validation VMs | ✅ | `/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}` |

### 3. VM Deployment Secrets

These secrets are required for the VM deployment workflow (`deploy-vm.yml`):

| Secret Name | Description | Required | Example Value |
|-------------|-------------|----------|---------------|
| `AZURE_CREDENTIALS` | Service principal credentials in JSON format | ✅ | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |
| `AZURE_RESOURCE_GROUP` | Target resource group name for VM deployments | ✅ | `rg-vms-dev-westus2-001` |
| `VM_ADMIN_USERNAME` | Administrator username for deployed VMs | ✅ | `azureuser` |
| `VM_ADMIN_PASSWORD` | Administrator password for deployed VMs (must meet complexity requirements) | ✅ | `YourSecurePassword123!` |
| `KEYVAULT_ID` | Resource ID of Key Vault containing certificates (Linux VMs only) | ✅ (Linux) | `/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/kv-example` |
| `CERTIFICATE_URL` | Key Vault secret URI for VM certificate (Linux VMs only) | ✅ (Linux) | `https://kv-example.vault.azure.net/secrets/vm-cert/abc123` |

## Setting Up the Secrets

### Step 1: Navigate to Repository Settings

1. Go to your GitHub repository
2. Click on the **Settings** tab
3. In the left sidebar, click on **Secrets and variables** → **Actions**

### Step 2: Add Required Secrets

For each secret listed above, click **New repository secret** and:

1. Enter the **Name** (exactly as shown in the table)
2. Enter the **Value** (your actual Azure resource values)
3. Click **Add secret**

## How to Obtain Secret Values

### Azure Authentication Values

You'll need to create an Azure AD app registration and service principal:

```powershell
# Login to Azure
Connect-AzAccount

# Create a new Azure AD app registration
$app = New-AzADApplication -DisplayName "GitHub-Actions-ImageBuilder"

# Create a service principal for the app
$sp = New-AzADServicePrincipal -ApplicationId $app.AppId

# Get the values you need
Write-Host "AZURE_CLIENT_ID: $($app.AppId)"
Write-Host "AZURE_TENANT_ID: $((Get-AzContext).Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $((Get-AzContext).Subscription.Id)"
```

### Required Azure Permissions

The service principal needs the following permissions:

- **Contributor** role on the subscription or resource groups where:
  - Shared Image Gallery resources are located
  - Image Builder resources will be created
  - Validation VMs will be deployed

- **User Access Administrator** role (if the workflow creates role assignments)

### Subnet ID

To get your subnet resource ID:

```powershell
# Replace with your actual values
$resourceGroupName = "your-vnet-resource-group"
$vnetName = "your-virtual-network"
$subnetName = "your-subnet"

# Get the subnet resource ID
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName) -Name $subnetName
Write-Host "SUBNET_ID: $($subnet.Id)"
```

### VM Deployment Secret Values

#### AZURE_CREDENTIALS
Create a service principal with JSON credentials:

```powershell
# Create service principal for GitHub Actions
$sp = New-AzADServicePrincipal -DisplayName "github-actions-vm-deployment" -Role "Contributor"

# Output the JSON format needed for AZURE_CREDENTIALS secret
$credentials = @{
    clientId = $sp.AppId
    clientSecret = $sp.PasswordCredentials.SecretText
    subscriptionId = (Get-AzContext).Subscription.Id
    tenantId = (Get-AzContext).Tenant.Id
} | ConvertTo-Json -Compress

Write-Host "AZURE_CREDENTIALS:"
Write-Host $credentials
```

#### VM_ADMIN_PASSWORD
Choose a strong password that meets these requirements:
- Minimum 12 characters
- Contains uppercase letters (A-Z)
- Contains lowercase letters (a-z)
- Contains numbers (0-9)
- Contains special characters (!@#$%^&*)
- Example: `YourSecurePassword123!`

#### KEYVAULT_ID and CERTIFICATE_URL (Linux VMs only)

```powershell
# Get Key Vault resource ID
$keyVaultName = "your-keyvault-name"
$keyVaultRg = "your-keyvault-resource-group"
$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $keyVaultRg
Write-Host "KEYVAULT_ID: $($keyVault.ResourceId)"

# Get certificate URL (replace 'your-cert-name' with actual certificate name)
$certName = "your-cert-name"
$cert = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $certName
Write-Host "CERTIFICATE_URL: $($cert.Id)"
```

Or using Azure CLI:

```bash
# Replace with your actual values
RESOURCE_GROUP="your-vnet-resource-group"
VNET_NAME="your-virtual-network"
SUBNET_NAME="your-subnet"

# Get the subnet resource ID
az network vnet subnet show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --query id \
  --output tsv
```

## Security Best Practices

### 1. Principle of Least Privilege
- Grant only the minimum permissions required
- Consider using resource group-scoped permissions instead of subscription-wide

### 2. Secret Management
- Regularly rotate secrets (recommended: every 6 months)
- Use Azure Key Vault for additional secret management if needed
- Monitor secret usage in Azure AD sign-in logs

### 3. Environment Protection
- Consider using GitHub Environments for additional approval workflows
- See [GitHub Environment Setup](./GitHub-Environment-Setup.md) for cleanup approval configuration

## Verification

After setting up all secrets, verify they're correctly configured:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Confirm all four required secrets are listed:
   - ✅ `AZURE_CLIENT_ID`
   - ✅ `AZURE_TENANT_ID`
   - ✅ `AZURE_SUBSCRIPTION_ID`
   - ✅ `SUBNET_ID`

## Troubleshooting

### Common Issues

**Secret not found errors:**
```
Error: The secret 'SUBNET_ID' was not found
```
- **Solution**: Ensure the secret name matches exactly (case-sensitive)

**Authentication failures:**
```
Error: Failed to authenticate with Azure
```
- **Solution**: Verify the Azure authentication secrets are correct
- Check that the service principal has the required permissions

**Invalid subnet ID:**
```
Error: The subnet could not be found
```
- **Solution**: Verify the subnet resource ID is complete and correct
- Ensure the subnet exists in the specified resource group

### Testing Your Setup

You can test your secrets by running a workflow manually:

1. Go to **Actions** tab in your repository
2. Select one of the image builder workflows (e.g., "Linux Build and Distribution")
3. Click **Run workflow**
4. Choose your parameters and run

If the workflow starts successfully and the Azure login step passes, your secrets are configured correctly.

## Related Documentation

- [GitHub Environment Setup](./GitHub-Environment-Setup.md) - Configure approval workflows
- [Main README](../README.md) - Usage examples and workflow parameters
- [Workflows README](../.github/workflows/README.md) - Detailed workflow documentation

## Support

If you encounter issues with secret setup:

1. Check the workflow run logs for specific error messages
2. Verify your Azure permissions using Azure CLI or PowerShell
3. Ensure all resource IDs are valid and accessible from your subscription

---

**Last Updated**: June 11, 2025
**Version**: 1.0
