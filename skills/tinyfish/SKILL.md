---
name: tinyfish
description: "Set up and use the TinyFish MCP server (web search, fetch_content, browser automation, monitors) in any MCP-capable agent. Use when the user asks to install/configure TinyFish, when tinyfish tools are expected but missing, or before web-grounded tasks that should prefer TinyFish's free search/fetch."
---

# TinyFish MCP

TinyFish is a hosted MCP server: free `search` + `fetch_content` for web
grounding, plus metered browser automation (`run_web_automation`), browser
profiles, and monitors.

## Setup

1. **API key** — get one from the TinyFish dashboard, then either:
   - `mkdir -p ~/.config/tinyfish && echo 'sk-...' > ~/.config/tinyfish/api-key && chmod 600 ~/.config/tinyfish/api-key`, or
   - `export TINYFISH_API_KEY=sk-...` in your shell profile.
2. **Header helper** — install `mcp/tinyfish/tinyfish-api-header` from this
   repo to a PATH dir (e.g. `~/.local/bin/tinyfish-api-header`, `chmod +x`).
   It prints `Bearer <key>` so the key never lives in agent config files.
   Test: `TINYFISH_API_KEY=sk-... tinyfish-api-header` → `Bearer sk-...`.
3. **Register the server** in your agent's MCP config:

   ```json
   {
     "tinyfish": {
       "type": "http",
       "url": "https://agent.tinyfish.ai/mcp",
       "headers": { "Authorization": "!tinyfish-api-header" }
     }
   }
   ```

   OMP: add to `~/.omp/agent/mcp.json` under `mcpServers`.
   Claude Code: `claude mcp add --transport http tinyfish https://agent.tinyfish.ai/mcp --header "Authorization: Bearer $TINYFISH_API_KEY"`.
   Codex / others: same URL + Authorization header in their MCP config.
4. Restart the agent session; `tinyfish` tools (`search`, `fetch_content`,
   `run_web_automation`, …) appear.

## Use

- `search` first for external grounding; `fetch_content` for specific URLs.
- `run_web_automation` for interactive pages (clicking, forms, login).
- Metered automation needs wallet balance; search/fetch are free.
