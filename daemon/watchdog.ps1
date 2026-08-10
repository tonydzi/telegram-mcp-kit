# Watchdog for the shared telegram-mcp daemon (port 8765).
# Design rules learned the hard way (see docs/GOTCHAS.md #4):
#   - a daemon RESTART kills the SSE stream of every live client session,
#     so restarting on a single failed probe is worse than most real crashes;
#   - therefore: TWO probes with a pause; a single failure is LOGGED, not healed;
#   - before restarting, log evidence (listener state, server PIDs) so a false
#     alarm is distinguishable from a real death in the log afterwards.
# Schedule: Task Scheduler, every 30 min, MultipleInstances=IgnoreNew.
# The watchdog must NOT live inside the thing it watches.

param([switch]$DryRun)

$Port     = 8765
$Launcher = Join-Path $PSScriptRoot "telegram_mcp_sse.cmd"
$Log      = Join-Path $env:USERPROFILE "telegram_mcp_watchdog.log"

function Probe {
    try {
        (Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded
    } catch { $false }
}
function Say($msg) { "$(Get-Date -Format s) $msg" | Add-Content $Log }

if (Probe) { exit 0 }                # healthy -> total silence

Start-Sleep -Seconds 20              # maybe a transient hiccup
if (Probe) { Say "false alarm: probe1 failed, probe2 ok - NOT restarting"; exit 0 }

# Real death. Collect evidence before touching anything.
$listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
$pids = Get-CimInstance Win32_Process -Filter "Name='python.exe'" |
        Where-Object { $_.CommandLine -match 'telegram-mcp' } |
        Select-Object -ExpandProperty ProcessId
Say "DEAD: listener=$($null -ne $listener) serverPids=[$($pids -join ',')] -> restarting"
if ($DryRun) { Say "dry-run: would restart"; exit 0 }

# A stale launcher wrapper can hold the log file and block the next start.
foreach ($p in $pids) { try { Stop-Process -Id $p -Force -ErrorAction Stop } catch {} }
Start-Process -WindowStyle Hidden cmd.exe -ArgumentList "/c `"$Launcher`""
Start-Sleep -Seconds 15
if (Probe) { Say "restart OK" } else { Say "restart FAILED - manual attention needed" }
