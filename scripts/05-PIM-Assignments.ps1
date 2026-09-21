# ============================================================
# 05 - PIM: ACTIVE / ELIGIBLE ROLE ASSIGNMENT EXAMPLES
# ============================================================
# Requires appropriate Microsoft Entra licensing and privileged
# role-management authority.

$Domain = "<tenant>.onmicrosoft.com"

$User = Get-MgUser -UserId "marcus.reyes@$Domain"
$Role = Get-MgRoleManagementDirectoryRoleDefinition `
    -Filter "displayName eq 'Privileged Role Administrator'"

# ACTIVE PIM assignment - 1 hour
$ActiveParams = @{
    Action           = "adminAssign"
    PrincipalId      = $User.Id
    RoleDefinitionId = $Role.Id
    DirectoryScopeId = "/"
    Justification    = "IAM lab - PIM active assignment"
    ScheduleInfo     = @{
        StartDateTime = (Get-Date).ToUniversalTime()
        Expiration    = @{
            Type     = "AfterDuration"
            Duration = "PT1H"
        }
    }
}

New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest `
    -BodyParameter $ActiveParams

# ELIGIBLE PIM assignment - no expiration
$EligibleParams = @{
    Action           = "adminAssign"
    PrincipalId      = $User.Id
    RoleDefinitionId = $Role.Id
    DirectoryScopeId = "/"
    Justification    = "IAM lab - PIM eligible assignment"
    ScheduleInfo     = @{
        StartDateTime = (Get-Date).ToUniversalTime()
        Expiration    = @{
            Type = "NoExpiration"
        }
    }
}

# Uncomment when you intentionally want an eligible assignment.
# New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest `
#     -BodyParameter $EligibleParams

# Verification
Get-MgRoleManagementDirectoryRoleAssignmentSchedule `
    -Filter "principalId eq '$($User.Id)' and roleDefinitionId eq '$($Role.Id)'"

Get-MgRoleManagementDirectoryRoleEligibilitySchedule `
    -Filter "principalId eq '$($User.Id)' and roleDefinitionId eq '$($Role.Id)'"
