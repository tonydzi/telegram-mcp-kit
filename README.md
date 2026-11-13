# telegram-mcp-kit

Lets your AI assistant (Claude Code, Codex, any MCP client) read your own Telegram account, using a small local server that runs on your computer.

**Who it's for:** people who want their AI to search and read their real Telegram chats, not a bot's empty inbox.
**What you get:** Telegram tools inside your AI chat, for example "find what Anna wrote about the invoice", read-only to start.

> **Security warning.** This logs in as YOU, so the saved login (a "session") is as powerful as your phone. Never paste your Telegram API hash, login code, 2FA password or session string into an AI chat, a command line, or Git. Never copy a session file to another computer. Never run `pip install telegram-mcp`: that name on PyPI is a different project. Use only `github.com/chigwell/telegram-mcp`.

## Quick start
1. Get your own Telegram API id and hash at [my.telegram.org/apps](https://my.telegram.org/apps). Keep them private.
2. Give your agent the prompt below. It installs and starts the server and asks you for the login code. Type the code only into the private local login window.
3. Start with read-only tools. Turn on sending later, only if you want it.

**Done when:** your AI client lists Telegram tools and a cheap check (`get_me`) shows your own name.

> Want an AI agent to do it for you? Paste this to Claude Code / Codex / Cursor:
> "Read the 'For AI agents' section of https://github.com/tonydzi/telegram-mcp-kit and set it up for me."

## For AI agents

### Preconditions
- Python 3.10 or newer (the upstream requirement), Git, optionally `uv`. On Windows make sure `python` is not the Microsoft Store stub.
- A Claude Code and/or Codex install. The server speaks streamable HTTP at `http://127.0.0.1:<FREE_PORT>/mcp`.
- Ask the human for: Telegram API id and API hash (they get them at my.telegram.org/apps), their phone number, and the login code and 2FA password when Telegram asks. The human types these into a private local window only. Never ask for them in chat, never put them in argv, a repo, a synced folder, a screenshot or shell history.
- Check first for an already working setup (running server, configured URL). Reuse it. Do not start a second owner of the same Telegram key.

### Install
The server is upstream `chigwell/telegram-mcp`. This repo ships docs, a skill and old patches, not the server.
```bash
git clone https://github.com/chigwell/telegram-mcp
cd telegram-mcp
git remote get-url origin        # must print https://github.com/chigwell/telegram-mcp
git checkout e55d9c7a66a8eb0855debb268a4ed5b63749af2d   # commit this kit was checked against (24 Oct 2026)
```
Then create a separate virtualenv and install dependencies the way that commit documents (upstream ships `uv.lock`, `poetry.lock`, `requirements.txt` and its own README: follow them, do not guess).

Install the portable skill from this repo, only the directory `skills/telegram-connect/`:
```bash
git clone https://github.com/tonydzi/telegram-mcp-kit
mkdir -p ~/.claude/skills/telegram-connect     # for Codex: ~/.codex/skills/telegram-connect
cp telegram-mcp-kit/skills/telegram-connect/SKILL.md ~/.claude/skills/telegram-connect/SKILL.md
```
If `telegram-connect` already exists, compare and back it up before overwriting.

The `patches/` folder targets an old upstream commit (`a008ac2`). Do not apply it to current upstream.

### Configure
1. Private server settings (a `.env` kept private and outside synced folders). First run values from `CONFIGURATION.md`:
```dotenv
MCP_TRANSPORT=http
MCP_HOST=127.0.0.1
MCP_PORT=<FREE_PORT>
TELEGRAM_EXPOSED_TOOLS=read-only
TELEGRAM_TRANSCRIBE=off
```
Plus the human's own `TELEGRAM_API_ID`, `TELEGRAM_API_HASH` and session, named by that commit's `.env.example`.
2. Session: use upstream `session_string_generator.py` with `--qr` or `--phone` (check `--help` at that commit). The human completes login in a private local window. Prefer a file session for a long-running server.
3. Run exactly one server process: `<VENV_PYTHON> <CHECKOUT>/main.py <PRIVATE_MEDIA_DIRECTORY>`. Give it a narrow media folder, never the whole home directory.
4. Register the same URL in each client. Check `claude mcp add --help` and `codex mcp add --help` first. Documented forms: `claude mcp add --transport http telegram http://127.0.0.1:<FREE_PORT>/mcp`, and in Codex config `[mcp_servers.telegram]` with `url = "http://127.0.0.1:<FREE_PORT>/mcp"`. Back up the config, edit only the telegram entry.
5. A scripts-without-LLM worker (Telethon) needs its own, different session key. Details in `README.ru.md` and `VALIDATION.md`.

### Verify
In each client (Claude Code, and separately Codex), call the Telegram tool `get_me` (or `list_accounts`). Expected: it returns the human's own account, not an error. A listening port or a running process is not proof. Then restart and repeat: it must pass without a new login. The full acceptance table is in `VALIDATION.md`. Static check you can run without any login: `ls ~/.claude/skills/telegram-connect/SKILL.md`, and the first lines must show `name: telegram-connect`.

### Uninstall / rollback
- Remove only the `telegram` entry from the client configs (restore your backup).
- Stop the one server process. Delete `~/.claude/skills/telegram-connect/` (and the Codex copy) if you added it.
- To end the login for good, the human terminates the session in Telegram: Settings, Devices. Then delete the session file.

### Rules for the agent
- Never display, log, echo or commit the API hash, OTP, 2FA password or session string. Do not pass them as command arguments.
- Never copy an authorized `.session` file or session string between machines. A second IP using the same key can get it revoked (`AUTH_KEY_DUPLICATED`). Each machine and each rail logs in on its own.
- Do not install `telegram-mcp` from PyPI. Do not run two MCP servers on one key. Do not mix `/sse` and `/mcp`.
- Keep the server bound to `127.0.0.1`. Do not disable Host or Origin checks. The pinned upstream has no built-in bearer auth, so other local processes can reach it: use a trusted single-user machine only.
- Read-only first. Enable send tools only if the human says so, and test with a message to their own Saved Messages. After a send timeout, check the chat before retrying.
- Do not message anyone, join or leave chats, or delete anything unless the human asked for exactly that.

## Details

Connect Claude (Claude Code / Claude Desktop / Codex — any MCP client) to **your own Telegram account** with a shared MCP service and a separate Telethon worker. It includes portable skills, prompts, setup and recovery instructions.

Built and battle-tested at [Palo Alto AI Research Lab](https://github.com/tonydzi/tonydzi) — our Claude fleet reads and writes Telegram in daily operations. Current upstream and historical local patches differ; verify the selected source rather than assuming parity.

## Current setup: Claude Code + Codex, MCP + Telethon

Start with the maintained [complete runbook (Russian)](README.ru.md), [agent prompts](PROMPTS.ru.md), [HTTP configuration](CONFIGURATION.md), and [acceptance checks](VALIDATION.md). The portable [telegram-connect skill](skills/telegram-connect/SKILL.md) supports either agent and needs no private fleet infrastructure.

**Security warning from upstream:** do not install `pip install telegram-mcp`, `uvx telegram-mcp`, or `uvx --from telegram-mcp`. That PyPI name is a different project. Clone only [chigwell/telegram-mcp](https://github.com/chigwell/telegram-mcp), verify origin and pin a full commit before using credentials.

Two independent rails:

1. A single local MCP server exposes streamable HTTP `/mcp` to both Claude Code and Codex.
2. A separately authorized Telethon worker handles scripts without an LLM session. It must use a different machine-local auth key, never a copied MCP session.

Keep login, OTP, API hash and session output in a private local UI. The agent conversation and process argv are not secret stores. Begin with read-only tools; verify each harness and worker independently, then repeat after restart. A successful port probe is not Telegram authorization.

### Historical patches and launchers

The files in `patches/` target historical upstream `a008ac2`. They are retained for users of that exact old source. Current upstream has native HTTP; do not apply transport or extra-tool patches blindly. Run `git apply --check` against the selected source and review schema differences first. Historical [daemon examples](daemon/README.md) use SSE, which must not be assumed compatible with a client's streamable HTTP transport.

This release updates setup instructions; fresh phone authorization and installation on all three operating systems have not been rerun. See [validation boundaries](VALIDATION.md).

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

<!--we-ask:start-->

## Contributors welcome — and here is what we are missing

We spend a lot of time answering other people's issues. It was fair to say out loud
what we have not built ourselves:

- [Verify the quickstart on macOS and Linux](https://github.com/tonydzi/telegram-mcp-kit/issues/1)
- [Detect when upstream moves and our patches stop applying](https://github.com/tonydzi/telegram-mcp-kit/issues/2)

Issues labelled [`accepted`](https://github.com/tonydzi/telegram-mcp-kit/issues?q=is%3Aissue+is%3Aopen+label%3Aaccepted) are scoped, free to take, and nobody is on them.
Comment **"claiming this"** — no permission needed — and it is yours for 7 days.
New here? Start with [`good first issue`](https://github.com/tonydzi/telegram-mcp-kit/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22).

**You keep the copyright to your code.** No CLA, no assignment, ever — your contribution goes
in under this repo's existing license, the same terms as ours. We answer every issue and PR
within 48 hours, including "no, and here is why"; our silence is our bug, so ping the thread.

Full deal: [CONTRIBUTING.md](https://github.com/tonydzi/.github/blob/main/CONTRIBUTING.md)

<!--we-ask:end-->

---

<!--ecosystem-map:start-->

## 🧩 One piece of a working system

This repository is one piece lifted out of a live operation: one engineer running a fleet of
machines, built with Claude as implementation collaborator; the machines reach consensus with
each other and wake the human only for money or the irreversible. It was extracted after it
survived production, not written as a demo — and it runs on its own: nothing here phones home
to the rest.

**See how the whole thing fits together → [SYSTEM.md](https://github.com/tonydzi/tonydzi/blob/main/SYSTEM.md)**

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
- 🌐 [Palo Alto AI Research Lab](https://github.com/tonydzi)
- 🧪 **Engineers: want to test-drive this setup?** Message me — I hand out free starter seeds to engineers who test and report back.

<!-- READ-WITH-AI:START (generated by read_with_ai.py - do not hand-edit) -->

### READ THIS WITH AI

One click and an agent reads the repo, pulls out the patterns and helps you apply them to your own work.

<a href="https://chatgpt.com/codex?prompt=Read%20this%20repo%3A%20https%3A%2F%2Fgithub.com%2Ftonydzi%2Ftelegram-mcp-kit%20%28%E2%80%9Ctelegram-mcp-kit%E2%80%9D%20-%20Connect%20Claude%20%28or%20any%20MCP%20client%29%20to%20your%20own%20Telegram%20in%20~15%20minutes%3A%20setup%20prompt%20for%20Claude%20Code%2FCodex%2C%20production%20patches%20%28shared%20daemon%2C%20extra%20tools%2C%20multi-account%29%2C%20watchdog%2C%20and%20every%20gotcha...%29.%20Work%20out%20what%20problem%20it%20actually%20solves%2C%20pull%20out%20the%20reusable%20patterns%20and%20help%20me%20apply%20them%20to%20my%20own%20setup.%20Start%20by%20asking%20what%20I%20am%20working%20on."><img alt="Codex - open" src="https://img.shields.io/badge/Codex-open-000000?style=for-the-badge&logo=openai&logoColor=white"></a> <a href="https://chatgpt.com/?q=Read%20this%20repo%3A%20https%3A%2F%2Fgithub.com%2Ftonydzi%2Ftelegram-mcp-kit%20%28%E2%80%9Ctelegram-mcp-kit%E2%80%9D%20-%20Connect%20Claude%20%28or%20any%20MCP%20client%29%20to%20your%20own%20Telegram%20in%20~15%20minutes%3A%20setup%20prompt%20for%20Claude%20Code%2FCodex%2C%20production%20patches%20%28shared%20daemon%2C%20extra%20tools%2C%20multi-account%29%2C%20watchdog%2C%20and%20every%20gotcha...%29.%20Work%20out%20what%20problem%20it%20actually%20solves%2C%20pull%20out%20the%20reusable%20patterns%20and%20help%20me%20apply%20them%20to%20my%20own%20setup.%20Start%20by%20asking%20what%20I%20am%20working%20on."><img alt="ChatGPT - open" src="https://img.shields.io/badge/ChatGPT-open-10a37f?style=for-the-badge&logo=openai&logoColor=white"></a> <a href="https://claude.ai/new?q=Read%20this%20repo%3A%20https%3A%2F%2Fgithub.com%2Ftonydzi%2Ftelegram-mcp-kit%20%28%E2%80%9Ctelegram-mcp-kit%E2%80%9D%20-%20Connect%20Claude%20%28or%20any%20MCP%20client%29%20to%20your%20own%20Telegram%20in%20~15%20minutes%3A%20setup%20prompt%20for%20Claude%20Code%2FCodex%2C%20production%20patches%20%28shared%20daemon%2C%20extra%20tools%2C%20multi-account%29%2C%20watchdog%2C%20and%20every%20gotcha...%29.%20Work%20out%20what%20problem%20it%20actually%20solves%2C%20pull%20out%20the%20reusable%20patterns%20and%20help%20me%20apply%20them%20to%20my%20own%20setup.%20Start%20by%20asking%20what%20I%20am%20working%20on."><img alt="Claude - open" src="https://img.shields.io/badge/Claude-open-d97757?style=for-the-badge&logo=anthropic&logoColor=white"></a>

<details>
<summary>Copy the prompt (works in any agent: Gemini, Grok, a local model, your own CLI)</summary>

```text
Read this repo: https://github.com/tonydzi/telegram-mcp-kit (“telegram-mcp-kit” - Connect Claude (or any MCP client) to your own Telegram in ~15 minutes: setup prompt for Claude Code/Codex, production patches (shared daemon, extra tools, multi-account), watchdog, and every gotcha...). Work out what problem it actually solves, pull out the reusable patterns and help me apply them to my own setup. Start by asking what I am working on.
```

</details>

<sub>— TonyDzi, Palo Alto AI Research Lab · second brain, agent coordination, persistent memory: github.com/tonydzi</sub>

<!-- READ-WITH-AI:END -->
