# Codex History Guard

一个本地的 Codex Desktop 聊天记录同步与归档工具。

当你使用 CC Switch 切换模型、切换 provider，或者在 Codex 里来回切换 API Key / OAuth 登录方式时，Codex 的聊天列表有时会像“消失”了一样。Codex History Guard 的作用是把本机聊天记录持续同步到一个独立的本地归档库里，让你随时可以搜索、查看、恢复。

它只读取本机文件：

- 不调用任何模型 API
- 不消耗 token
- 不上传聊天内容
- 不复制 `auth.json`
- 不保存 API Key、OAuth token 或 cookie
- 后台同步默认每 5 分钟运行一次

默认归档目录：

```text
~/.codex-history-vault
```

## 适合谁

如果你遇到这些情况，这个工具会有用：

- 用 CC Switch 切换模型后，Codex 里的旧聊天记录看不到了
- 从 ChatGPT 登录切到 API Key 登录后，聊天列表变了
- 想在不同 Codex 配置状态之间保留一份统一可搜索的聊天归档
- 想在切换模型/账号前后自动保存对话记录

## 会归档什么

默认会同步：

- `~/.codex/sessions/`
- `~/.codex/session_index.jsonl`
- `~/.codex/history.jsonl`
- `~/.codex/attachments/`
- `~/.codex/generated_images/`

完整快照模式还可以额外备份：

- `~/.codex/sqlite/*.sqlite`

后台自动同步使用轻量模式 `--skip-sqlite`，不会每 5 分钟复制 SQLite 数据库，避免不必要的磁盘占用。

## macOS 自动同步安装

```bash
git clone https://github.com/peter9237/codex-history-guard.git
cd codex-history-guard
chmod +x scripts/*
./scripts/install-launchd.sh
```

安装后会创建一个用户级 LaunchAgent，每 5 分钟运行一次：

```bash
codex-history-guard snapshot --skip-sqlite
```

也就是说，你切换 CC Switch 或 API 登录方式后，不需要手动输入命令，最多等 5 分钟，当前 Codex 数据目录里出现的新聊天记录就会被同步到归档库。

自定义归档目录或同步间隔：

```bash
CODEX_HISTORY_VAULT="$HOME/Documents/codex-history" \
CODEX_HISTORY_INTERVAL_SECONDS=600 \
./scripts/install-launchd.sh
```

## 手动使用

轻量同步当前 Codex 记录：

```bash
./scripts/codex-history-guard snapshot --skip-sqlite
```

完整同步，包括 SQLite 数据库快照：

```bash
./scripts/codex-history-guard snapshot
```

列出已归档会话：

```bash
./scripts/codex-history-guard list
```

搜索聊天记录：

```bash
./scripts/codex-history-guard search "cc switch"
```

查看某个会话全文：

```bash
./scripts/codex-history-guard show 019f1b8e
```

把某个会话恢复到当前 Codex home：

```bash
./scripts/codex-history-guard restore-session 019f1b8e
```

如果恢复后 Codex Desktop 的侧边栏没有马上刷新，重启 Codex Desktop 即可。

## 包装切换命令

如果你是在终端里切换模型或配置，可以用 `codex-safe-switch` 包一层。它会在切换前后各同步一次：

```bash
./scripts/codex-safe-switch cc-switch use openai
```

## 卸载后台同步

```bash
./scripts/uninstall-launchd.sh
```

卸载脚本只会移除 LaunchAgent，不会删除你的聊天归档库。

## 隐私说明

归档库里会包含聊天文本、附件和项目上下文，因此它本身是敏感数据。建议保留在本机，或者只同步到你信任的私有备份位置。

工具不会复制：

- `~/.codex/auth.json`
- API Key
- OAuth token
- cookie

## 多个 Codex Home

如果某个切换工具改变了 `CODEX_HOME`，可以把多个 Codex home 都加入同步源：

```bash
./scripts/codex-history-guard snapshot \
  --source "$HOME/.codex" \
  --source "$HOME/.codex-openai" \
  --source "$HOME/.codex-deepseek" \
  --skip-sqlite
```

## English Summary

Codex History Guard archives and indexes local Codex Desktop chat history across model, provider, CC Switch, and API-key/OAuth login changes. It reads local files only, does not call model APIs, does not consume tokens, and does not copy `auth.json` or API keys.

## License

MIT
