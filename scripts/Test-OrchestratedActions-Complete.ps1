# Test Orchestrated VM Actions
# This script validates the complete orchestrated VM deployment architecture

param(
    [Parameter(Mandatory = $false)]
    [string]$WorkflowPath = ".\.github\workflows",
    
    [Parameter(Mandatory = $false)]
    [string]$ActionsPath = ".\.github\actions"
)

Write-Host "🎯 Testing Orchestrated VM Deployment Architecture" -ForegroundColor Cyan
Write-Host "=" * 60

# Test 1: Verify orchestration actions exist
Write-Host "`n📁 Checking Orchestration Actions..." -ForegroundColor Yellow

$orchestrationActions = @(
    "orchestrate-vm-deployment",
    "orchestrate-vm-cleanup"
)

$missingOrchestrationActions = @()
foreach ($action in $orchestrationActions) {
    $actionPath = Join-Path $ActionsPath $action "action.yml"
    if (Test-Path $actionPath) {
        Write-Host "  ✅ $action" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $action (missing)" -ForegroundColor Red
        $missingOrchestrationActions += $action
    }
}

# Test 2: Verify base composite actions exist
Write-Host "`n📋 Checking Base Composite Actions..." -ForegroundColor Yellow

$baseActions = @(
    "validate-azure-resources",
    "validate-arm-template", 
    "deploy-azure-vm",
    "generate-deployment-report",
    "cleanup-failed-vm-deployment"
)

$missingBaseActions = @()
foreach ($action in $baseActions) {
    $actionPath = Join-Path $ActionsPath $action "action.yml"
    if (Test-Path $actionPath) {
        Write-Host "  ✅ $action" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $action (missing)" -ForegroundColor Red
        $missingBaseActions += $action
    }
}

# Test 3: Verify consolidated orchestrated workflow exists
Write-Host "`n🚀 Checking Consolidated Orchestrated Workflow..." -ForegroundColor Yellow

$consolidatedWorkflow = "deploy-rhel-vm.yml"
$workflowPath = Join-Path $WorkflowPath $consolidatedWorkflow

