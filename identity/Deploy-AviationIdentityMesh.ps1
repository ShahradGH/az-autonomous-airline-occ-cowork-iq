<#
.SYNOPSIS
    Deploy-AviationIdentityMesh.ps1
    Provisions dedicated Microsoft Entra ID workload identity and Microsoft Graph v2.x permissions
    for the Autonomous Airline Operations Control Centre (OCC) Co-Worker.

.DESCRIPTION
    Decouples agent authority from human interactive credentials by provisioning an Entra ID
    Application and Service Principal with strictly scoped Microsoft Graph application permissions
    (ChannelMessage.Read.All) to ambiently monitor the Teams disruption channel.

.NOTES
    Author: Shahrad Alerasoul
    Architecture: Autonomous Airline OCC Copilot Cowork & Multi-IQ Grounding
    Authority: Microsoft Frontier Tour 2026-2027
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$AppName = "app-agent-aviation-occ-prod",

    [Parameter(Mandatory = $false)]
    [string]$SignInAudience = "AzureADMyOrg"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==> [Identity Mesh] Verifying Microsoft Graph v2.x connection..." -ForegroundColor Cyan
try {
    $context = Get-MgContext
    if (-not $context) {
        Write-Host "Connecting to Microsoft Graph with Application.ReadWrite.All and AppRoleAssignment.ReadWrite.All..." -ForegroundColor Yellow
        Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"
    }
} catch {
    Write-Error "Failed to verify or connect Microsoft Graph context: $_"
}

# 1. Provision or Retrieve Service Principal
Write-Host "==> [Identity Mesh] Ensuring application '$AppName' exists..." -ForegroundColor Cyan
$existingApp = Get-MgApplication -Filter "DisplayName eq '$AppName'" | Select-Object -First 1

if (-not $existingApp) {
    Write-Host "Creating new Entra ID Application: $AppName" -ForegroundColor Green
    $existingApp = New-MgApplication -DisplayName $AppName -SignInAudience $SignInAudience
} else {
    Write-Host "Found existing Application: $($existingApp.AppId)" -ForegroundColor Gray
}

$sp = Get-MgServicePrincipal -Filter "AppId eq '$($existingApp.AppId)'" | Select-Object -First 1
if (-not $sp) {
    Write-Host "Creating Service Principal for AppId: $($existingApp.AppId)" -ForegroundColor Green
    $sp = New-MgServicePrincipal -AppId $existingApp.AppId
} else {
    Write-Host "Found existing Service Principal: $($sp.Id)" -ForegroundColor Gray
}

# 2. Grant Scoped Teams Channel Message Ingestion Permission
Write-Host "==> [Identity Mesh] Assigning 'ChannelMessage.Read.All' app role..." -ForegroundColor Cyan
$graphSp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'" | Select-Object -First 1
$role = $graphSp.AppRoles | Where-Object { $_.Value -eq "ChannelMessage.Read.All" -and $_.AllowedMemberTypes -contains "Application" } | Select-Object -First 1

if ($role) {
    $existingAssignment = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id | Where-Object { $_.AppRoleId -eq $role.Id }
    if (-not $existingAssignment) {
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id `
            -PrincipalId $sp.Id `
            -ResourceId $graphSp.Id `
            -AppRoleId $role.Id | Out-Null
        Write-Host "Successfully assigned ChannelMessage.Read.All to $AppName" -ForegroundColor Green
    } else {
        Write-Host "App role ChannelMessage.Read.All already assigned." -ForegroundColor Gray
    }
} else {
    Write-Warning "Could not resolve 'ChannelMessage.Read.All' role from Microsoft Graph service principal."
}

Write-Host "==> [Identity Mesh] Identity provisioning verified for $AppName." -ForegroundColor Green

