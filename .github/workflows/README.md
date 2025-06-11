# Azure VM Image Builder Template Workflow

This repository provides a comprehensive workflow template for building and distributing custom VM images using Azure VM Image Builder (AIB). The workflow has been designed with modularity and maintainability in mind.

## Current Architecture

The workflow system consists of:

### Main Template Workflow (`template.yaml`)
The primary reusable workflow that orchestrates the entire image building process. This workflow:
- Accepts comprehensive input parameters for image configuration
- Coordinates multiple composite actions to build and validate images
- Supports both ARM templates and Image Builder templates
- Provides built-in validation through VM deployment testing

### Composite Actions (`.github/actions/`)
Modular, reusable actions that handle specific aspects of the image building process:
- **Azure authentication and setup**
- **Version management and template preparation** 
- **Image building and distribution**
- **Validation through test VM deployment**
- **Resource cleanup and management**

## Usage

To use this template in your workflows:

```yaml
jobs:
  run-image-builder:
    name: Build and distribute custom VM image
    uses: ./.github/workflows/template.yaml  # Use the main template workflow
    with:
      # === Template Configuration ===
      templateFolder: "Your_Template_Folder"           # Folder containing your AIB template
      templateName: "Your_Template.json"               # Your AIB template file
      templateType: "imageTemplate"                    # armTemplate or imageTemplate
      
      # === Azure Resource Configuration ===
      sigResourceGroup: "rg-your-imagebuilder"         # Resource group for Shared Image Gallery
      buildRGName: "rg-your-build"                     # Resource group for build process
      uaiIdentityName: "your-managed-identity"         # User-assigned managed identity
      
      # === Gallery Configuration ===
      sigName: "yourImageGallery"                      # Shared Image Gallery name
      imageDefName: "YourImageDefinition"              # Image definition name
      runOutputName: "YourImageName"                   # Base name for image outputs
      
      # === Location Configuration ===
      location: "westus2"                              # Primary region
      additionalregion: "eastus2"                      # Additional replication region
      
      # === Validation Configuration ===
      subnet-id: "/subscriptions/.../subnets/your-subnet"  # Subnet for validation VM
      vm-os-type: "Linux"                              # Linux or Windows
      
      # === Build Configuration ===
      skipBuild: false                                 # Set to true to skip build and only validate
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Features

### Comprehensive Image Building
- Support for both ARM templates and native Image Builder templates
- Automatic template validation and preparation
- Multi-region image distribution
- Version management with GitHub run numbers and commit SHAs

### Built-in Validation
- Automatic deployment of test VMs using the created image
- Connectivity and functionality testing
- Support for both Linux and Windows validation
- Secure credential management through Key Vault

### Resource Management
- Automatic cleanup of validation resources
- Preservation of important build artifacts
- Graceful error handling during cleanup
- Optional resource group management

### Security
- OIDC-based authentication to Azure
- User-assigned managed identity support
- Secure secret management
- Network isolation support through custom subnets

## Prerequisites

### Required Repository Secrets
Before using these workflows, you must configure the following repository secrets:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Azure AD application client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |
| `SUBNET_ID` | Full resource ID of subnet for validation VMs |

📋 **Setup Guide**: See [Repository Secrets Setup](../../docs/Repository-Secrets-Setup.md) for detailed configuration instructions.

## Benefits of the Modular Approach

### Maintainability
- **Smaller, focused components**: Each action handles a specific responsibility
- **Easier debugging**: Issues can be isolated to specific actions
- **Simplified updates**: Changes can be made to individual components without affecting the entire workflow

### Reusability
- **Cross-project usage**: Actions can be reused in different repositories
- **Flexible composition**: Actions can be combined in different ways for various scenarios
- **Standardization**: Consistent patterns across all image building workflows

### Enhanced Capabilities
- **Better error handling**: Each action can implement specific error handling strategies
- **Improved logging**: Detailed logging at each step of the process
- **Validation at each step**: Template validation, build monitoring, and image testing
- **Conditional execution**: Support for skipping builds and validation-only runs

## Template Types Supported

- **`imageTemplate`**: Native Azure Image Builder JSON templates
- **`armTemplate`**: Azure Resource Manager templates for image building

Both template types support the same workflow features and validation capabilities.
