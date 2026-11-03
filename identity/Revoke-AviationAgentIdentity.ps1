<#
.SYNOPSIS
    Revoke-AviationAgentIdentity.ps1
    Emergency kill-switch: revokes Entra ID App Role assignments and disables the Service Principal.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$AppName = "app-agent-aviation-occ-prod"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==> [Kill-Switch] Locating Service Principal for '$AppName'..." -ForegroundColor Red
$sp = Get-MgServicePrincipal -Filter "DisplayName eq '$AppName'" | Select-Object -First 1

if (-not $sp) {
    Write-Warning "Service Principal for '$AppName' not found."
    return
}

# Remove app role assignments
$assignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id
foreach ($a in $assignments) {
    Write-Host "Removing app role assignment: $($a.Id)..." -ForegroundColor Yellow
    Remove-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -AppRoleAssignmentId $a.Id
}

# Disable Service Principal account
Write-Host "Disabling Service Principal $($sp.Id)..." -ForegroundColor Red
Update-MgServicePrincipal -ServicePrincipalId $sp.Id -AccountEnabled:$false

Write-Host "==> [Kill-Switch] Workload identity deactivated and permissions severed." -ForegroundColor Green

