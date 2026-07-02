---
name: codex-history-picker
description: List and inspect local Codex Desktop chat history after model, CC Switch provider, API-key, or login changes. Use when a user wants to recover, search, choose, or continue from previous Codex conversations by title or session id without modifying the Codex sidebar or SQLite state.
---

# Codex History Picker

Use this skill to retrieve local Codex conversation titles and selected transcript text safely. Prefer this workflow when the sidebar does not show old conversations after switching models/providers.

## Rules

- Do not modify `state_5.sqlite`.
- Do not attempt to rebuild or relabel Codex Desktop sidebar rows.
- Start with titles only; read transcript text only after the user chooses a title or id.
- Keep output compact. Listing titles is cheap; showing full transcripts can consume many tokens.
- Treat local history as sensitive. Redact API keys and tokens unless the user explicitly asks for raw text.

## Locate The CLI

Try these commands in order until one exists:

```bash
command -v codex-history
command -v codex-history-guard
test -x "$HOME/.local/bin/codex-history" && echo "$HOME/.local/bin/codex-history"
test -x "$HOME/Library/Application Support/CodexHistoryGuard/bin/codex-history-guard" && echo "$HOME/Library/Application Support/CodexHistoryGuard/bin/codex-history-guard"
```

If none exists, tell the user to install from:

```bash
git clone https://github.com/peter9237/codex-history-guard.git
cd codex-history-guard
chmod +x install.sh scripts/*
./install.sh
```

## List Titles

Run:

```bash
codex-history titles --limit 50
```

If `codex-history` is not on `PATH`, use the discovered absolute path.

Return the output to the user as a numbered list with title, short id, and time. Do not read transcript bodies during this step.

## Search

Run:

```bash
codex-history search "keyword" --limit 20
```

Use search when the user provides a project name, topic, or phrase instead of asking for recent titles.

## Show A Selected Conversation

After the user chooses a number or id, run:

```bash
codex-history show <number-or-id-prefix> --limit 40
```

If the user asks for more, increase `--limit` gradually. Avoid dumping an entire long session unless explicitly requested.

## Recommended Prompt To User

When helping a user recover context, say:

```text
I can list your local Codex conversation titles first. Pick a number or id, and I will show only that conversation's relevant text.
```

## Fallback

If the vault has not been built yet, run:

```bash
codex-history snapshot --skip-sqlite
codex-history titles --limit 50
```

This creates a local text index from `${CODEX_HOME:-$HOME/.codex}/sessions` without copying authentication files.
