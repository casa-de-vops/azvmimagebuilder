# Azure VM Image Builder

This repository provides comprehensive workflows, templates, and examples for building and distributing custom VM images using Azure VM Image Builder (AIB). It includes modular GitHub Actions workflows, template examples, and best practices for image building automation.

## Repository Structure

### GitHub Workflows (`.github/`)
- **`template.yaml`**: Main reusable workflow for building and distributing custom VM images
- **`GoldenLinuxImage.yml`**: Example workflow for building Linux golden images
- **`GoldenWindowsImage.yml`**: Example workflow for building Windows golden images
- **`actions/`**: Modular composite actions for image building components

### Templates (`templates/`)
Comprehensive collection of Azure Image Builder templates organized by use case:
- **Linux templates**: Custom Linux image creation examples
- **Windows templates**: Custom Windows image creation examples  
- **Shared Image Gallery**: Templates for publishing to Azure Compute Gallery
- **VNET integration**: Examples with custom networking configurations
- **Specialized scenarios**: Red Hat licensing, VHD exports, and more

### Solutions (`solutions/`)
End-to-end solutions and integration examples:
- Azure DevOps integration
- Security role configurations
- Windows Virtual Desktop (WVD) optimizations
- Environment variable usage patterns

### Infrastructure as Code (`terraform/`)
Terraform configurations for setting up Azure Image Builder infrastructure and dependencies.

## Quick Start

### 1. Setup Prerequisites
- Azure subscription with appropriate permissions
- GitHub repository with OIDC authentication configured
- User-assigned managed identity for Azure Image Builder

📋 **Important**: Before using the workflows, you must configure required repository secrets. See the [Repository Secrets Setup Guide](./docs/Repository-Secrets-Setup.md) for detailed instructions.

### 2. Use the Template Workflow
Add this to your workflow file (e.g., `.github/workflows/build-image.yml`):

```yaml
name: Build Custom VM Image

on:
  workflow_dispatch:
    inputs:
      skipBuild:
        description: "Skip building new image and validate latest"
        type: boolean
        required: false
        default: false

permissions:
  contents: read
  id-token: write

jobs:
  build-image:
    name: Build and distribute custom VM image
    uses: ./.github/workflows/template.yaml
    with:
      templateFolder: "1_Creating_a_Custom_Linux_Shared_Image_Gallery_Image"
      templateName: "GoldenLinuxImage.json"
      templateType: "imageTemplate"
      sigResourceGroup: "rg-imagebuilder"
      sigName: "myImageGallery"
      imageDefName: "myLinuxImage"
      uaiIdentityName: "imagebuilder-identity"
      location: "westus2"
      additionalregion: "eastus2"
      runOutputName: "myCustomImage"
      vm-os-type: "Linux"
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      SUBNET_ID: ${{ secrets.SUBNET_ID }}
```

### 3. Customize Your Template
Choose from the available templates in the `templates/` directory or create your own based on the examples.

## Features

### 🔧 Modular Architecture
- Reusable composite GitHub Actions
- Clean separation of concerns
- Easy to maintain and extend

### 🚀 Comprehensive Automation
- Image building and distribution
- Multi-region replication
- Automated validation testing
- Resource cleanup

### 🔐 Security Best Practices
- OIDC authentication
- Managed identity integration
- Secure credential management
- Network isolation support

### 📊 Monitoring & Validation
- Build progress monitoring
- Automated VM deployment testing
- Detailed logging and reporting
- Error handling and cleanup

## Template Types Supported

- **Image Builder Templates**: Native AIB JSON templates
- **ARM Templates**: Azure Resource Manager templates for image building

## Documentation

For detailed documentation, see:
- [GitHub Actions Documentation](.github/workflows/template.yaml.md)
- [Actions Reference](.github/actions/README.md)
- [Template Examples](templates/readme.md)

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
