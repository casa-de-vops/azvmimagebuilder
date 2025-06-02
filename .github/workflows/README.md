# Azure VM Image Builder Workflow

This directory contains a modular GitHub Actions workflow for building and distributing custom VM images using Azure VM Image Builder.

## Structure

The workflow is organized into the following components:

### Main Workflow File

- `template-modular.yaml`: The main orchestration file that calls the individual composite actions.

### Composite Actions

Located in the `.github/actions/` directory:

- `azure-login`: Handles Azure authentication using OIDC.
- `set-version`: Creates version numbers and image template names.
- `prepare-image-template`: Prepares and validates the image template.
- `build-distribute-image`: Builds and distributes the image.
- `validate-cleanup`: Validates the created image and cleans up resources.

### Utility Scripts

- `validate-aib-template.sh`: Bash script for validating image templates.

## Usage

To use this workflow, call it from your own workflow file:

```yaml
jobs:
  run-image-builder:
    name: Build and distribute custom VM image
    uses: ./.github/workflows/template-modular.yaml
    with:
      templateFolder: "Your_Template_Folder"
      templateName: "Your_Template_Name.json"
      templateType: "armTemplate" # or "imageTemplate"
      sigResourceGroup: "your-resource-group"
      imageDefName: "your-image-definition"
      sigName: "your-shared-image-gallery"
      uaiIdentityName: "your-user-assigned-identity"
      location: "your-location"
      additionalregion: "your-additional-region" # optional
      runOutputName: "your-run-output-name"
      buildRGName: "your-build-resource-group" # optional
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Workflow Phases

1. **PREPARE-IMAGE-TEMPLATE**: Prepares and validates the image template.
2. **BUILD-DISTRIBUTE-IMAGE**: Builds and distributes the image.
3. **VALIDATE-AND-CLEANUP**: Validates the created image and cleans up resources.

## Benefits of Modular Design

- **Reusability**: Each step can be reused in other workflows.
- **Maintainability**: Easier to maintain and update individual components.
- **Readability**: Cleaner, more organized code structure.
- **Testability**: Individual components can be tested separately.
