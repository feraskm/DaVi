#!/bin/sh

SCRIPT_NAME="davi.sh"
SCRIPT_PATH="$(dirname "$0")/$SCRIPT_NAME"
INSTALL_DIR="/usr/local/bin" # Default for Linux systems
CONFIG_FILE="${HOME}/.dlconfig"
ALIAS_NAME="dv"

# Check if running in Termux
if [ -n "$TERMUX_VERSION" ]; then
    INSTALL_DIR="${HOME}/bin" # Termux user bin directory
    echo "Detected Termux environment."
else
    echo "Detected Linux environment."
fi

# Function to display messages
display_message() {
    echo "----------------------------------------------------"
    echo "$1"
    echo "----------------------------------------------------"
}

# Copy the script
display_message "1. Copying $SCRIPT_NAME to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR" || { echo "Error: Could not create $INSTALL_DIR. Check permissions."; exit 1; }
cp "$SCRIPT_PATH" "$INSTALL_DIR/$SCRIPT_NAME" || { echo "Error: Could not copy $SCRIPT_NAME. Check permissions."; exit 1; }
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
display_message "$SCRIPT_NAME installed to $INSTALL_DIR."

# Create alias
display_message "2. Creating alias '$ALIAS_NAME'..."
if ! grep -q "alias $ALIAS_NAME=" "${HOME}/.bashrc" && ! grep -q "alias $ALIAS_NAME=" "${HOME}/.zshrc"; then
    if [ -f "${HOME}/.bashrc" ]; then
        echo "alias $ALIAS_NAME=\"$INSTALL_DIR/$SCRIPT_NAME\"" >> "${HOME}/.bashrc"
        echo "Alias added to ~/.bashrc"
    fi
    if [ -f "${HOME}/.zshrc" ]; then
        echo "alias $ALIAS_NAME=\"$INSTALL_DIR/$SCRIPT_NAME\"" >> "${HOME}/.zshrc"
        echo "Alias added to ~/.zshrc"
    fi
    display_message "Alias '$ALIAS_NAME' created. Please 'source ~/.bashrc' or 'source ~/.zshrc' or restart your terminal to use it."
else
    display_message "Alias '$ALIAS_NAME' already exists in your shell config. Skipping."
fi

# Create default config file
display_message "3. Checking for config file..."
if [ ! -f "$CONFIG_FILE" ]; then
    DEFAULT_OUTPUT_DIR=""
    if [ -n "$TERMUX_VERSION" ]; then
        DEFAULT_OUTPUT_DIR="${HOME}/storage/downloads/media"
    else
        DEFAULT_OUTPUT_DIR="${HOME}/Downloads/media" # More common for Linux
    fi
    
    cat > "$CONFIG_FILE" << EOF
# Video and Audio Download Settings
OUTPUT_DIR="${DEFAULT_OUTPUT_DIR}"
VIDEO_FORMAT="mp4"
AUDIO_FORMAT="mp3"
VIDEO_QUALITY="best"
AUDIO_QUALITY="0"
EMBED_SUBS="yes"
AUTO_SUBS="no"
EOF
    display_message "Default config file created: $CONFIG_FILE"
    display_message "You can edit this file to customize settings."
else
    display_message "Config file already exists: $CONFIG_FILE. Skipping creation."
fi

# Dependency installation instructions
display_message "4. Dependency Installation Instructions:"
if [ -n "$TERMUX_VERSION" ]; then
    echo "For Termux, run:"
    echo "  pkg update && pkg upgrade"
    echo "  pkg install python python-yt-dlp ffmpeg"
    echo "  termux-setup-storage (if you haven't already)"
    echo ""
    echo "Note: In Termux, 'python-yt-dlp' is recommended over 'yt-dlp' via pip due to potential permission issues."
else
    echo "For Linux, you need 'yt-dlp' and 'ffmpeg'."
    echo "Option A: Install using your system's package manager (recommended if available):"
    echo "  Debian/Ubuntu: sudo apt update && sudo apt install yt-dlp ffmpeg"
    echo "  Fedora: sudo dnf install yt-dlp ffmpeg"
    echo "  Arch Linux: sudo pacman -S yt-dlp ffmpeg"
    echo "  Alpine Linux: sudo apk add yt-dlp ffmpeg"
    echo ""
    echo "Option B: Install yt-dlp using pip (if system package manager doesn't have it or for latest version):"
    echo "  sudo pip install yt-dlp"
    echo "  # If you face 'externally-managed-environment' error, try:"
    echo "  # sudo pip install yt-dlp --break-system-packages"
    echo "  # Warning: Using --break-system-packages can sometimes affect system Python integrity. Use with caution."
    echo "  # For ffmpeg, use your system's package manager as in Option A."
    echo ""
    echo "Option C: Using Docker (for isolated environment, requires Docker installed):"
    echo "  If you have Docker, you can run yt-dlp in a container without affecting your system Python."
    echo "  You'd typically use a command like: docker run --rm -v \$(pwd):/data yt-dlp/yt-dlp [your_yt-dlp_options]"
    echo "  This script does NOT automatically integrate Docker for yt-dlp usage."
fi

display_message "Installation complete! Remember to install dependencies and source your shell config."
display_message "You can now use 'dv' command. Example: dv <video_url>"

exit 0