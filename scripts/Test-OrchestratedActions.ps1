# Test Orchestrated VM Deployment Actions
# This script validates the new orchestrated composite action architecture

param(
    [Parameter(Mandatory = $false)]
    [string]$WorkflowPath = ".\.github\workflows",
    
    [Parameter(Mandatory = $false)]
    [string]$ActionsPath = ".\.github\actions"
)

Write-Host "🎭 Testing Orchestrated VM Deployment Architecture" -ForegroundColor Cyan
Write-Host "=" * 60

# Test 1: Verify orchestration actions exist
Write-Host "`n📁 Checking Orchestration Actions..." -ForegroundColor Yellow

$orchestrationActions = @(
    "orchestrate-vm-deployment",
    "orchestrate-vm-cleanup"
)

$baseActions = @(
    "validate-azure-resources",
    "validate-arm-template", 
    "deploy-azure-vm",
    "generate-deployment-report",
    "cleanup-failed-vm-deployment"
)

$allActions = $orchestrationActions + $baseActions

$missingActions = @()
foreach ($action in $allActions) {
    $actionPath = Join-Path $ActionsPath $action "action.yml"
    if (Test-Path $actionPath) {
        if ($orchestrationActions -contains $action) {
            Write-Host "  🎭 $action (Orchestrator)" -ForegroundColor Magenta
        } else {
            Write-Host "  ⚙️  $action (Base Action)" -ForegroundColor Green
        }
    } else {
        Write-Host "  ❌ $action (missing)" -ForegroundColor Red
        $missingActions += $action
    }
}

# Test 2: Verify orchestrated workflow files
Write-Host "`n🔄 Checking Orchestrated Workflow Files..." -ForegroundColor Yellow

$orchestratedWorkflows = @(
    "deploy-rhel-vm-clean.yml",
    "deploy-vm-clean.yml"
)

$legacyWorkflows = @(
    "deploy-rhel-vm.yml",
    "deploy-vm-modular.yml"
)

Write-Host "  📋 Orchestrated Workflows:" -ForegroundColor Cyan
foreach ($workflow in $orchestratedWorkflows) {
    $workflowPath = Join-Path $WorkflowPath $workflow
    if (Test-Path $workflowPath) {
        Write-Host "    ✅ $workflow" -ForegroundColor Green
        
        # Check if workflow uses orchestration action
        $content = Get-Content $workflowPath -Raw
        if ($content -match "uses:\s*\.\./\.github/actions/orchestrate-vm-deployment") {
            Write-Host "      🎭 Uses VM deployment orchestrator" -ForegroundColor Magenta
        }
        if ($content -match "uses:\s*\.\./\.github/actions/orchestrate-vm-cleanup") {
            Write-Host "      🧹 Uses VM cleanup orchestrator" -ForegroundColor Magenta
        }
    } else {
        Write-Host "    ❌ $workflow (missing)" -ForegroundColor Red
    }
}

Write-Host "  📋 Legacy Workflows:" -ForegroundColor Yellow
foreach ($workflow in $legacyWorkflows) {
    $workflowPath = Join-Path $WorkflowPath $workflow
    if (Test-Path $workflowPath) {
        Write-Host "    ⚠️  $workflow (legacy)" -ForegroundColor Yellow
    } else {
        Write-Host "    ➖ $workflow (not present)" -ForegroundColor Gray
    }
}

# Test 3: Check orchestration action structure
Write-Host "`n🎯 Analyzing Orchestration Action Structure..." -ForegroundColor Yellow

$orchestratorPath = Join-Path $ActionsPath "orchestrate-vm-deployment" "action.yml"
if (Test-Path $orchestratorPath) {
    $content = Get-Content $orchestratorPath -Raw
    
    # Count orchestration steps
    $stepCount = ($content | Select-String -Pattern "- name:" -AllMatches).Matches.Count
    Write-Host "  📊 Orchestration Steps: $stepCount" -ForegroundColor Cyan
    
    # Check for key orchestration features
    $features = @()
    if ($content -match "validate-azure-resources") { $features += "Resource Validation" }
    if ($content -match "validate-arm-template") { $features += "Template Validation" }
    if ($content -match "deploy-azure-vm") { $features += "VM Deployment" }
    if ($content -match "generate-deployment-report") { $features += "Reporting" }
    if ($content -match "enable-rhel-features") { $features += "RHEL Features" }
    if ($content -match "enable-testing") { $features += "Testing" }
    
    Write-Host "  🎭 Orchestrated Features:" -ForegroundColor Magenta
    foreach ($feature in $features) {
        Write-Host "    ✅ $feature" -ForegroundColor Green
    }
    
    # Check input/output complexity
    $inputCount = ($content | Select-String -Pattern "^\s*[a-zA-Z-]+:" -AllMatches).Matches.Count
    Write-Host "  📥 Input Parameters: $inputCount" -ForegroundColor Cyan
} else {
    Write-Host "  ❌ Main orchestrator action not found" -ForegroundColor Red
}

