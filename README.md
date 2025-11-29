# TickTick MCP Server

A Model Context Protocol (MCP) server for TickTick task management, containerized with [mcp-proxy](https://github.com/sparfenyuk/mcp-proxy) for remote SSE access.

Based on [jacepark12/ticktick-mcp](https://github.com/jacepark12/ticktick-mcp).

## Features

- **Task Management**: Create, update, delete, complete tasks
- **GTD Workflow**: Built-in "Engaged" (high priority/due today) and "Next" (medium priority/due tomorrow) actions
- **Batch Creation**: Break down complex tasks into smaller subtasks
- **Project Support**: Organize tasks by project

## Setup

### 1. Register a TickTick App

1. Go to https://developer.ticktick.com and log in
2. Create a new app
3. Note your **Client ID** and **Client Secret**
4. Set Redirect URI to: `http://localhost:8000/callback`

### 2. Generate Access Token (One-Time, Local)

Run the auth flow locally to get your tokens:

```bash
cd /Users/ryan/Code/ticktick-mcp

# Create .env from template
cp .env.template .env

# Edit .env with your Client ID and Secret
nano .env

# Run auth flow (opens browser)
uv run -m ticktick_mcp.cli auth

# After authorizing, tokens are saved to .env
# Copy the ACCESS_TOKEN and REFRESH_TOKEN values
```

### 3. Deploy to Portainer

In Portainer, create a new stack and add these environment variables:

| Variable | Value |
|----------|-------|
| `TICKTICK_CLIENT_ID` | Your client ID |
| `TICKTICK_CLIENT_SECRET` | Your client secret |
| `TICKTICK_ACCESS_TOKEN` | Token from auth flow |
| `TICKTICK_REFRESH_TOKEN` | Refresh token from auth flow |

### 4. Connect Claude

The server exposes SSE at `http://your-host:8765/sse`

**Claude Desktop** (using mcp-remote):
```json
{
  "mcpServers": {
    "ticktick": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://your-server:8765/sse"]
    }
  }
}
```

**Via Tailscale:**
```json
{
  "mcpServers": {
    "ticktick": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://your-tailscale-ip:8765/sse"]
    }
  }
}
```

## Available Tools

- `create_task` - Create a new task
- `update_task` - Update an existing task  
- `delete_task` - Delete a task
- `complete_task` - Mark task as complete
- `get_tasks` - Get tasks (with GTD filtering: engaged/next)
- `batch_create_tasks` - Create multiple subtasks at once

## Local Development

```bash
# Install dependencies
uv venv
source .venv/bin/activate
uv pip install -e .

# Run auth
uv run -m ticktick_mcp.cli auth

# Test server
uv run -m ticktick_mcp.cli run
```

## Architecture

```
┌─────────────────┐     SSE      ┌──────────────┐     stdio     ┌─────────────────┐
│  Claude/Client  │◄────────────►│  mcp-proxy   │◄─────────────►│ ticktick-mcp    │
└─────────────────┘              └──────────────┘               └─────────────────┘
                                       │
                                  Port 8765
```

## Troubleshooting

**Check logs:**
```bash
docker logs ticktick-mcp
```

**Token expired:** Re-run the local auth flow and update the environment variables in Portainer.
