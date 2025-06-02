# Legacy Template (Deprecated)

This file contains the original monolithic workflow for Azure VM Image Builder. It has been replaced by the more modular `template-modular.yaml` workflow, which uses proper GitHub Actions composite actions located in the `.github/actions/` directory.

## Migration

If you are using this template directly, please update your workflows to use the new `template-modular.yaml` workflow instead. The inputs and secrets remain the same, so migration should be straightforward:

```yaml
jobs:
  run-image-builder:
    name: Build and distribute custom VM image
    uses: ./.github/workflows/template-modular.yaml  # Use this instead of template.yaml
    with:
      # Same inputs as before
      templateFolder: "Your_Template_Folder"
      templateName: "Your_Template_Name.json"
      # ... other inputs
    secrets:
      # Same secrets as before
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      # ... other secrets
```

## Benefits of the Modular Approach

The new modular approach provides several benefits:
- Better maintainability through smaller, focused components
- Improved reusability of individual actions
- Proper GitHub Actions composite action structure
- Enhanced validation capabilities
- Cleaner error handling and reporting
