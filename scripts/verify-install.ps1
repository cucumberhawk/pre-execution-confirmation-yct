[CmdletBinding()]
param(
    [string]$CodexHome
)

$ErrorActionPreference = "Stop"

$startMarker = "<!-- BEGIN CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->"
$endMarker = "<!-- END CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->"
$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$failures = New-Object System.Collections.Generic.List[string]
$legacyUnscopedPatterns = @(
    "(?i)For every new user request that asks the agent to perform an action",
    "对于每个要求 Codex 执行操作的新用户请求"
)

function Resolve-CodexHome {
    param([string]$RequestedHome)

    if (-not [string]::IsNullOrWhiteSpace($RequestedHome)) {
        return [Environment]::ExpandEnvironmentVariables($RequestedHome)
    }

    $environmentHome = [Environment]::GetEnvironmentVariable("CODEX_HOME")
    if (-not [string]::IsNullOrWhiteSpace($environmentHome)) {
        return [Environment]::ExpandEnvironmentVariables($environmentHome)
    }

    $userProfile = [Environment]::GetFolderPath("UserProfile")
    if ([string]::IsNullOrWhiteSpace($userProfile)) {
        throw "Unable to determine the current user profile."
    }

    return (Join-Path $userProfile ".codex")
}

function Add-Failure {
    param([string]$Message)
    $failures.Add($Message)
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $repoRoot "templates\AGENTS.md"
$skillPath = Join-Path $repoRoot "skills\pre-execution-confirmation-yct\SKILL.md"
$targetPath = Join-Path (Resolve-CodexHome -RequestedHome $CodexHome) "AGENTS.md"
$blockPattern = "(?s)" + [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)

if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    Add-Failure "Template file is missing."
}
else {
    $templateContent = [System.IO.File]::ReadAllText($templatePath, $utf8Strict)
    $templateMatches = [regex]::Matches($templateContent, $blockPattern)
    if ($templateMatches.Count -ne 1) {
        Add-Failure "The template does not contain exactly one rule block."
    }
}

if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
    Add-Failure "Skill file is missing."
}
else {
    $skillContent = [System.IO.File]::ReadAllText($skillPath, $utf8Strict)
    $skillRequirements = @(
        "# Pre-Execution Confirmation YCT",
        "## Agent Scope",
        "root, user-facing agent",
        "Sub-agents are explicitly excluded",
        "must not repeat the confirmation message or wait for user confirmation",
        "## Language Policy",
        "same language as the user's latest meaningful message",
        "If the user switches languages",
        "## When to Use",
        "## Mandatory Confirmation Format",
        "## Prohibited Before Confirmation",
        "## Authorization and Withdrawal",
        "## Scope Changes",
        "## Authorization Persistence",
        "Render the three confirmation labels in the user's latest meaningful language",
        "start, continue, agree, yes, proceed, confirm, okay, sure",
        "stop, cancel, no need",
        "Context compression, summary recovery, model changes"
    )

    foreach ($requirement in $skillRequirements) {
        if (-not $skillContent.Contains($requirement)) {
            Add-Failure "The Skill is missing this requirement: $requirement"
        }
    }
}

if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
    Add-Failure "User-level AGENTS.md was not found: $targetPath"
}
else {
    $targetContent = [System.IO.File]::ReadAllText($targetPath, $utf8Strict)
    $targetMatches = [regex]::Matches($targetContent, $blockPattern)

    if ($targetMatches.Count -eq 0) {
        Add-Failure "The user-level AGENTS.md does not contain the pre-execution confirmation rule block."
    }
    elseif ($targetMatches.Count -gt 1) {
        Add-Failure "The user-level AGENTS.md contains duplicate rule blocks."
    }
    else {
        $ruleBlock = $targetMatches[0].Value
        $ruleRequirements = @(
            "root, user-facing agent",
            "Sub-agents are explicitly excluded",
            "must not inherit, repeat, or enforce this confirmation workflow",
            "same language as the user's latest meaningful message",
            "If the user switches languages",
            "Render these three labels in the user's latest meaningful language",
            "Before the user explicitly confirms, the root agent must not call tools",
            "If the user changes, expands, or materially narrows the root-agent request before confirmation",
            "If the user changes the target, project, account, environment, or other external scope during root-agent execution",
            "After confirmation, context compression, summary recovery, model changes"
        )

        foreach ($requirement in $ruleRequirements) {
            if (-not $ruleBlock.Contains($requirement)) {
                Add-Failure "The user-level rule is missing this requirement: $requirement"
            }
        }

        foreach ($authorizationWord in @("start", "continue", "agree", "yes", "proceed", "confirm", "okay", "sure", "stop", "cancel", "no need")) {
            if (-not $ruleBlock.Contains($authorizationWord)) {
                Add-Failure "The user-level rule is missing this authorization or withdrawal word: $authorizationWord"
            }
        }

        $outsideBlock = [regex]::Replace($targetContent, $blockPattern, "")
        foreach ($pattern in $legacyUnscopedPatterns) {
            if ($outsideBlock -match $pattern) {
                Add-Failure "The user-level AGENTS.md contains a conflicting unscoped legacy confirmation rule outside the marked block."
                break
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host "INSTALL_VERIFY_FAILED"
    foreach ($failure in $failures) {
        Write-Host ("FAIL: " + $failure)
    }
    exit 1
}

Write-Host "INSTALL_VERIFY_OK"
Write-Host "The rule block, template, and Skill are complete; no duplicate block was found."
exit 0