if (Test-Path $workflowPath) {
    # Check if workflow uses orchestration actions
    $content = Get-Content $workflowPath -Raw
    if ($content -match "orchestrate-vm-deployment" -and $content -match "orchestrate-vm-cleanup") {
        Write-Host "  ✅ $consolidatedWorkflow (uses orchestration)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $consolidatedWorkflow (exists but not orchestrated)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ $consolidatedWorkflow (missing)" -ForegroundColor Red
}

# Verify old workflows are removed
$removedWorkflows = @(
    "deploy-rhel-vm-clean.yml",
    "deploy-vm-modular.yml", 
    "deploy-vm-clean.yml"
)

Write-Host "`n🗑️  Verifying Legacy Workflows Removed..." -ForegroundColor Yellow
foreach ($workflow in $removedWorkflows) {
    $legacyPath = Join-Path $WorkflowPath $workflow
    if (-not (Test-Path $legacyPath)) {
        Write-Host "  ✅ $workflow (properly removed)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $workflow (still exists)" -ForegroundColor Yellow
    }
}

# Test 4: Validate orchestration action structure
Write-Host "`n🔍 Validating Orchestration Action Structure..." -ForegroundColor Yellow

foreach ($action in $orchestrationActions) {
    $actionPath = Join-Path $ActionsPath $action "action.yml"
    if (Test-Path $actionPath) {
        $content = Get-Content $actionPath -Raw
        
        # Check required components
        $hasInputs = $content -match "inputs:"
        $hasOutputs = $content -match "outputs:"
        $hasSteps = $content -match "steps:"
        $hasCompositeRun = $content -match "using:\s*[`'\`"]?composite[`'\`"]?"
        
        if ($hasInputs -and $hasOutputs -and $hasSteps -and $hasCompositeRun) {
            Write-Host "  ✅ $action - Complete structure" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $action - Missing components:" -ForegroundColor Yellow
            if (-not $hasInputs) { Write-Host "    - inputs" -ForegroundColor Red }
            if (-not $hasOutputs) { Write-Host "    - outputs" -ForegroundColor Red }
            if (-not $hasSteps) { Write-Host "    - steps" -ForegroundColor Red }
            if (-not $hasCompositeRun) { Write-Host "    - composite runner" -ForegroundColor Red }
        }
    }
}

# Test 5: Check workflow-to-orchestration integration
Write-Host "`n🔗 Checking Workflow-Orchestration Integration..." -ForegroundColor Yellow

$requiredSecrets = @(
    'AZURE_CLIENT_ID',
    'AZURE_TENANT_ID', 
    'AZURE_SUBSCRIPTION_ID',
    'AZURE_RESOURCE_GROUP',
    'VM_ADMIN_USERNAME',
    'VM_ADMIN_PASSWORD',
    'KEYVAULT_ID',
    'CERTIFICATE_URL',
    'SUBNET_ID'
)

foreach ($workflow in $cleanWorkflows) {
    $workflowPath = Join-Path $WorkflowPath $workflow
    if (Test-Path $workflowPath) {
        $content = Get-Content $workflowPath -Raw
        
        $secretsUsed = @()
        foreach ($secret in $requiredSecrets) {
            if ($content -match "\$\{\{\s*secrets\.$secret\s*\}\}") {
                $secretsUsed += $secret
            }
        }
        
        Write-Host "  📋 $workflow uses $($secretsUsed.Count)/$($requiredSecrets.Count) required secrets" -ForegroundColor Cyan
        
        # Check for OIDC authentication
        if ($content -match "azure/login@v2" -and $content -match "client-id.*AZURE_CLIENT_ID") {
            Write-Host "    ✅ Uses OIDC authentication" -ForegroundColor Green
        } else {
            Write-Host "    ⚠️  Authentication method unclear" -ForegroundColor Yellow
        }
    }
}

# Test 6: Architecture completeness
Write-Host "`n📊 Architecture Completeness Report..." -ForegroundColor Yellow

$totalIssues = $missingOrchestrationActions.Count + $missingBaseActions.Count + $missingCleanWorkflows.Count

Write-Host "  📈 Orchestration Actions: $($orchestrationActions.Count - $missingOrchestrationActions.Count)/$($orchestrationActions.Count)" -ForegroundColor Cyan
Write-Host "  📈 Base Composite Actions: $($baseActions.Count - $missingBaseActions.Count)/$($baseActions.Count)" -ForegroundColor Cyan
Write-Host "  📈 Clean Workflows: $($cleanWorkflows.Count - $missingCleanWorkflows.Count)/$($cleanWorkflows.Count)" -ForegroundColor Cyan

if ($totalIssues -eq 0) {
    Write-Host "`n🎉 Orchestrated VM Deployment Architecture is Complete!" -ForegroundColor Green
    Write-Host "   Ready for production deployments." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Found $totalIssues issues in the architecture." -ForegroundColor Yellow
    Write-Host "   Review missing components above." -ForegroundColor Yellow
}

# Test 7: Generate architecture summary
Write-Host "`n📋 Architecture Summary..." -ForegroundColor Yellow
Write-Host "   🏗️  Orchestration Layer: Master composite actions" -ForegroundColor Cyan
Write-Host "   🔧 Base Actions Layer: Individual deployment components" -ForegroundColor Cyan  
Write-Host "   🚀 Workflow Layer: Clean trigger files" -ForegroundColor Cyan
Write-Host "   🔐 Authentication: OIDC with individual secrets" -ForegroundColor Cyan
Write-Host "   🧪 Testing: Built-in validation and cleanup" -ForegroundColor Cyan

Write-Host "`n✅ Orchestrated Actions Test Complete!" -ForegroundColor Green
