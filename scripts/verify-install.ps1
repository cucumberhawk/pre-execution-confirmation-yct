[CmdletBinding()]
param(
    [string]$CodexHome
)

$ErrorActionPreference = "Stop"

$startMarker = "<!-- BEGIN CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->"
$endMarker = "<!-- END CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->"
$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$failures = New-Object System.Collections.Generic.List[string]

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
        throw "无法确定当前用户目录。"
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
    Add-Failure "缺少模板文件。"
}
else {
    $templateContent = [System.IO.File]::ReadAllText($templatePath, $utf8Strict)
    $templateMatches = [regex]::Matches($templateContent, $blockPattern)
    if ($templateMatches.Count -ne 1) {
        Add-Failure "模板规则区块数量不是 1。"
    }
}

if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
    Add-Failure "缺少 Skill 文件。"
}
else {
    $skillContent = [System.IO.File]::ReadAllText($skillPath, $utf8Strict)
    $skillRequirements = @(
        "# 执行前确认",
        "## 强制确认格式",
        "## 确认前禁止事项",
        "## 授权与撤回",
        "## 范围变化",
        "## 授权持续时间",
        "意图理解：",
        "想法：",
        "是否开始执行？",
        "开始、继续、同意、可以、执行、确认、好的、是的",
        "停止、取消、不用了",
        "上下文压缩、摘要恢复、模型切换"
    )

    foreach ($requirement in $skillRequirements) {
        if (-not $skillContent.Contains($requirement)) {
            Add-Failure "Skill 缺少要求：$requirement"
        }
    }
}

if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
    Add-Failure "未找到用户级 AGENTS.md：$targetPath"
}
else {
    $targetContent = [System.IO.File]::ReadAllText($targetPath, $utf8Strict)
    $targetMatches = [regex]::Matches($targetContent, $blockPattern)

    if ($targetMatches.Count -eq 0) {
        Add-Failure "用户级 AGENTS.md 中不存在执行前确认规则区块。"
    }
    elseif ($targetMatches.Count -gt 1) {
        Add-Failure "用户级 AGENTS.md 中存在重复规则区块。"
    }
    else {
        $ruleBlock = $targetMatches[0].Value
        $ruleRequirements = @(
            "意图理解：",
            "想法：",
            "是否开始执行？",
            "确认前不得调用工具、读写文件、搜索、浏览、生成交付物、发送消息或创建任务",
            "用户在确认前修改、增加或实质性缩小请求",
            "如果用户在执行中改变目标、项目、账号、环境或其他外部对象范围",
            "上下文压缩、摘要恢复、模型切换"
        )

        foreach ($requirement in $ruleRequirements) {
            if (-not $ruleBlock.Contains($requirement)) {
                Add-Failure "用户级规则缺少要求：$requirement"
            }
        }

        foreach ($authorizationWord in @("开始", "继续", "同意", "可以", "执行", "确认", "好的", "是的", "停止", "取消", "不用了")) {
            if (-not $ruleBlock.Contains($authorizationWord)) {
                Add-Failure "用户级规则缺少授权或撤回词：$authorizationWord"
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
Write-Host "规则区块、模板和 Skill 完整且未发现重复区块。"
exit 0
