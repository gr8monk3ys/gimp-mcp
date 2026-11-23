---
status: accepted
date: 2026-11-22
---

# A socket bridge splits the MCP Server from the Plugin

GIMP 3's Python API (`gi.repository.Gimp`) is only importable inside GIMP's own interpreter, while MCP clients need a standalone process speaking MCP. We split the system in two: the **Plugin** (`gimp-mcp-plugin.py`) hosts a TCP socket server on `localhost:9877` inside GIMP, and the **MCP Server** (`gimp_mcp_server.py`, FastMCP) forwards **Commands** to it as JSON, one connection per command.

## Consequences

- The MCP Server can be installed and run with ordinary Python tooling (`uv`, `pyproject.toml`); only the Plugin is copied into GIMP's plug-ins directory.
- The Plugin must be started from GIMP (Tools > MCP) before any Tool works; `check_server` and `restart_server` exist for that.
- Commands and replies are bare JSON with no auth, so the socket must stay bound to localhost.
- Tests that exercise Commands need a running GIMP (`tests/`); `make check` therefore covers lint and syntax only.
