# PROMPT.md — give this to your Claude Code / Codex

Copy everything below the line into a Claude Code (or Codex CLI) session started with permissions to run shell commands. It will install and wire the Telegram MCP for you.

---

You are setting up a Telegram MCP server (MTProto user-account) so this machine's Claude can read and write my Telegram. Follow these steps exactly; the gotchas are real and each one cost the kit authors hours.

**Step 0 — prerequisites.** Check that `git` and `uv` are installed (`uv --version`). If `uv` is missing, install it (Windows: `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`; macOS/Linux: `curl -LsSf https://astral.sh/uv/install.sh | sh`).

**Step 1 — API credentials.** Ask me for `api_id` and `api_hash`. If I don't have them, tell me to open https://my.telegram.org → API development tools → create an app (platform: Desktop), and wait for me to paste both values. Treat `api_hash` like a password: never echo it into logs or commit it.

**Step 2 — install the server.**
```
git clone https://github.com/chigwell/telegram-mcp.git <MCP_DIR>   # e.g. C:\mcp\telegram-mcp or ~/mcp/telegram-mcp
cd <MCP_DIR>
uv sync
```

**Step 3 — apply the kit patches** (from https://github.com/tonydzi/telegram-mcp-kit). The patches are pinned to upstream commit `a008ac2`:
```
git checkout a008ac2
git apply <KIT_DIR>/patches/0001-transport-sse-env.patch
git apply <KIT_DIR>/patches/0002-extra-tools-multiaccount.patch
```
Alternative: stay on latest upstream HEAD (it already has env-selectable transport built in — skip patch 0001) and try `git apply -3 <KIT_DIR>/patches/0002-extra-tools-multiaccount.patch`; if hunks conflict, tell me which ones instead of silently skipping.

**Step 4 — session string (one-time interactive login).** Run `uv run session_string_generator.py` in a REAL interactive terminal (it needs my input: phone + code, or QR). You cannot complete this for me — hand me the exact command, wait, then ask me to paste the resulting session string. Never store the string in any file that goes to git.

**Step 5 — media folder (allowed roots).** Create a dedicated folder (e.g. `C:\TG-Media` or `~/tg-media`). CRITICAL GOTCHA: file tools (`download_media`, `send_file`) only work if this folder is passed as a **trailing positional argument** to `main.py` — NOT an env var. Forgetting this is the #1 silent failure.

**Step 6 — register the MCP server.** For Claude Code:
```
claude mcp add telegram --scope user \
  --env TELEGRAM_API_ID=<id> \
  --env TELEGRAM_API_HASH=<hash> \
  --env TELEGRAM_SESSION_STRING=<string> \
  -- <MCP_DIR>/.venv/Scripts/python.exe <MCP_DIR>/main.py <MEDIA_DIR>
```
Launch the venv python DIRECTLY, not through `uv run`: on Windows the `uv run` wrapper leaks orphaned server processes (we once found 60). For Claude Desktop, write the equivalent `mcpServers` block into `claude_desktop_config.json`.

If I want read-only safety by default, add `--env TELEGRAM_EXPOSED_TOOLS=read-only`.

**Step 7 — verify.** Restart the session (newly added stdio MCP tools appear only after restart), then call `get_me`. Success = my account info comes back. Then `list_chats` limit 5. Report both results to me verbatim.

**Step 8 (optional, for machines running many parallel agent sessions) — shared daemon.** Instead of a stdio copy per session, run one daemon: set `MCP_TRANSPORT=sse`, `MCP_HOST=127.0.0.1`, `MCP_PORT=8765` and launch `main.py` once at login (Windows: HKCU Run key; macOS: launchd; Linux: systemd --user). Then register the client as `{"type":"sse","url":"http://127.0.0.1:8765/sse"}`. Add the watchdog from the kit's `daemon/` folder — but read its README first: a naive "port dead → restart" watchdog blinds every live session; the shipped one uses two probes with a pause and logs evidence before touching anything.

**Safety rules you must follow during this setup:** the session string equals full account access without 2FA — keep it only in the MCP registration env; never print it in your final report; tell me I can revoke it any time in Telegram → Settings → Devices. Mass downloads must be throttled (flood-wait bans are real).
