# Test Repository Secrets Configuration
# This script helps validate that your repository secrets are properly configured for VM deployment

param(
    [Parameter(HelpMessage = "Test Linux VM deployment secrets")]
    [switch]$TestLinux,
    
    [Parameter(HelpMessage = "Test Windows VM deployment secrets")]
    [switch]$TestWindows,
    
    [Parameter(HelpMessage = "Validate Azure resources exist")]
    [switch]$ValidateResources
)

Write-Host "🔍 Repository Secrets Validation Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if Azure PowerShell is available
if (-not (Get-Module -Name Az -ListAvailable)) {
    Write-Host "❌ Azure PowerShell module not found. Please install it:" -ForegroundColor Red
    Write-Host "   Install-Module -Name Az -Force -AllowClobber" -ForegroundColor Yellow
    exit 1
}

# Check if user is logged in to Azure
try {
    $context = Get-AzContext -ErrorAction Stop
    if (-not $context) {
        throw "Not logged in"
    }
    Write-Host "✅ Azure PowerShell context found for: $($context.Account.Id)" -ForegroundColor Green
} catch {
    Write-Host "❌ Not logged in to Azure. Please run: Connect-AzAccount" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Required Repository Secrets Checklist" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

# Common secrets for all deployments
$commonSecrets = @(
    "AZURE_CREDENTIALS",
    "AZURE_SUBSCRIPTION_ID", 
    "AZURE_RESOURCE_GROUP",
    "VM_ADMIN_USERNAME",
    "VM_ADMIN_PASSWORD",
    "SUBNET_ID"
)

# Linux-specific secrets
$linuxSecrets = @(
    "KEYVAULT_ID",
    "CERTIFICATE_URL"
)

Write-Host ""
Write-Host "Common Secrets (Required for all VMs):" -ForegroundColor Cyan
foreach ($secret in $commonSecrets) {
    Write-Host "  ☐ $secret" -ForegroundColor White
}

if ($TestLinux) {
    Write-Host ""
    Write-Host "Linux-Specific Secrets:" -ForegroundColor Cyan
    foreach ($secret in $linuxSecrets) {
        Write-Host "  ☐ $secret" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "💡 Secret Value Examples:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow

# Example AZURE_CREDENTIALS format
Write-Host ""
Write-Host "AZURE_CREDENTIALS (JSON format):" -ForegroundColor Cyan
$credentialsExample = @{
    clientId = "12345678-1234-1234-1234-123456789012"
    clientSecret = "your-service-principal-secret"
    subscriptionId = (Get-AzContext).Subscription.Id
    tenantId = (Get-AzContext).Tenant.Id
} | ConvertTo-Json -Compress

Write-Host $credentialsExample -ForegroundColor Gray

# Other examples
Write-Host ""
Write-Host "VM_ADMIN_PASSWORD requirements:" -ForegroundColor Cyan
Write-Host "  • Minimum 12 characters" -ForegroundColor Gray
Write-Host "  • Contains uppercase letters" -ForegroundColor Gray
Write-Host "  • Contains lowercase letters" -ForegroundColor Gray
Write-Host "  • Contains numbers" -ForegroundColor Gray
Write-Host "  • Contains special characters" -ForegroundColor Gray
Write-Host "  • Example: YourSecurePassword123!" -ForegroundColor Gray

if ($ValidateResources) {
    Write-Host ""
    Write-Host "🔍 Validating Azure Resources..." -ForegroundColor Yellow
    Write-Host "================================" -ForegroundColor Yellow
    
    # Prompt for resource group name
    $rgName = Read-Host "Enter your VM deployment resource group name"
    
    # Check if resource group exists
    try {
        $rg = Get-AzResourceGroup -Name $rgName -ErrorAction Stop
        Write-Host "✅ Resource Group '$rgName' found in $($rg.Location)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Resource Group '$rgName' not found" -ForegroundColor Red
        return
    }
    
    # Check Shared Image Gallery
    Write-Host ""
    Write-Host "🖼️ Checking Shared Image Gallery..." -ForegroundColor Cyan
    $galleries = Get-AzGallery
    if ($galleries.Count -gt 0) {
        Write-Host "✅ Found $($galleries.Count) Shared Image Galleries:" -ForegroundColor Green
        foreach ($gallery in $galleries) {
            Write-Host "   • $($gallery.Name) in $($gallery.ResourceGroupName)" -ForegroundColor Gray
            
            # Check for golden images
            $images = Get-AzGalleryImageDefinition -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName
            foreach ($image in $images) {
                if ($image.Name -match "Golden") {
                    Write-Host "     📸 $($image.Name) ($($image.OsType))" -ForegroundColor Green
                }
            }
        }
    } else {
        Write-Host "❌ No Shared Image Galleries found" -ForegroundColor Red
    }
    
    # Check virtual networks
    Write-Host ""
    Write-Host "🌐 Checking Virtual Networks..." -ForegroundColor Cyan
    $vnets = Get-AzVirtualNetwork
    if ($vnets.Count -gt 0) {
        Write-Host "✅ Found $($vnets.Count) Virtual Networks:" -ForegroundColor Green
        foreach ($vnet in $vnets) {
            Write-Host "   • $($vnet.Name) in $($vnet.ResourceGroupName)" -ForegroundColor Gray
            foreach ($subnet in $vnet.Subnets) {
                $subnetId = $subnet.Id
                Write-Host "     🔗 Subnet: $($subnet.Name)" -ForegroundColor Gray
                Write-Host "       Resource ID: $subnetId" -ForegroundColor DarkGray
            }
        }
    } else {
        Write-Host "❌ No Virtual Networks found" -ForegroundColor Red
    }
    
    if ($TestLinux) {
        # Check Key Vault
        Write-Host ""
        Write-Host "🔑 Checking Key Vaults..." -ForegroundColor Cyan
        $keyVaults = Get-AzKeyVault
        if ($keyVaults.Count -gt 0) {
            Write-Host "✅ Found $($keyVaults.Count) Key Vaults:" -ForegroundColor Green
            foreach ($kv in $keyVaults) {
                Write-Host "   • $($kv.VaultName) in $($kv.ResourceGroupName)" -ForegroundColor Gray
                Write-Host "     Resource ID: $($kv.ResourceId)" -ForegroundColor DarkGray
                
                # Check for certificates/secrets
                try {
                    $secrets = Get-AzKeyVaultSecret -VaultName $kv.VaultName -ErrorAction SilentlyContinue
                    if ($secrets.Count -gt 0) {
                        Write-Host "     🔐 Secrets available: $($secrets.Count)" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "     ⚠️ Cannot list secrets (permission required)" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "❌ No Key Vaults found" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "📚 Next Steps:" -ForegroundColor Yellow
Write-Host "==============" -ForegroundColor Yellow
Write-Host "1. Configure the required secrets in your GitHub repository" -ForegroundColor White
Write-Host "2. Navigate to Settings → Secrets and variables → Actions" -ForegroundColor White
Write-Host "3. Add each secret with the exact name shown above" -ForegroundColor White
Write-Host "4. Test the deployment workflow in the Actions tab" -ForegroundColor White
Write-Host ""
Write-Host "📖 For detailed setup instructions, see:" -ForegroundColor Cyan
Write-Host "   docs/Repository-Secrets-Setup.md" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Ready to deploy VMs with GitHub Actions!" -ForegroundColor Green