# Test 4: Check workflow simplification
Write-Host "`n📏 Measuring Workflow Simplification..." -ForegroundColor Yellow

foreach ($workflow in $orchestratedWorkflows) {
    $workflowPath = Join-Path $WorkflowPath $workflow
    if (Test-Path $workflowPath) {
        $content = Get-Content $workflowPath -Raw
        
        # Count jobs and steps
        $jobCount = ($content | Select-String -Pattern "^\s*[a-zA-Z-]+:" -AllMatches | Where-Object { $_.Line -notmatch "^\s*-" }).Matches.Count - 5  # Subtract YAML metadata
        $stepCount = ($content | Select-String -Pattern "^\s*- name:" -AllMatches).Matches.Count
        
        Write-Host "  📋 $workflow" -ForegroundColor Cyan
        Write-Host "    🔧 Jobs: $jobCount" -ForegroundColor Green
        Write-Host "    ⚙️  Total Steps: $stepCount" -ForegroundColor Green
        
        # Check for orchestration calls
        $orchestrationCalls = ($content | Select-String -Pattern "uses:\s*\.\./\.github/actions/orchestrate-" -AllMatches).Matches.Count
        Write-Host "    🎭 Orchestration Calls: $orchestrationCalls" -ForegroundColor Magenta
    }
}

# Test 5: Authentication and best practices
Write-Host "`n🔐 Checking Authentication and Best Practices..." -ForegroundColor Yellow

foreach ($workflow in $orchestratedWorkflows) {
    $workflowPath = Join-Path $WorkflowPath $workflow
    if (Test-Path $workflowPath) {
        $content = Get-Content $workflowPath -Raw
        
        # Check authentication
        if ($content -match "azure/login@v2") {
            Write-Host "  ✅ $workflow - Using azure/login@v2" -ForegroundColor Green
        }
        
        if ($content -match "client-id.*AZURE_CLIENT_ID" -and $content -match "tenant-id.*AZURE_TENANT_ID") {
            Write-Host "  ✅ $workflow - Using OIDC authentication" -ForegroundColor Green
        }
        
        # Check for clean structure
        if ($content -match "Orchestrate.*Deployment") {
            Write-Host "  🎭 $workflow - Uses orchestration pattern" -ForegroundColor Magenta
        }
        
        # Check for proper separation of concerns
        if ($content -match "validate-and-prepare" -and $content -match "deploy-.*-vm" -and $content -match "cleanup-on-failure") {
            Write-Host "  ⚙️  $workflow - Clean job separation" -ForegroundColor Green
        }
    }
}

# Summary
Write-Host "`n📊 Architecture Summary" -ForegroundColor Cyan
Write-Host "=" * 60

if ($missingActions.Count -eq 0) {
    Write-Host "✅ All orchestration and base actions are present" -ForegroundColor Green
} else {
    Write-Host "❌ Missing actions: $($missingActions -join ', ')" -ForegroundColor Red
}

Write-Host "`n🎯 Orchestration Benefits:" -ForegroundColor Cyan
Write-Host "✅ Single responsibility: Each workflow focuses on orchestration only"
Write-Host "✅ Complexity encapsulation: All deployment logic in composite actions"
Write-Host "✅ Reusability: Orchestrator can be used across multiple workflows"
Write-Host "✅ Maintainability: Changes in one place update all deployments"
Write-Host "✅ Testability: Individual components can be tested independently"

Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Test orchestrated workflows in development environment"
Write-Host "2. Compare complexity reduction vs legacy workflows"
Write-Host "3. Update documentation with new orchestration patterns"
Write-Host "4. Consider deprecating legacy workflow files"

Write-Host "`n🔗 Documentation:" -ForegroundColor Cyan
Write-Host "- Architecture: docs/Modular-VM-Deployment-Architecture.md"
Write-Host "- Implementation: docs/Implementation-Summary.md"
Write-Host "- Repository Setup: docs/Repository-Secrets-Setup.md"
