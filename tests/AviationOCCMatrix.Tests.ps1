<#
    .SYNOPSIS
        16-Test Deterministic Verification Matrix for Autonomous Airline OCC Co-Worker
    .DESCRIPTION
        Validates 6 permitted operational patterns and 10 negative safety/security boundary veto tests.
        Repository: https://github.com/ShahradGH/az-autonomous-airline-occ-cowork-iq
        Reference: Grounding Teams Copilot Cowork across 4 Microsoft IQs
#>

BeforeAll {
    $script:CasesFile = Join-Path $PSScriptRoot "..\sample-data\aviation-disruption-cases.json"
    if (Test-Path $script:CasesFile) {
        $raw = Get-Content -Raw -Path $script:CasesFile
        $script:Cases = ConvertFrom-Json $raw
    } else {
        $script:Cases = @()
    }
}

Describe "Aviation OCC Disruption Matrix 16-Test Suite" {

    # =========================================================================
    # Phase 1: Governed Multi-IQ Ingress & Telemetry Reads (Permitted Operations)
    # =========================================================================
    Context "Phase 1: Multi-IQ Context Mesh Ingress (Permitted Operations)" {
        It "AIR-01: Work IQ ambient Teams channel message subscription returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-01" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "AIR-03: Fabric Direct Lake semantic measure query returns PERMIT (<100ms)" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-03" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "AIR-06: Web IQ Eurocontrol NMOC slot window ingestion returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-06" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "AIR-08: Web IQ METAR convective weather radar ingestion returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-08" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "AIR-09: Cosmos DB Decision Memory session proposal commit returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-09" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "AIR-13: Microsoft Fabric TMDL Realized_Capacity read returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-13" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "AIR-15: Interactive Adaptive Card emission to #occ-bridge returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-15" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }
    }

    # =========================================================================
    # Phase 2: Mandatory Air Safety, CAA FTL & Sovereign Veto Boundaries (DENY)
    # =========================================================================
    Context "Phase 2: Flight Safety & Operational Veto Gates (DENY)" {
        It "AIR-02: Direct unvetted Sabre mainframe write is strictly DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-02" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "AIR-04: Mandatory CAA Flight Time Limitation (FTL) duty breach is DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-04" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "AIR-05: HOLD FOR CHIEF DUTY PILOT SIGN-OFF gate violation is DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-05" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "AIR-07: Concurrency race condition on Cosmos DB state lock is DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-07" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "AIR-10: Confidential HR and crew personnel dossier access is DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-10" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }
    }

    # =========================================================================
    # Phase 3: Identity Mesh, Recursion & Boundary Breach Resilience (DENY)
    # =========================================================================
    Context "Phase 3: Identity Mesh & Circuit Breaker Resilience (DENY)" {
        It "AIR-11: 8-Turn negotiation recursion loop circuit breaker trips (DENY)" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-11" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "AIR-12: Chief Duty Pilot Entra ID token spoofing is rejected (DENY)" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-12" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "AIR-14: Direct SQL injection / table drop attempt against Lakehouse is DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-14" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "AIR-16: Unsigned outbound webhook to tarmac ground tug is DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "AIR-16" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }
    }
}
