# MCP client configuration: placeholders only

Use a single running `chigwell/telegram-mcp` server, configured and authenticated locally. Current upstream HTTP endpoint: `http://127.0.0.1:<FREE_PORT>/mcp`. Replace placeholders. Neither block contains Telegram credentials.

## Claude Code

First inspect the installed version's `claude mcp add --help`. Current upstream documents:

```text
claude mcp add --transport http telegram http://127.0.0.1:<FREE_PORT>/mcp
```

Select the intended scope explicitly using that installed CLI's help. Preserve other entries and back up the manifest privately before editing. A representative manifest entry (use the actual config file chosen by Claude Code, not a guessed Claude Desktop filename):

```json
{"mcpServers":{"telegram":{"type":"http","url":"http://127.0.0.1:<FREE_PORT>/mcp"}}}
```

## Codex

Inspect the installed CLI `codex mcp add --help` before using `codex mcp add telegram --url <URL>` if supported. Equivalent representative user config fragment:

```toml
[mcp_servers.telegram]
url = "http://127.0.0.1:<FREE_PORT>/mcp"
```

Merge the block once; do not overwrite the whole config. If the server requires HTTP auth, use the installed harness's supported secret/environment mechanism after reading its current docs. Do not commit an Authorization header/token, assume unauthenticated access, or switch auth off to make a test pass.

## Server settings (not a complete secret file)

```dotenv
MCP_TRANSPORT=http
MCP_HOST=127.0.0.1
MCP_PORT=<FREE_PORT>
TELEGRAM_EXPOSED_TOOLS=read-only
TELEGRAM_TRANSCRIBE=off
```

The real private file also supplies your API application credentials and exactly the appropriate MCP authorization. Keep it outside synced directories, command argv and public manifests. Resolve env loading from the chosen upstream commit. A `.env` next to the checkout is one documented upstream option but must remain private and ignored.

## Legacy deployments

SSE is `/sse`, HTTP is `/mcp`: these are different transports, not interchangeable URLs. Existing patched servers may use `MCP_TRANSPORT=sse` plus a separate `MCP_ALSO_HTTP` compatibility flag. That flag is not assumed by this quickstart. Confirm the actual endpoint and its auth branch from source; do not apply it from memory. Register two harnesses against the same compatible shared service rather than launching two owners of one Telegram key.

## Authentication boundary of the pinned upstream

At commit `e55d9c7a66a8eb0855debb268a4ed5b63749af2d`, built-in HTTP bearer authentication is not documented or configured in the inspected runner. `MCP_ALLOWED_HOSTS` and `MCP_ALLOWED_ORIGINS` protect Host/Origin handling; they are not authentication. Keep loopback binding and do not disable those checks. Other local processes can still access the endpoint. This baseline is for a trusted single-user machine, not an untrusted shared host. A separately audited token-protected proxy/adapter is outside this kit. Never invent an upstream `MCP_BEARER_TOKEN` or assume a client Authorization header authenticates an unprotected server.

Primary sources: [pinned env example](https://github.com/chigwell/telegram-mcp/blob/e55d9c7a66a8eb0855debb268a4ed5b63749af2d/.env.example), [pinned runner](https://github.com/chigwell/telegram-mcp/blob/e55d9c7a66a8eb0855debb268a4ed5b63749af2d/telegram_mcp/runner.py).
