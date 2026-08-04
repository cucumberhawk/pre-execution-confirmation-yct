[CmdletBinding()]
param(
    [string]$CodexHome
)

$ErrorActionPreference = "Stop"

$startMarker = "<!-- BEGIN CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->"
$endMarker = "<!-- END CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->"
$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)

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
        throw "Unable to determine the current user profile; installation was not performed."
    }

    return (Join-Path $userProfile ".codex")
}

function Get-BackupPath {
    param([string]$Target)

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $candidate = "$Target.backup.$timestamp"
    $suffix = 1

    while (Test-Path -LiteralPath $candidate) {
        $candidate = "$Target.backup.$timestamp-$suffix"
        $suffix++
    }

    return $candidate
}

function Test-ObviousCredentialPattern {
    param([string]$Content)

    $patterns = @(
        "-----BEGIN [^-]+ PRIVATE KEY-----",
        "(?i)\b(?:AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,})\b",
        "(?i)\b(?:api[_-]?key|token|password|cookie)\s*[:=]\s*\S{8,}",
        "(?i)\bBearer\s+[A-Za-z0-9._~+/=-]{16,}"
    )

    foreach ($pattern in $patterns) {
        if ($Content -match $pattern) {
            return $true
        }
    }

    return $false
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $repoRoot "templates\AGENTS.md"
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    throw "The rule template does not exist; installation was not performed."
}

$userCodexHome = Resolve-CodexHome -RequestedHome $CodexHome
$targetPath = Join-Path $userCodexHome "AGENTS.md"

Write-Host "Target user-level configuration: $targetPath"
Write-Host "The script only merges the explicitly marked rule block. It does not access the network or modify project source."
$confirmation = Read-Host "Type INSTALL to continue; type anything else to cancel"
if ($confirmation -ine "INSTALL") {
    Write-Host "Canceled. No files were changed."
    exit 2
}

$templateContent = [System.IO.File]::ReadAllText($templatePath, $utf8Strict)
$blockPattern = "(?s)" + [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)
$templateMatches = [regex]::Matches($templateContent, $blockPattern)
if ($templateMatches.Count -ne 1) {
    throw "The rule template must contain exactly one complete marked block; installation was not performed."
}

$ruleBlock = $templateMatches[0].Value.Trim()
$targetExists = Test-Path -LiteralPath $targetPath -PathType Leaf
$existingContent = ""

if ($targetExists) {
    $existingContent = [System.IO.File]::ReadAllText($targetPath, $utf8Strict)
    if (Test-ObviousCredentialPattern -Content $existingContent) {
        throw "The target AGENTS.md contains a suspected credential pattern. Installation stopped to avoid copying or overwriting sensitive content; review it manually first."
    }
}

$existingMatches = [regex]::Matches($existingContent, $blockPattern)
if ($existingMatches.Count -gt 1) {
    throw "The target AGENTS.md contains multiple rule blocks. Installation stopped to avoid damaging user content."
}

if (-not (Test-Path -LiteralPath $userCodexHome -PathType Container)) {
    New-Item -ItemType Directory -Path $userCodexHome -Force | Out-Null
}

if ($targetExists) {
    $backupPath = Get-BackupPath -Target $targetPath
    Copy-Item -LiteralPath $targetPath -Destination $backupPath
    Write-Host "Backup created: $backupPath"
}

if ($existingMatches.Count -eq 1) {
    $newContent = [regex]::Replace(
        $existingContent,
        $blockPattern,
        [System.Text.RegularExpressions.MatchEvaluator]{
            param($match)
            $ruleBlock
        },
        1
    )
}
else {
    if ([string]::IsNullOrEmpty($existingContent)) {
        $separator = ""
    }
    elseif ($existingContent.EndsWith("`r`n") -or $existingContent.EndsWith("`n")) {
        $separator = [Environment]::NewLine
    }
    else {
        $separator = [Environment]::NewLine + [Environment]::NewLine
    }

    $newContent = $existingContent + $separator + $ruleBlock + [Environment]::NewLine
}

[System.IO.File]::WriteAllText($targetPath, $newContent, [System.Text.UTF8Encoding]::new($false))
Write-Host "The pre-execution confirmation rule was installed in the user-level AGENTS.md."
exit 0
