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
        throw "无法确定当前用户目录，未执行安装。"
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
    throw "规则模板不存在，未执行安装。"
}

$userCodexHome = Resolve-CodexHome -RequestedHome $CodexHome
$targetPath = Join-Path $userCodexHome "AGENTS.md"

Write-Host "目标用户级配置：$targetPath"
Write-Host "脚本只会合并明确标记的规则区块，不会联网或修改项目源码。"
$confirmation = Read-Host "输入 INSTALL 继续，输入其他内容取消"
if ($confirmation -ine "INSTALL") {
    Write-Host "已取消，未修改任何文件。"
    exit 2
}

$templateContent = [System.IO.File]::ReadAllText($templatePath, $utf8Strict)
$blockPattern = "(?s)" + [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)
$templateMatches = [regex]::Matches($templateContent, $blockPattern)
if ($templateMatches.Count -ne 1) {
    throw "规则模板必须包含且只能包含一个完整标记区块，未执行安装。"
}

$ruleBlock = $templateMatches[0].Value.Trim()
$targetExists = Test-Path -LiteralPath $targetPath -PathType Leaf
$existingContent = ""

if ($targetExists) {
    $existingContent = [System.IO.File]::ReadAllText($targetPath, $utf8Strict)
    if (Test-ObviousCredentialPattern -Content $existingContent) {
        throw "目标 AGENTS.md 包含疑似凭据格式。为避免复制或覆盖敏感内容，安装已停止；请先人工审查。"
    }
}

$existingMatches = [regex]::Matches($existingContent, $blockPattern)
if ($existingMatches.Count -gt 1) {
    throw "目标 AGENTS.md 已包含多个规则区块。为避免破坏用户内容，安装已停止。"
}

if (-not (Test-Path -LiteralPath $userCodexHome -PathType Container)) {
    New-Item -ItemType Directory -Path $userCodexHome -Force | Out-Null
}

if ($targetExists) {
    $backupPath = Get-BackupPath -Target $targetPath
    Copy-Item -LiteralPath $targetPath -Destination $backupPath
    Write-Host "已创建备份：$backupPath"
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
Write-Host "执行前确认规则已安装到用户级 AGENTS.md。"
exit 0
