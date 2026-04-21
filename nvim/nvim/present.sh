#!/bin/bash
# Neovim presentation script
# Slides open in browser (reveal-md), Neovim runs in the terminal.

SLIDES_FILE="/Users/therealcisse/dot/nvim/nvim/PRESENTATION-new.md"
DEMO_DIR="/Users/therealcisse/demo-nvim"

# Kill any previous reveal-md instance
pkill -f "reveal-md.*PRESENTATION-new" 2>/dev/null

# Start slides in browser (background)
npx reveal-md "$SLIDES_FILE" --theme night --highlight-theme monokai &
SLIDES_PID=$!

# Clean up reveal-md when the script exits
trap "kill $SLIDES_PID 2>/dev/null" EXIT

# Launch Neovim in the demo project
cd "$DEMO_DIR" && nvim src/Main.scala
