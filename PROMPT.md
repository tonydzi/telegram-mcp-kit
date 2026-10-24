# Telegram setup prompt for Claude Code or Codex

Use the maintained [complete prompts](PROMPTS.ru.md) with the [runbook](README.ru.md), [client config](CONFIGURATION.md), and [acceptance checks](VALIDATION.md). Install the portable [skill](skills/telegram-connect/SKILL.md) if you want this procedure available in future sessions.

Copy this into your agent:

```text
Set up my Telegram for Claude Code and Codex using https://github.com/tonydzi/telegram-mcp-kit. Read README.ru.md, PROMPTS.ru.md, CONFIGURATION.md and VALIDATION.md from the same inspected revision before changes. Reuse existing working setup. I need two rails: one shared loopback HTTP MCP server for both clients, plus a separately authorized Telethon worker. Never copy auth keys between rails or machines. Verify the exact chigwell/telegram-mcp origin and pin its commit; never install the unrelated PyPI telegram-mcp name or blindly apply historical patches. Keep secrets and login output out of this chat, logs and argv; use private local input. Preserve unrelated configs, start read-only, prove each harness and worker separately and again after restart. No external sends without permission. Report tested, failed and unknown separately; do not claim live setup from static checks.
```

Source and credit: https://github.com/tonydzi
