# ============================================================
# 03 - MOVER: ACCESS CHANGE EXAMPLE
# ============================================================
# Simplified example. In production, desired access should come
# from HR/IGA policy and be approved before changes are applied.

$Domain    = "<tenant>.onmicrosoft.com"
$TargetUPN = "danielle.okafor@$Domain"

$User = Get-MgUser -UserId $TargetUPN -ErrorAction Stop
Write-Host "Mover workflow for $($User.DisplayName)"

# Example job change.
Update-MgUser `
    -UserId $User.Id `
    -JobTitle "Senior Security Operations Analyst" `
    -Department "Cybersecurity Contractors"

# Example new role required after promotion.
$NewRole = Get-MgRoleManagementDirectoryRoleDefinition `
    -Filter "displayName eq 'Security Operator'"

$ExistingRole = Get-MgRoleManagementDirectoryRoleAssignment `
    -Filter "principalId eq '$($User.Id)' and roleDefinitionId eq '$($NewRole.Id)'"

if (-not $ExistingRole) {
    New-MgRoleManagementDirectoryRoleAssignment `
        -BodyParameter @{
            PrincipalId      = $User.Id
            RoleDefinitionId = $NewRole.Id
            DirectoryScopeId = "/"
        } |
        Out-Null
    Write-Host "ADDED ROLE: Security Operator"
}
else {
    Write-Host "SKIPPED: Security Operator already assigned"
}

# Example old role no longer required.
$OldRole = Get-MgRoleManagementDirectoryRoleDefinition `
    -Filter "displayName eq 'Security Reader'"

$OldAssignments = Get-MgRoleManagementDirectoryRoleAssignment `
    -Filter "principalId eq '$($User.Id)' and roleDefinitionId eq '$($OldRole.Id)'"

foreach ($Assignment in $OldAssignments) {
    Remove-MgRoleManagementDirectoryRoleAssignment `
        -UnifiedRoleAssignmentId $Assignment.Id
    Write-Host "REMOVED ROLE: Security Reader"
}

Write-Host "Mover workflow completed."
