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
