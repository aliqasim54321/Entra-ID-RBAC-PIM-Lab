# Part 2 — RBAC & Privileged Identity Management

## Objective

Part 2 focuses on assigning access according to job function using Microsoft Entra directory roles, Microsoft Graph, least privilege, Privileged Identity Management, and custom roles.

## Figure 9 — Microsoft Graph Role Management Permission

```powershell
Connect-MgGraph `
    -Scopes "User.Read.All","Directory.Read.All","RoleManagement.ReadWrite.Directory" `
    -ContextScope Process
```

```markdown
![Figure 9 - Microsoft Graph role management permission](images/fig09.png)
```

## Figure 10 — Assign a Role Through Microsoft Graph

A single-user test was performed first.

```powershell
$User = Get-MgUser -UserId "marcus.reyes@$Domain"

$Role = Get-MgRoleManagementDirectoryRoleDefinition `
    -Filter "displayName eq 'Helpdesk Administrator'"

$Params = @{
    PrincipalId      = $User.Id
    RoleDefinitionId = $Role.Id
    DirectoryScopeId = "/"
}

New-MgRoleManagementDirectoryRoleAssignment `
    -BodyParameter $Params
```

```markdown
![Figure 10 - Role assignment through Microsoft Graph](images/fig10.png)
```

```text
PrincipalId      = WHO
RoleDefinitionId = WHAT ROLE
DirectoryScopeId = WHERE
```

## Figure 11 — Portal Verification

```markdown
![Figure 11 - Helpdesk Administrator role verified in Entra ID](images/fig11.png)
```

## Figure 12 — Bulk Role Assignment Script

A `$RoleMap` hashtable mapped each user to one or more directory roles. The script checked whether the relationship already existed before creating it.

```markdown
![Figure 12 - Bulk RBAC assignment script](images/fig12.png)
```

## Figure 13 — Users Assigned Their Respective Roles

```markdown
![Figure 13 - Bulk users assigned their respective Entra roles](images/fig13.png)
```

This demonstrates **least-privilege RBAC** rather than giving every user broad administrative access.

## Figure 14 — PIM Privileged Role Assignment

Marcus was assigned **Privileged Role Administrator** through Privileged Identity Management.

```markdown
![Figure 14 - Privileged Role Administrator assignment through PIM](images/fig14.png)
```

### Troubleshooting — `RoleNotFound`

PIM initially returned:

```text
RoleNotFound
The role is not found
```

The role definition itself existed. The issue was resolved after the administrative account had the appropriate privileged role-management authority and Graph authentication was refreshed.

```powershell
Disconnect-MgGraph
Connect-MgGraph `
    -Scopes "User.Read.All","RoleManagement.ReadWrite.Directory" `
    -ContextScope Process
```

```text
Graph OAuth scope
      +
Entra directory role
      +
fresh authentication context
      =
successful privileged operation
```

## Figure 15 — Custom SOC Analyst Role

A custom role named **Soc Analyst Custom role** was created and assigned to **Fatima Al-Rashid**.

```markdown
![Figure 15 - SOC Analyst custom role and user assignment](images/fig15.png)
```

### Troubleshooting — PIM Propagation

The custom role initially produced inconsistent PIM behavior. Graph confirmed that the role existed, was enabled, had a role management policy assignment, and had the expected PIM rules. The portal needed additional time to complete propagation.

## RBAC Outcome

```text
Identity
  -> job function
  -> least-privilege Entra role
  -> PIM for privileged roles
  -> custom role where appropriate
  -> verification in Graph and portal
```

## Repository Scope

This repository focuses on **RBAC, least privilege, Microsoft Graph role assignment, PIM, custom roles, and Mover access changes**.

## Prerequisite

The identities used here were created in the Joiner repository.
