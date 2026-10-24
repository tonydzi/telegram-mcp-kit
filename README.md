# telegram-mcp-kit

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
