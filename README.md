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

Part of the connector kit series by Palo Alto AI Research Lab — see also [`whatsapp-mcp-kit`](https://github.com/tonydzi/whatsapp-mcp-kit) (published 2026-08-10: a live self-refreshing QR page that makes WhatsApp pairing actually work) and [`mcp-daemon-diet`](https://github.com/tonydzi/mcp-daemon-diet) (one shared MCP daemon per machine instead of a copy in every session - the daemon and watchdog referenced in this kit's `daemon/` folder, generalised to any MCP server) and [`agent-approval-gate`](https://github.com/tonydzi/agent-approval-gate) (once your agent can send Telegram messages, this is how it asks you for permission from there without hanging — Telegram is its default transport). Reviewing what your agent builds on top of all this? [`secondop-panel`](https://github.com/tonydzi/secondop-panel) runs every change past several model families at once instead of one. Running this setup on more than one machine? [`fleet-deploy`](https://github.com/tonydzi/fleet-deploy) rolls the patches and the daemon config to every box and refuses to call it done until each one reads the fact back. Questions / broken step? Open an issue — we answer within 24h.

---


> **Publishing your own internals?** This repo was sanitized for release with
> [`oss-publish`](https://github.com/tonydzi/oss-publish) — our substitution pipeline:
> personal data is replaced by plausible fakes of the same shape (never `<REDACTED>`),
> and a fail-closed gate re-scans the whole tree before the push. Free, MIT.

<!--kits-series:start-->

## 🧰 Connector & Ops Kits

Eight kits, all published 2026-08-10, each lifted out of the same live fleet after it
survived production rather than written as a demo. They are independent: take one, ignore
the rest. All stdlib-only Python, all free.

| kit | what it solves |
|---|---|
| [`telegram-mcp-kit`](https://github.com/tonydzi/telegram-mcp-kit) | Connect your agent to your own Telegram account in ~15 minutes, with the production patches and every gotcha |
| [`whatsapp-mcp-kit`](https://github.com/tonydzi/whatsapp-mcp-kit) | Link WhatsApp, using a live self-refreshing QR page that makes pairing actually work |
| [`mcp-daemon-diet`](https://github.com/tonydzi/mcp-daemon-diet) | One shared MCP daemon per machine instead of a stdio copy in every session, with a watchdog that will not blind your live sessions |
| [`agent-approval-gate`](https://github.com/tonydzi/agent-approval-gate) | Your agent needs a human's OK and nobody is at the terminal: the ask goes to a messenger, the answer comes back into the run |
| [`fleet-deploy`](https://github.com/tonydzi/fleet-deploy) | Roll a fix to N machines and prove it landed on each one: canary waves and a verify that must read a fact back |
| [`secondop-panel`](https://github.com/tonydzi/secondop-panel) | Nobody reviews themselves, and one reviewer model is one blind spot: fan a change out to several model families with quorum and honest skips |
| [`oss-publish`](https://github.com/tonydzi/oss-publish) | Open up internal work without leaking it: plausible substitutions of the same shape, then a fail-closed gate over the whole tree |
| [`llm-spend-audit`](https://github.com/tonydzi/llm-spend-audit) | What your own wiring charges on every session, and which paid subscriptions are going undrawn |

<!--kits-series:end-->

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

<!-- CONTACT-FOOTER -->
## About & contact

Built and battle-tested at **Palo Alto AI Research Lab** — a fleet of Claude Code machines
running 24/7 as a second brain and synthetic cofounder. This kit is our own Telegram setup,
lifted out after it survived production, not written as a demo.

Stuck on a step, or a gotcha here does not match what you hit? Tell us — a broken step
report is worth more to this repo than a star.

- 👤 Author: **Anton Dziatkovskii** — Telegram [@tonydzi](https://t.me/tonydzi) · WhatsApp [+1 341 222 9178](https://wa.me/13412229178) · X [@Tony_Stef_](https://x.com/Tony_Stef_)
- 📣 Channels: [@ClawRus](https://t.me/ClawRus) (RU) · [@ClawEng](https://t.me/ClawEng) (EN)
- 🌐 [palo-alto.ai](https://palo-alto.ai) · [Palo Alto AI Research Lab](https://github.com/tonydzi)
- 🧪 **Engineers: want to test-drive this setup?** Message me — I hand out free starter seeds to engineers who test and report back.
