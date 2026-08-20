#!/bin/bash
# Headless invoker for the teams-catchup skill.
# Called by launchd on a schedule.

# Log everything to a file so we can debug cron failures
LOG_DIR="/Users/amadou/.claude/state/teams-catchup"
LOG_FILE="$LOG_DIR/cron.log"
mkdir -p "$LOG_DIR"

echo "=== teams-catchup run: $(date '+%Y-%m-%d %H:%M:%S %Z') ===" >> "$LOG_FILE"

# Ensure PATH includes common locations for claude CLI
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

# Run claude in headless mode. Uses --permission-mode auto (allowed via user's shell alias).
# The prompt tells Claude to invoke the teams-catchup skill.
/usr/bin/env claude \
  --permission-mode auto \
  -p "Run the teams-catchup skill. Follow its SKILL.md exactly. Do not ask for confirmation." \
  >> "$LOG_FILE" 2>&1

echo "=== exit: $? ===" >> "$LOG_FILE"
