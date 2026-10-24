# Shared daemon mode (one server per machine)

Why: each Claude session normally spawns its own stdio copy of the server. At ~10 parallel sessions we measured ~2.7 GB of duplicate Telegram clients on one laptop. One shared daemon fixes it.

**Historical SSE examples only.** New installations should use the [native HTTP runbook](../README.ru.md) and [both client configurations](../CONFIGURATION.md). Current upstream needs no old transport patch. These launchers target the historical patched source; inspect the selected source and do not assume `/sse` equals `/mcp`.

## Setup (Windows)

1. Edit the three paths in `telegram_mcp_sse.cmd` (venv python, `main.py`, media dir). Put your `TELEGRAM_API_ID` / `TELEGRAM_API_HASH` / `TELEGRAM_SESSION_STRING` into the machine user env (or add `set` lines to the script — then keep the script out of synced/committed folders).
2. Autostart without admin: HKCU Run key (command inside the script header).
3. Point every MCP client at the daemon instead of spawning its own:
   ```json
   "mcpServers": { "telegram": { "type": "sse", "url": "http://127.0.0.1:8765/sse" } }
   ```
4. Watchdog: schedule `watchdog.ps1` in Task Scheduler every 30 min with `MultipleInstances=IgnoreNew`. Test first: `powershell -File watchdog.ps1 -DryRun`.

macOS/Linux: same pattern — launchd / `systemd --user` unit exporting `MCP_TRANSPORT=sse`, `MCP_HOST=127.0.0.1`, `MCP_PORT=8765`.

## Warnings

- Bind to `127.0.0.1` only. The daemon is your logged-in Telegram; never expose the port.
- A daemon restart breaks the SSE stream of every live session (they'll error on telegram calls until restarted). That's why the watchdog is deliberately conservative — read its header before "improving" it.
- Do not update the source underneath a live service. Pin the selected commit, inspect transport support and check historical patches before a controlled upgrade; never blindly reapply them.
