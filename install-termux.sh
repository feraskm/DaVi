#!/data/data/com.termux/files/usr/bin/bash

# DaVi - Termux-only installer and runner
# Author: فراس
# Date: 2025-06-16

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if running in Termux
if [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    echo -e "${RED}This installer is intended for Termux only.${NC}"
    exit 1
fi

# Ensure bash is used
if [[ -z "$BASH_VERSION" ]]; then
    echo -e "${RED}Please run this installer with bash: bash install.sh${NC}"
    exit 1
fi

# Install dependencies
echo -e "${GREEN}Installing dependencies...${NC}"
pkg update -y
pkg install -y python ffmpeg git bash
pip install --upgrade yt-dlp

# Paths
BIN_PATH="$PREFIX/bin"
SCRIPT_PATH="$HOME/DaVi/davi.sh"
ALIAS_FILE="$HOME/.bashrc"

# Make script executable
chmod +x "$SCRIPT_PATH"

# Add alias to .bashrc if not present
if ! grep -q "alias dv=" "$ALIAS_FILE" 2>/dev/null; then
    echo -e "\nalias dv='bash $SCRIPT_PATH'" >> "$ALIAS_FILE"
    echo -e "${GREEN}Alias 'dv' added to .bashrc${NC}"
else
    echo -e "${GREEN}Alias 'dv' already exists in .bashrc${NC}"
fi

# Reload .bashrc
source "$ALIAS_FILE"

# Done
echo -e "${GREEN}Installation complete. You can now use the 'dv' command.${NC}"
echo -e "Example: dv https://youtu.be/example"
