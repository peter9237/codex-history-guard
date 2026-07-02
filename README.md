# Codex History Guard

Local, read-first access to Codex Desktop chat history.

When Codex Desktop appears to lose old conversations after switching models, CC Switch providers, API keys, or login modes, the safest recovery path is usually not to rewrite the sidebar. Instead, list local conversation titles, choose the relevant thread, and show the transcript in the current conversation.

This tool reads local files only:

- no model API calls
- no token use beyond whatever text you paste/show to the model
- no upload of chat history
- no copy of `auth.json`
- no API keys, OAuth tokens, or cookies copied into the vault
- no sidebar SQLite edits for normal title/search/show usage

## Install

```bash
git clone https://github.com/peter9237/codex-history-guard.git
cd codex-history-guard
chmod +x install.sh scripts/*
./install.sh
```

The installer creates:

- `~/.local/bin/codex-history`
- `~/.local/bin/codex-history-guard`
- `${CODEX_HOME:-~/.codex}/skills/codex-history-picker`

If `~/.local/bin` is not on your `PATH`, add:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Quick Use

List recent conversation titles:

```bash
codex-history titles --limit 50
```

Example:

```text
01. 2026-07-02T01:41:31.829Z  019f1d36  我的对话咋都没呢
02. 2026-07-01T09:48:23.893Z  019f12ae  退出 Clash Verge 进程
```

Show a selected conversation by number from the latest title list:

```bash
codex-history show 2 --limit 40
```

Or by session id prefix:

```bash
codex-history show 019f12ae --limit 40
```

Search titles and transcript text:

```bash
codex-history search "cc switch" --limit 20
```

The output is redacted by default for common API key and token patterns.

## Prompt For A New Model

After switching to another model/provider, tell the current model:

```text
Use codex-history-picker. First run:
codex-history titles --limit 50

Only list titles and IDs. I will choose one. Then run:
codex-history show <id-or-number> --limit 40

Do not modify state_5.sqlite or any Codex sidebar database.
```

## What Gets Indexed

The tool indexes local Codex history from:

```text
${CODEX_HOME:-~/.codex}/sessions/**/*.jsonl
${CODEX_HOME:-~/.codex}/session_index.jsonl
${CODEX_HOME:-~/.codex}/history.jsonl
```

The default local vault is:

```text
~/.codex-history-vault
```

Create or refresh the vault manually:

```bash
codex-history snapshot --skip-sqlite
```

## Commands

```bash
codex-history titles --limit 50
codex-history search "keyword" --limit 20
codex-history show 019f1d36 --limit 40
codex-history snapshot --skip-sqlite
codex-history mirror --skip-sqlite
```

`titles`, `search`, and `show` are the recommended commands for day-to-day use because they do not modify Codex Desktop sidebar state.

## Optional Background Archive

On macOS, install the background archive job:

```bash
./scripts/install-launchd.sh
```

This creates a user LaunchAgent that runs every 5 minutes:

```bash
codex-history-guard mirror --skip-sqlite
```

It archives and backfills session files. It does not need model tokens.

Uninstall:

```bash
./scripts/uninstall-launchd.sh
```

## About Sidebar Recovery

Codex Desktop sidebars are backed by `state_5.sqlite`, and rows are filtered by provider. A single thread row has one `model_provider`, so trying to make the same history appear in both OpenAI and custom providers can cause confusing UI behavior.

For that reason, this project recommends the safe flow:

1. list titles with `codex-history titles`
2. choose a conversation
3. show text with `codex-history show`
4. let the current model use that text as context

Advanced SQLite repair commands may exist in the CLI for local recovery, but they are not the recommended public workflow. Back up before using them.

## Skill

The repository includes a Codex skill:

```text
skill/codex-history-picker/SKILL.md
```

The installer copies it to:

```text
${CODEX_HOME:-~/.codex}/skills/codex-history-picker
```

Use it by asking:

```text
Use codex-history-picker to list my recent Codex conversation titles.
```

## Privacy

Your vault contains chat text and may contain sensitive project context. Keep it local or store it only in a private, trusted location.

The tool does not copy:

- `auth.json`
- API keys
- OAuth tokens
- cookies

## License

MIT
