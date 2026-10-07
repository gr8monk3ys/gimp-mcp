# Lorenzo's setup (branch `lorenzo`)

Personal config for this fork. Upstream fixes go on their own `fix/*` branches and PRs to
maorcc/gimp-mcp; this branch = upstream `main` + those fixes + this folder.

- GIMP 3.2.6 (winget) on Windows. Install/refresh the plugin: `powershell -File local\install-plugin.ps1`,
  restart GIMP, then **Tools > MCP > Start MCP Server** (needed every GIMP launch; listens on
  127.0.0.1:9877 and exec()s any Python sent to it).
- Claude Code: registered at user scope as `gimp` ->
  `uv run --directory C:\Users\loren\Code\additional\gimp-mcp gimp_mcp_server.py`.
- Tests: `uv run python run_tests.py` against the running GUI GIMP (98 checks, pixel-verified).
- Headless (no GUI): `gimp-console-3.exe -i --batch-interpreter=python-fu-eval -b "<run plug-in-mcp-server NONINTERACTIVE>"`
  works, but `new_canvas`/`open_image` call `Gimp.Display.new()` and fail there; it also needs
  port 9877 free.

Open fixes: https://github.com/maorcc/gimp-mcp/pull/62 (filters, drop shadow, export formats,
bitmap index). Other useful open upstream PRs not merged here: #41 colours/gradient, #52
close_image, #48 histogram, #60 auto_levels, #55 get_pixel_color.

Updating: `git fetch upstream && git merge upstream/main`; drop a fix branch's commits once its PR
is merged upstream.
