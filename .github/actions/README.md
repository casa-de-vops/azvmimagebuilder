# Azure VM Image Builder Composite Actions

This directory contains composite GitHub Actions for building and distributing custom VM images using Azure VM Image Builder (AIB). These actions provide a modular approach to image building workflows, making them more maintainable and reusable.

## Available Actions

### Core Actions

- **`azure-login`**: Handles Azure authentication using OpenID Connect (OIDC)
  - Authenticates to Azure using client ID, tenant ID, and subscription ID
  - Enables Azure PowerShell session for subsequent steps

- **`set-version`**: Creates version numbers and image template names
  - Generates release version based on GitHub run number and commit SHA
  - Creates unique image template names for tracking builds

- **`prepare-image-template`**: Prepares and validates the Azure Image Builder template
  - Validates template syntax and configuration
  - Prepares the template for deployment with proper parameters
  - Supports both ARM templates and Image Builder templates

- **`build-distribute-image`**: Builds and distributes the custom VM image
  - Initiates the Azure Image Builder process
  - Monitors build progress and handles both template types
  - Distributes images to specified regions

### Validation Actions

- **`validate-vm`**: Validates the created image by deploying a test VM
  - Deploys a validation VM using the newly created image
  - Performs connectivity and functionality tests
  - Supports both Linux and Windows VM validation
  - Creates Key Vault for secure credential management

- **`cleanup-vm`**: Cleans up validation resources after testing
  - Removes validation VMs and associated resources
  - Cleans up network interfaces, disks, and other components
  - Optionally preserves build resource groups
  - Handles cleanup failures gracefully

### Legacy/Incomplete Actions

- **`validate-cleanup`**: ⚠️ *Currently empty - placeholder for future development*

## Usage

These actions are designed to be used together in a complete image building workflow. The recommended usage pattern is through the main workflow template:

```yaml
jobs:
  build-custom-image:
    name: Build and distribute custom VM image
    uses: ./.github/workflows/template.yaml
    with:
      templateFolder: "Your_Template_Folder"      templateName: "Your_Template.json"
      templateType: "imageTemplate"  # or "armTemplate"
      sigResourceGroup: "your-rg"
      imageDefName: "your-image-definition"
      sigName: "your-image-gallery"
      uaiIdentityName: "your-managed-identity"
      location: "westus2"
      additionalregion: "eastus2"
      runOutputName: "your-image-name"
      vm-os-type: "Linux"  # or "Windows"
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      SUBNET_ID: ${{ secrets.SUBNET_ID }}
```

## Action Dependencies

The actions follow a logical workflow sequence:

1. **`azure-login`** → Authenticates to Azure
2. **`set-version`** → Creates version identifiers
3. **`prepare-image-template`** → Validates and prepares the template
4. **`build-distribute-image`** → Builds and distributes the image
5. **`validate-vm`** → Tests the created image
6. **`cleanup-vm`** → Cleans up validation resources

## Structure

Each action directory contains:

- **`action.yml`**: The action definition file that specifies inputs, outputs, and steps
- Action-specific scripts and configurations as needed

## Benefits

- **Modularity**: Each action handles a specific aspect of the image building process
- **Reusability**: Actions can be reused across different workflows and projects
- **Maintainability**: Easier to maintain and update individual components
- **Error Handling**: Proper error handling and logging at each step
- **Flexibility**: Support for both ARM templates and Image Builder templates
- **Validation**: Built-in image validation through VM deployment testing
