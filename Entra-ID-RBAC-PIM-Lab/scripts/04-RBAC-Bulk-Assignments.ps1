# ============================================================
# 04 - RBAC: BULK MICROSOFT ENTRA ROLE ASSIGNMENTS
# ============================================================

$Domain = "<tenant>.onmicrosoft.com"

$RoleMap = @{
    # IAM
    "marcus.reyes@$Domain" = @("Helpdesk Administrator","Security Reader")
    "priya.nair@$Domain" = @("Cloud Application Administrator","Security Reader")
    "jordan.whitfield@$Domain" = @("Helpdesk Administrator","Security Reader")

    # SOC
    "danielle.okafor@$Domain" = @("Security Reader")
    "ethan.bowen@$Domain" = @("Security Reader","Security Operator")
    "sofia.marchetti@$Domain" = @("Security Administrator")

    # GRC
    "kwame.asante@$Domain" = @("Compliance Data Administrator")
    "leila.hassan@$Domain" = @("Compliance Administrator")
    "ryan.callahan@$Domain" = @("Compliance Data Administrator","Security Reader")

    # Pentest / Red Team
    "aleksei.volkov@$Domain" = @("Security Reader")
    "tanya.brooks@$Domain" = @("Security Reader")
    "hiro.tanaka@$Domain" = @("Security Reader")

    # Cloud Security
    "amara.diallo@$Domain" = @("Cloud App Security Administrator","Security Reader")
    "noah.steinberg@$Domain" = @("Cloud App Security Administrator","Cloud Application Administrator")
    "fatima.al-rashid@$Domain" = @("Security Reader")

    # Threat Intel / Malware / Vulnerability / DFIR / AppSec
    "damon.pierce@$Domain" = @("Security Reader")
    "ingrid.larsson@$Domain" = @("Security Reader")
    "carlos.fuentes@$Domain" = @("Security Reader")
    "simone.dupont@$Domain" = @("Security Operator","Security Reader")
    "kai.nguyen@$Domain" = @("Security Reader","Cloud Application Administrator")
}

$Assigned = 0
$Skipped  = 0
$Failed   = 0

foreach ($UPN in $RoleMap.Keys) {
    try {
        $User = Get-MgUser -UserId $UPN -ErrorAction Stop

        foreach ($RoleName in $RoleMap[$UPN]) {
            try {
                $Role = Get-MgRoleManagementDirectoryRoleDefinition `
                    -Filter "displayName eq '$RoleName'"

                if (-not $Role) {
                    Write-Host "FAILED: $($User.DisplayName) -> $RoleName (role not found)"
                    $Failed++
                    continue
                }

                $Existing = Get-MgRoleManagementDirectoryRoleAssignment `
                    -Filter "principalId eq '$($User.Id)' and roleDefinitionId eq '$($Role.Id)'"

                if ($Existing) {
                    Write-Host "SKIPPED: $($User.DisplayName) -> $RoleName"
                    $Skipped++
                    continue
                }

                New-MgRoleManagementDirectoryRoleAssignment `
                    -BodyParameter @{
                        PrincipalId      = $User.Id
                        RoleDefinitionId = $Role.Id
                        DirectoryScopeId = "/"
                    } `
                    -ErrorAction Stop |
                    Out-Null

                Write-Host "ASSIGNED: $($User.DisplayName) -> $RoleName"
                $Assigned++
            }
            catch {
                Write-Host "FAILED: $($User.DisplayName) -> $RoleName"
                Write-Host $_.Exception.Message
                $Failed++
            }
        }
    }
    catch {
        Write-Host "FAILED USER: $UPN"
        Write-Host $_.Exception.Message
        $Failed++
    }
}

Write-Host ""
Write-Host "RBAC SUMMARY"
Write-Host "Assigned: $Assigned"
Write-Host "Skipped : $Skipped"
Write-Host "Failed  : $Failed"
