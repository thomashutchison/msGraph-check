#Install Module for Graph
#Install-Module Microsoft.Graph -Scope CurrentUser

# Sign in and authenticate
#Connect-MgGraph -Scopes "User.Read"

# View the token cache for the current session
#(Get-MgContext).AuthContext.Account

#To inspect the token itself
#(Get-MgContext).AuthContext.TokenCacheItems

# Install Microsoft Graph PowerShell module if not already installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Import the module
Import-Module Microsoft.Graph

# Authenticate and connect to Microsoft Graph (use 'User.Read' scope to fetch user details)
Connect-MgGraph -Scopes "User.Read"

# Retrieve and display current user details
$currentUser = Get-MgUser -UserId (Get-MgUser -Filter "userPrincipalName eq '$(Get-MgUser).userPrincipalName'").id

Write-Host "User Information:"
Write-Host "Display Name: $($currentUser.DisplayName)"
Write-Host "User Principal Name (UPN): $($currentUser.UserPrincipalName)"
Write-Host "Mail: $($currentUser.Mail)"
Write-Host "Job Title: $($currentUser.JobTitle)"
Write-Host "Account Enabled: $($currentUser.AccountEnabled)"
Write-Host "----------------------------------------"

# Retrieve token cache and inspect any associated tokens
$tokenCacheItems = (Get-MgContext).AuthContext.TokenCacheItems

if ($tokenCacheItems.Count -eq 0) {
    Write-Host "No tokens found in the cache."
} else {
    foreach ($token in $tokenCacheItems) {
        Write-Host "Token Type: $($token.TokenType)"
        Write-Host "Expires On: $($token.ExpiresOn)"
        Write-Host "Scopes: $($token.Scope)"
        Write-Host "----------------------------------------"
    }
}

# Disconnect the session
Disconnect-MgGraph
