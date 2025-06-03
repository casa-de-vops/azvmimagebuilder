# GitHub Environment Setup for VM Image Builder

This document explains how to set up the GitHub environment protection rule for the cleanup approval process.

## Overview

The VM Image Builder workflow has been updated to separate validation and cleanup into different jobs:

1. **VALIDATE-IMAGE** - Deploys and validates the VM image
2. **CLEANUP-RESOURCES** - Cleans up validation resources (requires manual approval)

## Setting Up the Cleanup Approval Environment

To enable manual approval for resource cleanup, you need to create a GitHub environment with protection rules.

### Steps:

1. **Navigate to your repository settings**
   - Go to your GitHub repository
   - Click on **Settings** tab
   - Select **Environments** from the left sidebar

2. **Create the cleanup-approval environment**
   - Click **New environment**
   - Name it: `cleanup-approval`
   - Click **Configure environment**

3. **Configure protection rules**
   - ✅ **Required reviewers**: Add yourself and/or team members who should approve cleanup
   - ✅ **Wait timer**: Set to 0 minutes (optional - you can add a delay if needed)
   - ⚠️ **Deployment branches**: Configure as needed for your branch protection strategy

4. **Save the environment**

## How the Approval Process Works

### Workflow Execution:
1. **Build Phase** (if `skipBuild: false`):
   - Prepares image template
   - Builds and distributes the image

2. **Validation Phase**:
   - Deploys a validation VM using the custom image
   - Runs basic validation tests
   - Outputs VM details for cleanup job

3. **Manual Testing Window**:
   - VM is deployed and ready for manual testing
   - You can connect to the VM to verify customizations
   - Workflow pauses and waits for approval

4. **Cleanup Approval**:
   - GitHub creates a deployment request for the `cleanup-approval` environment
   - Designated approvers receive notifications
   - Approvers can review the validation results before approving cleanup

5. **Cleanup Phase** (after approval):
   - Deletes the validation VM
   - Removes associated network interfaces, public IPs, and disks
   - Optionally deletes the resource group and image template

### Benefits:

- ✅ **Controlled cleanup**: Resources are only deleted after explicit approval
- ✅ **Manual testing window**: Time to manually verify the image before cleanup
- ✅ **Audit trail**: All approvals are tracked in GitHub
- ✅ **Safety**: Prevents accidental deletion of validation resources
- ✅ **Flexibility**: Can approve or deny cleanup based on validation results

## Environment Variables in Cleanup Job

The cleanup job receives the following information from the validation job:

- `vm-name`: Name of the deployed validation VM
- `resource-group`: Resource group containing the validation VM  
- `image-id`: ID of the validated image

This ensures the cleanup job knows exactly which resources to remove.

## Workflow Behavior

### With `skipBuild: false` (default):
```
Build → Validate → [Manual Approval] → Cleanup
```

### With `skipBuild: true`:
```
Validate Latest Image → [Manual Approval] → Cleanup
```

### Approval Scenarios:

- **Approve**: Resources are cleaned up automatically
- **Deny**: Workflow stops, resources remain for further investigation
- **Timeout**: Resources remain (if you configure a wait timer in the environment)

## Troubleshooting

### Environment not found error:
```
Error: The environment 'cleanup-approval' does not exist
```
**Solution**: Create the environment in repository settings as described above.

### No approval required:
**Solution**: Ensure the environment has "Required reviewers" configured.

### Cannot approve own deployment:
**Solution**: Add another team member as a required reviewer, or use a different GitHub account.

## Security Considerations

- Only users with appropriate repository permissions can approve deployments
- Consider using teams instead of individual users for approvals
- Review who has access to approve deployments in your organization
- The cleanup job still requires Azure credentials to delete resources

## Example Usage

To use the updated workflow:

```yaml
uses: ./.github/workflows/template-modular.yaml
with:
  templateFolder: "templates/windows"
  templateName: "windows-base"
  sigResourceGroup: "rg-sig-images"
  # ... other parameters
  skipBuild: false  # Set to true to only validate existing image
```

The workflow will automatically pause for approval before cleanup, regardless of the `skipBuild` setting.
