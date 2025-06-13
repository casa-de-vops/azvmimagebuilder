# Test Modular Actions
# This script validates that the modular composite actions are properly configured

param(
    [Parameter(Mandatory = $false)]
    [string]$WorkflowPath = ".\.github\workflows",
    
    [Parameter(Mandatory = $false)]
    [string]$ActionsPath = ".\.github\actions"
)

Write-Host "🧪 Testing Modular VM Deployment Actions" -ForegroundColor Cyan
Write-Host "=" * 50

# Test 1: Verify composite actions exist
Write-Host "`n📁 Checking Composite Actions..." -ForegroundColor Yellow

$expectedActions = @(
    "validate-azure-resources",
    "validate-arm-template", 
    "deploy-azure-vm",
    "generate-deployment-report",
    "cleanup-failed-vm-deployment"
)

$missingActions = @()
foreach ($action in $expectedActions) {
    $actionPath = Join-Path $ActionsPath $action "action.yml"
    if (Test-Path $actionPath) {
        Write-Host "  ✅ $action" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $action (missing)" -ForegroundColor Red
        $missingActions += $action
    }
}

# Test 2: Verify action.yml files are valid YAML
Write-Host "`n📋 Validating Action YAML Files..." -ForegroundColor Yellow

foreach ($action in $expectedActions) {
    $actionPath = Join-Path $ActionsPath $action "action.yml"
    if (Test-Path $actionPath) {
        try {
            # Basic YAML validation - check if file can be read and has expected structure
            $content = Get-Content $actionPath -Raw
            if ($content -match "name:\s*'.*'" -and $content -match "runs:") {
                Write-Host "  ✅ $action - Valid YAML structure" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  $action - Missing required YAML elements" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "  ❌ $action - Invalid YAML: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Test 3: Check workflow files
Write-Host "`n🔄 Checking Workflow Files..." -ForegroundColor Yellow

$workflowFiles = @(
    "deploy-rhel-vm.yml",
    "deploy-vm-modular.yml"
)

foreach ($workflow in $workflowFiles) {
    $workflowFullPath = Join-Path $WorkflowPath $workflow
    if (Test-Path $workflowFullPath) {
        Write-Host "  ✅ $workflow" -ForegroundColor Green
        
        # Check if workflow uses modular actions
        $content = Get-Content $workflowFullPath -Raw
        $usedActions = 0        foreach ($action in $expectedActions) {
            if ($content -match "uses:\s*\./\.github/actions/$action") {
                $usedActions++
            }
        }
        Write-Host "    📊 Uses $usedActions/$($expectedActions.Count) modular actions" -ForegroundColor Cyan
    } else {
        Write-Host "  ❌ $workflow (missing)" -ForegroundColor Red
    }
}

# Test 4: Check authentication method
Write-Host "`n🔐 Checking Authentication Method..." -ForegroundColor Yellow

foreach ($workflow in $workflowFiles) {
    $workflowFullPath = Join-Path $WorkflowPath $workflow
    if (Test-Path $workflowFullPath) {
        $content = Get-Content $workflowFullPath -Raw
        
        if ($content -match "azure/login@v2") {
            Write-Host "  ✅ $workflow - Using azure/login@v2" -ForegroundColor Green
        } elseif ($content -match "azure/login@v1") {
            Write-Host "  ⚠️  $workflow - Using azure/login@v1 (consider updating)" -ForegroundColor Yellow
        }
        
        if ($content -match "client-id.*AZURE_CLIENT_ID" -and $content -match "tenant-id.*AZURE_TENANT_ID") {
            Write-Host "  ✅ $workflow - Using OIDC authentication" -ForegroundColor Green
        } elseif ($content -match "creds.*AZURE_CREDENTIALS") {
            Write-Host "  ⚠️  $workflow - Using service principal JSON (deprecated)" -ForegroundColor Yellow
        } else {
            Write-Host "  ❌ $workflow - Unknown authentication method" -ForegroundColor Red
        }
    }
}

# Test 5: Check for required inputs/outputs
Write-Host "`n📥 Checking Action Inputs/Outputs..." -ForegroundColor Yellow

$actionRequirements = @{
    "validate-azure-resources" = @("resource-group", "subnet-id", "vm-type")
    "validate-arm-template" = @("template-path", "resource-group", "deployment-name")
    "deploy-azure-vm" = @("template-path", "vm-name", "vm-type")
    "generate-deployment-report" = @("environment", "vm-type", "vm-name")
    "cleanup-failed-vm-deployment" = @("resource-group", "vm-name", "vm-type")
}

foreach ($action in $expectedActions) {
    $actionPath = Join-Path $ActionsPath $action "action.yml"
    if (Test-Path $actionPath) {
        $content = Get-Content $actionPath -Raw
        $requiredInputs = $actionRequirements[$action]
        $foundInputs = 0
          foreach ($input in $requiredInputs) {
            if ($content -match "${input}:") {
                $foundInputs++
            }
        }
        
        if ($foundInputs -eq $requiredInputs.Count) {
            Write-Host "  ✅ $action - All required inputs present ($foundInputs/$($requiredInputs.Count))" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $action - Missing some inputs ($foundInputs/$($requiredInputs.Count))" -ForegroundColor Yellow
        }
    }
}

# Summary
Write-Host "`n📊 Summary" -ForegroundColor Cyan
Write-Host "=" * 50

if ($missingActions.Count -eq 0) {
    Write-Host "✅ All composite actions are present" -ForegroundColor Green
} else {
    Write-Host "❌ Missing actions: $($missingActions -join ', ')" -ForegroundColor Red
}

Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Review any warnings or errors above"
Write-Host "2. Test workflows in a development environment" 
Write-Host "3. Update repository secrets for OIDC authentication"
Write-Host "4. Consider migrating legacy deploy-vm.yml to modular approach"

Write-Host "`n🔗 Documentation:" -ForegroundColor Cyan
Write-Host "- Modular Architecture: docs/Modular-VM-Deployment-Architecture.md"
Write-Host "- Repository Secrets: docs/Repository-Secrets-Setup.md"
Write-Host "- Deployment Guide: DEPLOYMENT-GUIDE.md"
