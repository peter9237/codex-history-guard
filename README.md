# Codex History Guard

一个本地的 Codex Desktop 聊天记录同步、归档与回填工具。

当你使用 CC Switch 切换模型、切换 provider，或者在 Codex 里来回切换 API Key / OAuth 登录方式时，Codex 的聊天列表有时会像“消失”了一样。Codex History Guard 的作用是把本机聊天记录持续同步到一个独立的本地归档库里，并在后台把归档库里的记录回填到当前 Codex home，让你随时可以搜索、查看、恢复。

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

后台自动同步使用轻量模式 `mirror --skip-sqlite`，不会每 5 分钟复制 SQLite 数据库，避免不必要的磁盘占用。

如果你希望切换 provider 后 Codex Desktop 侧边栏也能看到旧对话，需要同时同步 `state_5.sqlite` 里的 `threads` 索引：

```bash
./scripts/codex-history-guard mirror --skip-sqlite --sync-state-db
```

这个模式会先备份 `state_5.sqlite`，再从 `sessions/*.jsonl` 补齐缺失线程，并把侧边栏线程的 `model_provider` 重标成当前 Codex provider。当前 provider 会优先从 `config.toml` 判断；如果你使用 CC Switch，则会参考 CC Switch 当前选中的 Codex provider。这样在 CC Switch/custom 和 OpenAI 之间切换时，侧边栏不会因为 provider 过滤而变空。

## macOS 自动同步安装

```bash
git clone https://github.com/peter9237/codex-history-guard.git
cd codex-history-guard
chmod +x scripts/*
./scripts/install-launchd.sh
```

安装后会创建一个用户级 LaunchAgent，每 5 分钟运行一次：

```bash
codex-history-guard mirror --skip-sqlite
```

也就是说，你切换 CC Switch 或 API 登录方式后，不需要手动输入命令，最多等 5 分钟：

- 当前 Codex home 里出现的新聊天记录会被同步到归档库
- 归档库里已有但当前 Codex home 缺失的记录会被回填回来
- Codex Desktop 的 SQLite 侧边栏索引会被补齐并按当前 provider 重标

如果 Codex Desktop 侧边栏没有马上刷新，重启 Codex Desktop 后通常就能看到已回填的记录。

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

轻量同步并回填到当前 Codex home：

```bash
./scripts/codex-history-guard mirror --skip-sqlite
```

同步文件、回填并修复侧边栏索引：

```bash
./scripts/codex-history-guard mirror --skip-sqlite --sync-state-db
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

如果你是在终端里切换模型或配置，可以用 `codex-safe-switch` 包一层。它会在切换前后各执行一次轻量同步和回填：

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
./scripts/codex-history-guard mirror \
  --source "$HOME/.codex" \
  --source "$HOME/.codex-openai" \
  --source "$HOME/.codex-deepseek" \
  --skip-sqlite
```

## English Summary

Codex History Guard archives and indexes local Codex Desktop chat history across model, provider, CC Switch, and API-key/OAuth login changes. It reads local files only, does not call model APIs, does not consume tokens, and does not copy `auth.json` or API keys.

## License

MIT
