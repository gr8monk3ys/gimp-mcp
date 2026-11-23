# GIMP MCP

Lets MCP clients (Claude Desktop and others) drive a running GIMP 3.x over a local socket.

## Language

**Plugin**:
The GIMP 3 plug-in (`gimp-mcp-plugin.py`, class `MCPPlugin`) that runs a socket server inside GIMP and executes commands against the GIMP API. It registers the `plug-in-mcp-check` and `plug-in-mcp-restart` procedures.
_Avoid_: add-on, extension

**MCP Server**:
The FastMCP process (`gimp_mcp_server.py`, entry point `gimp-mcp-server`) that MCP clients talk to. It exposes tools and prompts and forwards them to the Plugin.
_Avoid_: bridge, proxy

**GimpConnection**:
The MCP Server's client of the Plugin's socket (`localhost:9877`). One command per connection: it connects, sends, reads the full reply, then disconnects.

**Command**:
A JSON message `{"type": <name>, "params": {...}}` sent over the socket. The Plugin dispatches on `type` in `execute_command`. See `GIMP_MCP_PROTOCOL.md`.
_Avoid_: request, RPC

**Tool**:
An `@mcp.tool()` function on the MCP Server (e.g. `new_canvas`, `export_image`, `call_api`). Most map to one Command of the same name.

**call_api**:
The generic Tool that executes Python code strings inside GIMP's pyGObject console via `api_path="exec"`; the escape hatch when no dedicated Tool exists.

**Prompt**:
An `@mcp.prompt` served to clients: `gimp_best_practices` and `gimp_iterative_workflow`, sourced from `docs/best_practices.md` and `docs/iterative_workflow.md`.

**Image bitmap**:
The rendered pixels of the current image returned as an MCP `Image` by `get_image_bitmap`, optionally bounded by `max_width`, `max_height` or a `region`.

**Image metadata**:
Structured facts about the current image returned by `get_image_metadata`; `get_state_snapshot` bundles it with a bitmap.

**Context state**:
GIMP's current foreground/background colours, brush and similar settings, read by `get_context_state` and set by `set_colors`.

**Server check / restart**:
`check_server` reports whether the Plugin's socket is alive; `restart_server` restarts it. Also exposed inside GIMP as the `plug-in-mcp-check` and `plug-in-mcp-restart` procedures.
