function Get-GraphApiCredentials {
    $ClientId = Read-Host "Enter Client ID"
    $ClientSecret = Read-Host "Enter Client Secret"
    $UserEmail = Read-Host "Enter User Email"

    return @{
        ClientId = $ClientId
        ClientSecret = $ClientSecret
        UserEmail = $UserEmail
    }
}

function Get-ConditionalAccessPolicies {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$UserEmail
    )

    # ... (Rest of the function remains the same as before)

    $Policies = Invoke-RestMethod -Uri $GraphApiUrl -Headers $Headers -Method Get

    return $Policies
}

function Get-GraphApiPermissions {
    param (
        [string]$ClientId,
        [string]$ClientSecret
    )

    # ... (Rest of the function remains the same as before)

    $Permissions = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants" -Headers $Headers -Method Get

    return $Permissions.value
}

function Get-UserLicensing {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$UserEmail
    )

    $TokenUrl = "https://login.microsoftonline.com/<YOUR_TENANT_ID>/oauth2/v2.0/token"
    $GraphApiUrl = "https://graph.microsoft.com/v1.0/users/$UserEmail/licenseDetails"

    # ... (Rest of the function remains the same as before)

    $LicensingInfo = Invoke-RestMethod -Uri $GraphApiUrl -Headers $Headers -Method Get

    return $LicensingInfo.value
}

### This function will use Get-AzureADSubscribedSku to gather license information 
# Link Ref: https://learn.microsoft.com/en-us/powershell/module/azuread/get-azureadsubscribedsku?view=azureadps-2.0
###  
function Get-EntraIDLicensing-PS { 
    # Get the list of assigned licenses (SKUs)
    $licenses = Get-AzureADSubscribedSku

    # Initialize a hash table to store license information
    $licenseInfo = @{}

    # Populate the hash table with license details
    foreach ($license in $licenses) {
        $skuPartNumber = $license.SkuPartNumber
        $enabledUnits = $license.ConsumedUnits
        $licenseInfo[$skuPartNumber] = $enabledUnits
    }

    # Define the mapping of SKUs to readable license names
    $skuToLicenseName = @{
        "AAD_PREMIUM" = "Azure AD Premium P1"
        "AAD_PREMIUM_P2" = "Azure AD Premium P2"
        "AAD_BASIC" = "Azure AD Basic"
        "EMS" = "Enterprise Mobility + Security (EMS)"
        "EMS_E3" = "Enterprise Mobility + Security E3"
        "EMS_E5" = "Enterprise Mobility + Security E5"
        "O365_BUSINESS" = "Office 365 Business"
        "O365_ENTERPRISE" = "Office 365 Enterprise"
        # Add other SKUs as needed
    }

    # Display the licenses assigned to the tenant
    Write-Output "Licenses assigned to the tenant:"
    foreach ($sku in $licenseInfo.Keys) {
        $licenseName = $skuToLicenseName[$sku]
        $units = $licenseInfo[$sku]
        Write-Output "$licenseName ($sku): $units units"
    }
    Write-Output "-------------------------------------"

    # Determine the available license types
    $licenseTypes = @{}
    $licenseTypes["Free"] = $true  # Every tenant has Free tier by default

    if ($licenseInfo.ContainsKey("AAD_PREMIUM") -or $licenseInfo.ContainsKey("EMS") -or $licenseInfo.ContainsKey("EMS_E3")) {
        $licenseTypes["P1"] = $true
    } else {
        $licenseTypes["P1"] = $false
    }
    if ($licenseInfo.ContainsKey("AAD_PREMIUM_P2") -or $licenseInfo.ContainsKey("EMS_E5")) {
        $licenseTypes["P2"] = $true
    } else {
        $licenseTypes["P2"] = $false
    }

    # Define the features and their availability based on license type
    $features = @(
        @{Name = "User and Group Management"; Free = $true; P1 = $true; P2 = $true},
        @{Name = "Single Sign-On (SSO)"; Free = $true; P1 = $true; P2 = $true},
        @{Name = "Basic Security and Usage Reports"; Free = $true; P1 = $true; P2 = $true},
        @{Name = "Self-Service Password Change"; Free = $true; P1 = $true; P2 = $true},
        @{Name = "Microsoft 365 Integration"; Free = $true; P1 = $true; P2 = $true},
        @{Name = "Device Registration"; Free = $true; P1 = $true; P2 = $true},
        @{Name = "Application Proxy"; Free = $true; P1 = $true; P2 = $true},
        @{Name = "Advanced Security Reports and Alerts"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Conditional Access"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Azure AD Join"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Multi-Factor Authentication (MFA)"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Dynamic Groups"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Self-Service Password Reset (SSPR)"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Cloud App Discovery"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Enterprise State Roaming"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Company Branding"; Free = $false; P1 = $true; P2 = $true},
        @{Name = "Identity Protection"; Free = $false; P1 = $false; P2 = $true},
        @{Name = "Privileged Identity Management (PIM)"; Free = $false; P1 = $false; P2 = $true},
        @{Name = "Access Reviews"; Free = $false; P1 = $false; P2 = $true},
        @{Name = "Entitlement Management"; Free = $false; P1 = $false; P2 = $true},
        @{Name = "Identity Governance"; Free = $false; P1 = $false; P2 = $true}
    )

    # Create the chart based on the licenses present in the tenant
    $chart = @()
        foreach ($feature in $features) {
            $chart += [PSCustomObject]@{
                Feature = $feature.Name
                Free = if ($feature.Free -and $licenseTypes["Free"]) { "Yes" } else { "No" }
                PremiumP1 = if ($feature.P1 -and $licenseTypes["P1"]) { "Yes" } else { "No" }
                PremiumP2 = if ($feature.P2 -and $licenseTypes["P2"]) { "Yes" } else { "No" }
            }
    }

    # Display the chart
    Write-Output "Feature Availability based on Licenses:"
    $chart | Format-Table -AutoSize

}

function Check-AdvancedSecurityFeatures {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$UserEmail
    )

    # ... (Rest of the function remains the same as before)

    $ConditionalAccessEnabled = $UserDetails.assignedPlans | Where-Object { $_.servicePlanId -eq "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" } -ne $null

    # ... (Rest of the function remains the same as before)

    return $SecurityFeatures
}

function Check-GraphApiPermissions {
    param (
        [string]$ClientId,
        [string]$ClientSecret
    )

    # ... (Rest of the function remains the same as before)
}

function Check-UserLicensing {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$UserEmail
    )

    $LicensingInfo = Get-UserLicensing -ClientId $ClientId -ClientSecret $ClientSecret -UserEmail $UserEmail

    Write-Host "User Licensing Information for $UserEmail:"
    $LicensingInfo | ForEach-Object {
        Write-Host "Service: $($_.servicePlan.service) - SKU: $($_.servicePlan.skuId) - Active: $($_.servicePlan.capabilityStatus)"
    }
}

$Credentials = Get-GraphApiCredentials
$SecurityFeatures = Check-AdvancedSecurityFeatures -ClientId $Credentials.ClientId -ClientSecret $Credentials.ClientSecret -UserEmail $Credentials.UserEmail

# ... (Rest of the script remains the same as before)

Check-UserLicensing -ClientId $Credentials.ClientId -ClientSecret $Credentials.ClientSecret -UserEmail $Credentials.UserEmail
