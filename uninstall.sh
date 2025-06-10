#!/bin/sh

SCRIPT_NAME="davi.sh"
INSTALL_DIR="/usr/local/bin" # Default for Linux systems
CONFIG_FILE="${HOME}/.dlconfig"
RESUME_FILE_PATTERN="${HOME}/storage/downloads/media/.resume_data" # Termux default
LINUX_RESUME_FILE_PATTERN="${HOME}/Downloads/media/.resume_data" # Linux default
ALIAS_NAME="dv"

# Check if running in Termux
if [ -n "$TERMUX_VERSION" ]; then
    INSTALL_DIR="${HOME}/bin" # Termux user bin directory
fi

# Function to display messages
display_message() {
    echo "----------------------------------------------------"
    echo "$1"
    echo "----------------------------------------------------"
}

# Remove the script
display_message "1. Removing $SCRIPT_NAME from $INSTALL_DIR..."
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    rm "$INSTALL_DIR/$SCRIPT_NAME"
    display_message "$SCRIPT_NAME removed."
else
    display_message "$SCRIPT_NAME not found in $INSTALL_DIR. Skipping."
fi

# Remove alias
display_message "2. Removing alias '$ALIAS_NAME'..."
if [ -f "${HOME}/.bashrc" ]; then
    sed -i "/alias $ALIAS_NAME=/d" "${HOME}/.bashrc"
    display_message "Alias removed from ~/.bashrc"
fi
if [ -f "${HOME}/.zshrc" ]; then
    sed -i "/alias $ALIAS_NAME=/d" "${HOME}/.zshrc"
    display_message "Alias removed from ~/.zshrc"
fi
display_message "Remember to 'source ~/.bashrc' or 'source ~/.zshrc' or restart your terminal."

# Offer to remove config file
display_message "3. Config and resume files cleanup:"
if [ -f "$CONFIG_FILE" ]; then
    printf "Do you want to remove the config file ($CONFIG_FILE)? (y/N): "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS])
            rm "$CONFIG_FILE"
            display_message "Config file removed."
            ;;
        *)
            display_message "Config file retained."
            ;;
    esac
else
    display_message "Config file ($CONFIG_FILE) not found. Skipping."
fi

# Remove resume data files
display_message "Attempting to remove resume data files..."
if [ -n "$TERMUX_VERSION" ]; then
    if [ -f "$RESUME_FILE_PATTERN" ]; then
        rm "$RESUME_FILE_PATTERN"
        display_message "Termux resume file removed: $RESUME_FILE_PATTERN"
    else
        display_message "Termux resume file not found: $RESUME_FILE_PATTERN"
    fi
else
    if [ -f "$LINUX_RESUME_FILE_PATTERN" ]; then
        rm "$LINUX_RESUME_FILE_PATTERN"
        display_message "Linux resume file removed: $LINUX_RESUME_FILE_PATTERN"
    else
        display_message "Linux resume file not found: $LINUX_RESUME_FILE_PATTERN"
    fi
fi


display_message "Uninstallation complete."

exit 0