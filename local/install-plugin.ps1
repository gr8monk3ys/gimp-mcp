# Copy gimp-mcp-plugin.py into the newest GIMP 3.x per-user plug-ins folder.
# Re-run after pulling plugin changes or upgrading GIMP (3.2 -> 3.4 moves the folder),
# then restart GIMP and use Tools > MCP > Start MCP Server.
$ErrorActionPreference = 'Stop'
$base = Join-Path $env:APPDATA 'GIMP'
$ver = Get-ChildItem $base -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^3\.\d+$' } |
    Sort-Object { [version]$_.Name } | Select-Object -Last 1
if (-not $ver) { throw "No GIMP 3.x config dir under $base - launch GIMP once, then re-run." }
$dest = Join-Path $ver.FullName 'plug-ins\gimp-mcp-plugin'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item (Join-Path $PSScriptRoot '..\gimp-mcp-plugin.py') $dest -Force
"Installed into $dest"
if (Get-Process gimp-3* -ErrorAction SilentlyContinue) {
    'GIMP is running: restart it to load the new plugin.'
}
