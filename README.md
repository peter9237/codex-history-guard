# Codex History Guard

Codex History Guard keeps Codex Desktop chat history available when switching
models, providers, CC Switch profiles, or API-key/OAuth login modes.

It reads local files only. It does not call model APIs, does not consume tokens,
and intentionally does not copy `auth.json` or API keys.

## What It Archives

- `~/.codex/sessions/`
- `~/.codex/session_index.jsonl`
- `~/.codex/history.jsonl`
- `~/.codex/attachments/`
- `~/.codex/generated_images/`
- Optional SQLite snapshots from `~/.codex/sqlite/*.sqlite`

Default vault:

```text
~/.codex-history-vault
```

## Install Automatic Sync On macOS

```bash
git clone https://github.com/peter9237/codex-history-guard.git
cd codex-history-guard
chmod +x scripts/*
./scripts/install-launchd.sh
```

The LaunchAgent runs every 5 minutes using:

```bash
codex-history-guard snapshot --skip-sqlite
```

This lightweight mode avoids repeated SQLite snapshots and is suitable for
background use.

To customize the vault or interval:

```bash
CODEX_HISTORY_VAULT="$HOME/Documents/codex-history" \
CODEX_HISTORY_INTERVAL_SECONDS=600 \
./scripts/install-launchd.sh
```

## Manual Usage

Snapshot current Codex history:

```bash
./scripts/codex-history-guard snapshot --skip-sqlite
```

Full snapshot, including SQLite database backup:

```bash
./scripts/codex-history-guard snapshot
```

List archived threads:

```bash
./scripts/codex-history-guard list
```

Search archived transcripts:

```bash
./scripts/codex-history-guard search "cc switch"
```

Show one transcript:

```bash
./scripts/codex-history-guard show 019f1b8e
```

Restore one session JSONL into the current Codex home:

```bash
./scripts/codex-history-guard restore-session 019f1b8e
```

If the Codex thread list does not refresh immediately after restore, restart
Codex Desktop.

## Wrap A Switch Command

If you switch profiles from a terminal, wrap the command so history is captured
before and after the switch:

```bash
./scripts/codex-safe-switch cc-switch use openai
```

## Uninstall Automatic Sync

```bash
./scripts/uninstall-launchd.sh
```

The uninstall script removes the LaunchAgent only. It does not delete your
history vault.

## Privacy Notes

The vault contains chat transcripts and may contain sensitive project context.
Keep it local unless you intentionally want to back it up somewhere private.

The tool never copies:

- `~/.codex/auth.json`
- API keys
- OAuth tokens
- cookies

## Multiple Codex Homes

If a switcher changes `CODEX_HOME`, add each Codex home as a source:

```bash
./scripts/codex-history-guard snapshot \
  --source "$HOME/.codex" \
  --source "$HOME/.codex-openai" \
  --source "$HOME/.codex-deepseek" \
  --skip-sqlite
```

## License

MIT
