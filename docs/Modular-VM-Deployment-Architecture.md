# Modular VM Deployment Architecture

This document describes the modular deployment architecture implemented for Azure VM deployments in this repository.

## Overview

The VM deployment workflows have been templatized into reusable composite actions to improve maintainability, consistency, and reusability across different deployment scenarios.

## Composite Actions

### 1. **validate-azure-resources** (`.github/actions/validate-azure-resources/`)
**Purpose**: Validates that required Azure resources exist before VM deployment

**Inputs**:
- `resource-group`: Target resource group name
- `subnet-id`: Subnet resource ID for VM deployment
- `keyvault-id`: Key Vault resource ID (required for Linux VMs)
- `vm-type`: VM type (linux or windows)

**What it does**:
- Validates resource group exists
- Validates subnet exists and is accessible
- Validates Key Vault exists (Linux VMs only)

### 2. **validate-arm-template** (`.github/actions/validate-arm-template/`)
**Purpose**: Validates ARM template and shows deployment preview

**Inputs**:
- `template-path`: Path to ARM template file
- `resource-group`: Target resource group
- `deployment-name`: Name for the deployment
- VM configuration parameters (name, type, size, etc.)
- Authentication parameters (username, password, certificates)

**What it does**:
- Validates ARM template syntax and parameters
- Runs `az deployment group validate`
- Shows `what-if` analysis of planned changes

### 3. **deploy-azure-vm** (`.github/actions/deploy-azure-vm/`)
**Purpose**: Deploys Azure VM using ARM template

**Inputs**:
- Template and deployment configuration
- VM specifications and networking
- Authentication credentials

**Outputs**:
- `vm-resource-id`: Resource ID of deployed VM
- `vm-name`: Name of deployed VM
- `private-ip`: Private IP address
- `network-interface-id`: Network interface resource ID

**What it does**:
- Deploys VM using conditional logic for Linux/Windows
- Uses `azure/arm-deploy@v2` action
- Extracts and returns deployment outputs

### 4. **generate-deployment-report** (`.github/actions/generate-deployment-report/`)
**Purpose**: Generates comprehensive deployment report

**Inputs**:
- Environment and VM configuration details
- Deployment outputs from previous step

**What it does**:
- Creates detailed GitHub Step Summary
- Shows deployment details and outputs
- Provides next steps based on VM type
- Includes platform-specific guidance

### 5. **cleanup-failed-vm-deployment** (`.github/actions/cleanup-failed-vm-deployment/`)
**Purpose**: Cleans up resources when deployment fails

**Inputs**:
- `resource-group`: Target resource group
- `vm-name`: Name of VM to clean up
- `vm-type`: VM type for cleanup logic

**What it does**:
- Deletes failed VM resources
- Removes associated network interfaces
- Cleans up Network Security Groups (Windows VMs)
- Runs cleanup operations asynchronously

## Workflows Using Modular Actions

### 1. **deploy-rhel-vm.yml** - RHEL-Specific Deployment
- **Triggers**: Manual, workflow_run, scheduled (weekly)
- **Features**:
  - RHEL-specific naming conventions
  - Post-deployment RHEL configuration guidance
  - Integration testing capabilities
  - Conditional deployment based on upstream workflow success

### 2. **deploy-vm-modular.yml** - General VM Deployment
- **Triggers**: Manual workflow dispatch
- **Features**:
  - Support for Linux/Windows VMs
  - Multiple image options (GoldenLinuxImage, GoldenRHELImage, GoldenWindowsImage)
  - Flexible VM sizing options
  - Auto-shutdown configuration for Windows VMs

### 3. **deploy-vm.yml** - Legacy Workflow
- **Status**: Legacy implementation without modular actions
- **Recommendation**: Migrate to `deploy-vm-modular.yml` for better maintainability

## Authentication Methods

The workflows now support **OpenID Connect (OIDC)** authentication instead of service principal JSON:

### Required Secrets:
```
AZURE_CLIENT_ID          # Application (client) ID
AZURE_TENANT_ID          # Directory (tenant) ID  
AZURE_SUBSCRIPTION_ID    # Azure subscription ID
```

### Login Pattern:
```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Benefits of Modular Architecture

1. **Reusability**: Actions can be used across multiple workflows
2. **Consistency**: Same validation and deployment logic everywhere
3. **Maintainability**: Changes in one place update all workflows
4. **Testing**: Individual actions can be tested independently
5. **Error Handling**: Centralized cleanup and error handling
6. **Documentation**: Self-documenting action interfaces

## Usage Example

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Azure Login
      uses: azure/login@v2
      with:
        client-id: ${{ secrets.AZURE_CLIENT_ID }}
        tenant-id: ${{ secrets.AZURE_TENANT_ID }}
        subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    
    - name: Validate Resources
      uses: ./.github/actions/validate-azure-resources
      with:
        resource-group: ${{ secrets.AZURE_RESOURCE_GROUP }}
        subnet-id: ${{ secrets.SUBNET_ID }}
        vm-type: 'linux'
    
    - name: Deploy VM
      uses: ./.github/actions/deploy-azure-vm
      with:
        template-path: './templates/azuredeploy.linux.json'
        vm-name: 'my-vm'
        # ... other parameters
```

## Future Enhancements

1. **Additional Workflows**: Create specific workflows for Windows and Linux golden images
2. **Enhanced Testing**: Add more comprehensive integration tests
3. **Multi-Region**: Support for cross-region deployments
4. **Cost Optimization**: Add cost estimation and optimization features
5. **Monitoring**: Integrate with Azure Monitor and alerting

## Migration Guide

To migrate existing workflows to use modular actions:

1. Replace manual Azure CLI commands with composite action calls
2. Update authentication to use OIDC instead of service principal JSON
3. Standardize input/output patterns across workflows
4. Add proper error handling and cleanup logic
5. Update documentation and repository secrets
