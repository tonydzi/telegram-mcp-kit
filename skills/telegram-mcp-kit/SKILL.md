---
name: telegram-mcp-kit
description: "Compatibility entry for Telegram MCP setup. Use the maintained telegram-connect skill for shared Claude Code/Codex HTTP and a separate Telethon rail."
license: Apache-2.0
---

# Maintained Telegram setup

This skill name is retained for existing installations. Read the current complete instructions at [telegram-connect](https://github.com/tonydzi/telegram-mcp-kit/blob/main/skills/telegram-connect/SKILL.md) and [runbook](https://github.com/tonydzi/telegram-mcp-kit/blob/main/README.ru.md), using the same inspected revision. They work without files adjacent to this installed skill.

Never install the unrelated PyPI `telegram-mcp` name. Never put API hash/session/OTP into a chat or argv, clone auth keys, apply historical patches blindly, or launch another owner of a working session. Use one loopback HTTP MCP service for both clients and a separately authorized Telethon worker. Setup is not proven until each rail passes its own real read-only check and restart.

Author: https://github.com/tonydzi
