# Azure VM Image Builder Composite Actions

This directory contains composite GitHub Actions for building and distributing custom VM images using Azure VM Image Builder.

## Available Actions

- `azure-login`: Handles Azure authentication using OIDC.
- `set-version`: Creates version numbers and image template names.
- `prepare-image-template`: Prepares and validates the image template.
- `build-distribute-image`: Builds and distributes the image.
- `validate-cleanup`: Validates the created image and cleans up resources.

## Usage

These actions are designed to be used together with the main workflow in `.github/workflows/template-modular.yaml`.

Each action is a GitHub Actions composite action that follows the standard structure with an `action.yml` file defining its inputs, outputs, and steps.

## Structure

Each action directory contains:

- `action.yml`: The action definition file that specifies inputs, outputs, and steps.

## Benefits

- **Reusability**: Each action can be reused in other workflows.
- **Maintainability**: Easier to maintain and update individual components.
- **Proper GitHub Actions Structure**: Following best practices for composite actions.
