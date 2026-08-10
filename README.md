# telegram-mcp-kit

Connect Claude (Claude Code / Claude Desktop / Codex — any MCP client) to **your own Telegram account** so it can read your chats and send replies. This kit is everything we wish we had on day one: it took us several hours and many broken iterations to get a stable setup; with this kit it should take you ~15 minutes.

Built and battle-tested at [Palo Alto AI Research Lab](https://github.com/tonydzi/Palo-Alto-AI-Research-Lab) — our Claude fleet reads and writes Telegram through exactly this setup, every day, across 5 machines.

## What you get

1. **A working setup path** on top of the excellent upstream server [`chigwell/telegram-mcp`](https://github.com/chigwell/telegram-mcp) (MTProto user-account, pure Python, no TDLib build pain).
2. **[`PROMPT.md`](PROMPT.md)** — a copy-paste prompt you give to Claude Code or Codex, and it performs the whole installation for you, including the gotchas.
3. **Patches** we run in production, pinned to upstream commit `a008ac2` (apply cleanly there; run `git checkout a008ac2` after cloning, or resolve conflicts yourself on a newer HEAD):
   - [`patches/0001-transport-sse-env.patch`](patches/0001-transport-sse-env.patch) — run the server as **one shared HTTP/SSE daemon per machine** instead of a stdio copy per session. With 10+ parallel agent sessions the stdio model wasted us ~2.7 GB RAM on duplicate Telegram clients; one daemon fixes that. Opt-in via `MCP_TRANSPORT=sse` (+ `MCP_HOST`/`MCP_PORT`), default behavior unchanged. **Update:** current upstream HEAD now ships env-selectable transport natively — on latest upstream skip this patch and just set the env vars; the daemon + watchdog in this kit work the same.
   - [`patches/0002-extra-tools-multiaccount.patch`](patches/0002-extra-tools-multiaccount.patch) — tools we found missing in daily agent work: `search_dialogs` (find private groups by title, not only @usernames), `search_messages_global`, `get_new_messages_since` (incremental polling for watchers), `resolve_message_link` (t.me link → message + context), `get_unread_mentions`, `find_media`, plus an `account:` parameter on tools for **multi-account** setups and an incoming-message watcher configured by env vars (`TELEGRAM_WATCH_CHATS`, `TELEGRAM_PRINCIPAL_IDS`).
4. **[`daemon/`](daemon/)** — Windows launcher + watchdog for the shared daemon (auto-restart with evidence logging; a naive TCP-probe watchdog caused us worse outages than the crashes it "fixed" — see GOTCHAS).
5. **[`docs/GOTCHAS.md`](docs/GOTCHAS.md)** — every trap we paid hours for, so you don't.
6. **[`docs/SECURITY.md`](docs/SECURITY.md)** — a user-account MCP is your *whole* Telegram; read this before pasting a session string anywhere.

## Quickstart (manual)

```powershell
# 1. api_id / api_hash from https://my.telegram.org (API development tools)

# 2. clone + install (Windows shown; Linux/macOS identical minus paths)
git clone https://github.com/chigwell/telegram-mcp.git C:\mcp\telegram-mcp
cd C:\mcp\telegram-mcp
uv sync

# 3. our patches (optional but recommended)
git apply path\to\telegram-mcp-kit\patches\0001-transport-sse-env.patch
git apply path\to\telegram-mcp-kit\patches\0002-extra-tools-multiaccount.patch

# 4. one-time login -> session STRING (QR or phone+code)
uv run session_string_generator.py

# 5. register in Claude Code (stdio, simplest)
claude mcp add telegram --scope user `
  --env TELEGRAM_API_ID=YOUR_API_ID `
  --env TELEGRAM_API_HASH=YOUR_API_HASH `
  --env TELEGRAM_SESSION_STRING=YOUR_SESSION_STRING `
  -- uv --directory C:\mcp\telegram-mcp run main.py C:\TG-Media
```

The trailing `C:\TG-Media` is the **allowed-roots positional argument** — without it every file tool (`download_media`, `send_file`) silently refuses to work. That one line cost us an evening.

Running many parallel Claude sessions? Switch to the shared daemon: see [`daemon/README.md`](daemon/README.md).

## The lazy path

Open Claude Code, paste the contents of [`PROMPT.md`](PROMPT.md), answer two questions (api_id/api_hash), scan one QR. Done.

## Why user-account (MTProto) and not a bot?

A Bot API bot cannot read your existing personal chat history or old media. A user-account server sees what *you* see — which is the entire point of giving your assistant your Telegram. It is also why you must read [`docs/SECURITY.md`](docs/SECURITY.md).

## License

Patches and docs: Apache-2.0 (same as upstream `chigwell/telegram-mcp`). Upstream code is not vendored here — we ship patches against it and credit the original authors.

---

Part of the connector kit series by Palo Alto AI Research Lab — see also [`whatsapp-mcp-kit`](https://github.com/tonydzi/whatsapp-mcp-kit) (published 2026-08-10: a live self-refreshing QR page that makes WhatsApp pairing actually work). Questions / broken step? Open an issue — we answer within 24h.

---

<!--ecosystem-map:start-->

## 🧩 One piece of a working system

This repository is one piece lifted out of a live operation: one non-technical founder, an AI
cofounder, and a fleet of machines that reach consensus with each other and wake the human only
for money or the irreversible. It was extracted after it survived production, not written as a
demo — and it runs on its own: nothing here phones home to the rest.

**See how the whole thing fits together → [SYSTEM.md](https://github.com/tonydzi/Palo-Alto-AI-Research-Lab/blob/main/SYSTEM.md)**

Its closest neighbours in the **connectors** layer: [`whatsapp-mcp-kit`](https://github.com/tonydzi/whatsapp-mcp-kit) · [`mcp-daemon-diet`](https://github.com/tonydzi/mcp-daemon-diet)

<!--ecosystem-map:end-->

## AI contributors

This project is built by a human + AI team, and the git log says so: Claude writes most of
the code, Codex and Grok review it, Gemini feeds the research. Each is credited on a commit
**only if its output changed that commit's content** — no decorative credits. Lab-wide
policy, one source for every repo: [AI-CONTRIBUTORS.md](https://github.com/tonydzi/.github/blob/main/AI-CONTRIBUTORS.md).
