Install-Module Microsoft.Graph -Scope CurrentUser

# Import the module
Import-Module Microsoft.Graph

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "SecurityEvents.Read.All"

# Retrieve the Secure Score data
$secureScore = Get-MgSecuritySecureScore

# Display the Secure Score summary
$secureScoreSummary = @{
    "Current Score" = $secureScore.CurrentScore
    "Max Score" = $secureScore.MaxScore
    "Percentage" = ($secureScore.CurrentScore / $secureScore.MaxScore) * 100
}

$secureScoreSummary | Format-Table -AutoSize

# Retrieve detailed Secure Score control data
$secureScoreControls = Get-MgSecuritySecureScoreControlProfile

# Display detailed Secure Score control data
$secureScoreControls | Select-Object DisplayName, Status, CurrentScore, MaxScore, ComplianceStatus | Format-Table -AutoSize

# Analyze which controls have the highest potential impact
$highImpactControls = $secureScoreControls | Where-Object { $_.ComplianceStatus -eq "NotCompliant" } | Sort-Object -Property MaxScore -Descending

# Display the high impact controls
$highImpactControls | Select-Object DisplayName, Status, CurrentScore, MaxScore | Format-Table -AutoSize

thomashutchison/msGraph-check/eid_secure_score.ps1