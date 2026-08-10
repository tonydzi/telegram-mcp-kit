@echo off
REM One shared telegram-mcp daemon per machine (needs patch 0001-transport-sse-env).
REM All Claude sessions connect to 127.0.0.1:8765 instead of each spawning a copy.
REM Autostart: add this script to an HKCU Run key (no admin needed), e.g.:
REM   reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v TelegramMcpSSE /d "\"%~f0\""
REM NOTE: the transport patch is local to your clone - a git pull from upstream can
REM revert it, and the daemon silently falls back to stdio. Re-apply after pulls.
set MCP_TRANSPORT=sse
set MCP_HOST=127.0.0.1
set MCP_PORT=8765
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
REM Adjust the three paths below to your install:
"C:\mcp\telegram-mcp\.venv\Scripts\python.exe" "C:\mcp\telegram-mcp\main.py" "C:\TG-Media" >> "%USERPROFILE%\telegram_mcp_sse.log" 2>&1
