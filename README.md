# pre-execution-confirmation-yct

这是一个可公开分享、可复用的 Codex 规则分发项目，用于在代理执行工具调用、文件操作、搜索、浏览或其他外部动作前，先向用户确认执行范围。

本项目提供三类内容：

- `skills/pre-execution-confirmation-yct/SKILL.md`：可复用的 Codex Skill 说明。
- `templates/AGENTS.md`：可复制到用户级 `AGENTS.md` 的规则区块。
- `scripts/`：本机安装和验证脚本。

项目根目录下已有的 `tmp/` 与 `RECOVERY_STATUS.md` 是此前恢复过程中保留的用户内容，不是本规则分发功能的运行依赖，也不会被安装脚本修改。

## 适用范围

适用于希望代理在执行以下动作前先获得明确授权的个人或团队：

- 调用工具、读写文件、搜索或浏览；
- 生成交付物、发送消息、创建任务；
- 修改代码、配置或其他外部状态。

这套规则是用户级行为约束模板，不是插件，不会自动安装到任何人的机器上，也不会替代具体项目的安全策略。

## 目录结构

```text
skills/
└── pre-execution-confirmation-yct/
    └── SKILL.md
templates/
└── AGENTS.md
scripts/
├── install-global-rule.ps1
└── verify-install.ps1
CHANGELOG.md
LICENSE
README.md
.gitignore
```

## 安装方式

安装脚本只操作本机用户级配置，不连接网络或服务器。目标文件为：

1. `CODEX_HOME\AGENTS.md`（如果设置了 `CODEX_HOME`）；
2. 否则为当前 Windows 用户目录下的 `.codex\AGENTS.md`。

在项目根目录打开 PowerShell，运行：

```powershell
.\scripts\install-global-rule.ps1
```

脚本会先显示目标路径并要求输入 `INSTALL`。如果目标 `AGENTS.md` 已存在，脚本会先创建带时间戳的备份，然后只合并带明确标记的规则区块。重复运行不会重复追加规则区块。

安装脚本不会修改当前项目源码、工具包快照、图片或其他项目文件。

## 验证方式

安装后运行：

```powershell
.\scripts\verify-install.ps1
```

验证脚本只读检查：

- 用户级 `AGENTS.md` 是否存在；
- 规则开始/结束标记是否各出现一次；
- 规则是否包含意图、想法、确认问题、授权词、撤回词和范围变化要求；
- 本项目的 Skill 和模板文件是否完整；
- 是否出现重复的规则区块。

验证脚本不会执行安装，也不会打印 `AGENTS.md` 的正文。

## 卸载方式

卸载时只删除以下标记之间的内容，不要删除用户 `AGENTS.md` 中的其他内容：

```text
<!-- BEGIN CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->
...
<!-- END CODEX_PRE_EXECUTION_CONFIRMATION_RULE -->
```

安装脚本创建的备份文件应保留，直到确认卸载或恢复结果正确。不要使用递归删除命令处理用户配置目录。

## 安全说明

- 安装脚本默认要求交互式确认，不会静默覆盖用户配置。
- 目标文件存在时会先生成时间戳备份。
- 脚本只合并明确标记的规则区块，保留区块外的用户内容。
- 脚本不会联网、连接服务器、安装插件或修改当前项目源码。
- 脚本不会输出、复制或提交密码、Token、API Key、Cookie、私钥或其他隐私信息。
- 本项目不包含任何真实凭据；请勿把用户级 `AGENTS.md`、备份文件或环境文件直接提交到公开仓库。
- 规则要求确认的是“是否开始执行”；用户改变目标、范围或约束时必须重新确认。

## 发布到 GitHub

发布前建议：

1. 复核 `git diff` 和文件清单；
2. 确认没有 `.env`、备份配置、凭据或本机路径；
3. 运行文档和 PowerShell 静态验证；
4. 在确认项目边界后初始化或关联远程仓库；
5. 使用清晰的初始提交，例如 `feat: publish pre-execution confirmation rule bundle`；
6. 发布后再根据需要创建版本标签。

本地安装脚本不会自动初始化 Git、创建提交或推送到 GitHub。
