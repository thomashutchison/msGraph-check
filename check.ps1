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

    $TokenUrl = "https://login.microsoftonline.com/<YOUR_TENANT_ID>/oauth2/v2.0/token"
    $GraphApiUrl = "https://graph.microsoft.com/v1.0/users/$UserEmail/policies/conditionalAccess"

    $TokenBody = @{
        client_id     = $ClientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $ClientSecret
        grant_type    = "client_credentials"
    }

    $TokenResponse = Invoke-RestMethod -Uri $TokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $TokenBody
    $AccessToken = $TokenResponse.access_token

    $Headers = @{
        Authorization = "Bearer $AccessToken"
    }

    $Policies = Invoke-RestMethod -Uri $GraphApiUrl -Headers $Headers -Method Get

    return $Policies
}

function Get-GraphApiPermissions {
    param (
        [string]$ClientId,
        [string]$ClientSecret
    )

    $TokenUrl = "https://login.microsoftonline.com/<YOUR_TENANT_ID>/oauth2/v2.0/token"
    $Scope = "https://graph.microsoft.com/.default"
    
    $TokenBody = @{
        client_id     = $ClientId
        scope         = $Scope
        client_secret = $ClientSecret
        grant_type    = "client_credentials"
    }

    $TokenResponse = Invoke-RestMethod -Uri $TokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $TokenBody
    $AccessToken = $TokenResponse.access_token

    $Headers = @{
        Authorization = "Bearer $AccessToken"
    }

    $Permissions = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants" -Headers $Headers -Method Get

    return $Permissions.value
}

function Check-AdvancedSecurityFeatures {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$UserEmail
    )

    $TokenUrl = "https://login.microsoftonline.com/<YOUR_TENANT_ID>/oauth2/v2.0/token"
    $GraphApiUrl = "https://graph.microsoft.com/v1.0/users/$UserEmail"

    # ... (Rest of the function remains the same as previous)

    $ConditionalAccessEnabled = $UserDetails.assignedPlans | Where-Object { $_.servicePlanId -eq "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" } -ne $null

    $SecurityFeatures = @{
        MultiFactorAuthentication = $MfaEnabled
        AdvancedThreatProtection = $AtpEnabled
        ConditionalAccess = $ConditionalAccessEnabled
        InformationProtection = $InformationProtectionEnabled
        MdmEnrolled = $MdmEnrolled
        WindowsDefenderEnabled = $DefenderEnabled
        DlpPolicies = $DlpPolicies
    }

    if ($ConditionalAccessEnabled) {
        $ConditionalAccessPolicies = Get-ConditionalAccessPolicies -ClientId $ClientId -ClientSecret $ClientSecret -UserEmail $UserEmail
        $SecurityFeatures.ConditionalAccessPolicies = $ConditionalAccessPolicies.value
    }

    return $SecurityFeatures
}

function Check-GraphApiPermissions {
    param (
        [string]$ClientId,
        [string]$ClientSecret
    )

    $Permissions = Get-GraphApiPermissions -ClientId $ClientId -ClientSecret $ClientSecret

    $Permissions | ForEach-Object {
        Write-Host "Resource: $($_.resourceDisplayName) - Scope: $($_.scope)"
    }
}

$Credentials = Get-GraphApiCredentials
$SecurityFeatures = Check-AdvancedSecurityFeatures -ClientId $Credentials.ClientId -ClientSecret $Credentials.ClientSecret -UserEmail $Credentials.UserEmail

Write-Host "Multi-Factor Authentication Enabled: $($SecurityFeatures.MultiFactorAuthentication)"
Write-Host "Advanced Threat Protection Enabled: $($SecurityFeatures.AdvancedThreatProtection)"
Write-Host "Conditional Access Enabled: $($SecurityFeatures.ConditionalAccess)"
Write-Host "Information Protection Enabled: $($SecurityFeatures.InformationProtection)"
Write-Host "MDM Enrolled: $($SecurityFeatures.MdmEnrolled)"
Write-Host "Windows Defender Enabled: $($SecurityFeatures.WindowsDefenderEnabled)"
Write-Host "DLP Policies Enabled: $($SecurityFeatures.DlpPolicies)"

if ($SecurityFeatures.ConditionalAccess) {
    Write-Host "Conditional Access Policies:"
    $SecurityFeatures.ConditionalAccessPolicies | ForEach-Object {
        Write-Host "Policy: $($_.displayName) - State: $($_.state)"
    }
}

Write-Host "Graph API Permissions:"
Check-GraphApiPermissions -ClientId $Credentials.ClientId -ClientSecret $Credentials.ClientSecret
