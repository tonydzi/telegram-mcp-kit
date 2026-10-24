# Acceptance and verification boundaries

Preparation of this documentation is a static review. It does not authenticate a new user's Telegram. Record time, OS, exact source commit, dependency lock revision and harness versions in a private report; never attach raw secret files, full config dumps or message bodies.

| Gate | Expected evidence | What it does not prove |
|---|---|---|
| Source identity | exact GitHub origin + full commit, source/README matching | package with a matching name is safe |
| Static manifests | JSON/TOML parse, URL placeholders resolved, no argv secrets | server reachable |
| Service | one owner PID, loopback listener, correct endpoint | Telegram login or tool discovery |
| Claude Code | in-session discovery + own cheap get_me | Codex tools available |
| Codex | in-session discovery + own cheap get_me | background worker healthy |
| Worker | own distinct key, exclusive lock, timeout-bounded get_me | send permission or full history coverage |
| Restart | same gates pass after normal restart, no new login | unattended uptime forever |
| Optional write | explicitly authorized self-chat canary, returned ID read back | recipient read it or accepted content |

A useful fake-client test for an existing worker checks missing credentials→AUTH_REQUIRED/config error before networking; second lock contender→BUSY without connect; timeout→nonzero status + guaranteed disconnect; exception→lock released; no secret values in stdout/stderr/argv; fake write timeout→UNKNOWN and no automatic retry. Mocks must never import production secrets or instantiate a live client. Mark mocked behavior TEST, not live acceptance. Run only applicable tests of the selected implementation; this package does not bundle a new worker or claim that these tests already passed.

Before exposing write tools, review each tool name from the actual server schema. If read-only is used, verify destructive/write tools are absent. Tool-surface restriction does not reduce the underlying Telegram authorization's authority. For chat scopes or HTTP token support, inspect the selected pinned version: do not assume a documented setting exists in an older build.

Public documentation's negative examples: a second stdio MCP on the same key, `pip install telegram-mcp`, mixing `/sse` with `/mcp`, passing real session strings via CLI, copying `.session` between machines, treating get_me success as send proof, restarting after ambiguous send without readback. Review must reject each.
