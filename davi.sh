#!/bin/sh

# Default settings - Compatible with Termux
if [ -n "$TERMUX_VERSION" ]; then
    # Termux settings
    OUTPUT_DIR="${OUTPUT_DIR:-${HOME}/storage/downloads/media}"
    TERMUX_STORAGE="${HOME}/storage"
else
    # Regular Linux settings
    OUTPUT_DIR="${OUTPUT_DIR:-${HOME}/Downloads/media}" # Changed default for Linux
fi

CONFIG_FILE="${HOME}/.dlconfig"
# Resume file will be specific to the output directory
# Ensure OUTPUT_DIR is defined before RESUME_FILE
if [ -z "$OUTPUT_DIR" ]; then
    if [ -n "$TERMUX_VERSION" ]; then
        OUTPUT_DIR="${HOME}/storage/downloads/media"
    else
        OUTPUT_DIR="${HOME}/Downloads/media"
    fi
fi
RESUME_FILE="${OUTPUT_DIR}/.davi_resume_data" # Unique resume file name

# Load configuration from file
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
    fi
    # Ensure OUTPUT_DIR from config is used for resume file
    if [ -n "$OUTPUT_DIR" ]; then
        RESUME_FILE="${OUTPUT_DIR}/.davi_resume_data"
    fi
}

# Create default config file
create_default_config() {
    local default_dir
    if [ -n "$TERMUX_VERSION" ]; then
        default_dir="${HOME}/storage/downloads/media"
    else
        default_dir="${HOME}/Downloads/media" # Changed default for Linux
    fi
    
    cat > "$CONFIG_FILE" << EOF
# Video and Audio Download Settings
OUTPUT_DIR="${default_dir}"
VIDEO_FORMAT="mp4"
AUDIO_FORMAT="mp3"
VIDEO_QUALITY="best"
AUDIO_QUALITY="0"
EMBED_SUBS="yes"
AUTO_SUBS="no"
EOF
    echo "Config file created: $CONFIG_FILE"
}

# Show help
show_help() {
    cat << 'EOF'
Usage: $0 [Options] <video_or_playlist_url>

Options:
  audio               Download audio only
  video               Download video (default)
  playlist            Download full playlist
  --format FORMAT     Specify file format (mp4, mkv, webm for video | mp3, wav, m4a for audio)
  --quality QUALITY   Download quality (best, worst, 720p, 480p, etc)
  --resume            Resume interrupted downloads
  --config            Create a new config file
  --help              Display this help

Examples:
  $0 https://youtu.be/example
  $0 https://youtu.be/example audio
  $0 https://youtu.be/example playlist
  $0 https://youtu.be/example --format mkv --quality 720p
  $0 --resume
EOF
}

# Check required tools
check_dependencies() {
    # Check for yt-dlp
    if ! command -v yt-dlp >/dev/null 2>&1; then
        echo >&2 "Error: yt-dlp is not installed."
        if [ -n "$TERMUX_VERSION" ]; then
            echo >&2 "To install yt-dlp in Termux:"
            echo >&2 "  pkg install python"
            echo >&2 "  pkg install python-yt-dlp" # Recommended for Termux
        else
            echo >&2 "To install yt-dlp: pip install yt-dlp or use your system package manager."
            echo >&2 "  (e.g., sudo apt install yt-dlp / sudo dnf install yt-dlp)"
        fi
        exit 1
    fi
    
    # Check for ffmpeg
    if ! command -v ffmpeg >/dev/null 2>&1; then
        echo >&2 "Error: ffmpeg is not installed."
        if [ -n "$TERMUX_VERSION" ]; then
            echo >&2 "To install ffmpeg in Termux:"
            echo >&2 "  pkg install ffmpeg"
        else
            echo >&2 "To install ffmpeg: Use your system's package manager (e.g., sudo apt install ffmpeg)"
        fi
        exit 1
    fi
    
    # For Termux: Check storage permissions
    if [ -n "$TERMUX_VERSION" ] && [ ! -d "${HOME}/storage" ]; then
        echo "⚠️  Warning: Termux storage permissions are not set"
        echo "Please run the following command first:"
        echo "  termux-setup-storage"
        echo "Then rerun the script"
        exit 1
    fi
}

# Validate URL
validate_url() {
    if [ -z "$1" ]; then
        echo "Error: No URL provided."
        show_help
        exit 1
    fi
    
    if ! echo "$1" | grep -qE '^https?://'; then
        echo "Error: Invalid URL. Must start with http:// or https://"
        exit 1
    fi
}

# Create safe filename
get_safe_filename() {
    local url="$1"
    local title
    
    # Try to get title, if fails, use a generic name or part of URL
    title=$(yt-dlp --get-title "$url" 2>/dev/null | head -1)
    if [ -z "$title" ]; then
        echo "Failed to retrieve video title from: $url. Using URL hash as fallback." >&2
        title=$(echo "$url" | md5sum | head -c 16) # Use a hash of the URL as a fallback
    fi
    
    # Clean filename
    echo "$title" | sed -e 's/[\/:*?"<>|]/_/g' -e 's/^[[:space:].]*//' -e 's/[[:space:].]*$//' -e 's/__*/_/g'
}

# Check for existing file
check_existing_file() {
    local filename="$1"
    local extension="$2"
    local full_path="${OUTPUT_DIR}/${filename}.${extension}"
    
    if [ -f "$full_path" ]; then
        echo "Warning: File ${filename}.${extension} already exists."
        printf "Do you want to overwrite it? (y/N): "
        read -r -t 15 response # Add timeout
        response=${response:-N} # Default to No if no input
        case "$response" in
            [yY]|[yY][eE][sS]) return 0 ;;
            *) echo "Cancelled."; exit 0 ;;
        esac
    fi
}

# Save resume data
save_resume_data() {
    local url="$1"
    local mode="$2"
    local filename="$3"
    
    mkdir -p "$(dirname "$RESUME_FILE")"
    echo "${url}|${mode}|${filename}|$(date '+%Y-%m-%d %H:%M:%S')" >> "$RESUME_FILE"
}

# Resume interrupted downloads
resume_downloads() {
    if [ ! -f "$RESUME_FILE" ]; then
        echo "No interrupted downloads to resume."
        exit 0
    fi
    
    echo "🔄 Resume interrupted downloads..."
    # Read resume file and process each line. Use a temp file for remaining entries.
    local temp_resume_file="${RESUME_FILE}.tmp"
    > "$temp_resume_file" # Create/clear temp file
    
    local resumed_any="false"
    while IFS='|' read -r url mode filename timestamp; do
        if [ -n "$url" ] && [ -n "$mode" ] && [ -n "$filename" ]; then
            echo "Resuming: $filename ($timestamp)"
            # Attempt to download, if successful, do NOT write to temp file
            if download_content "$url" "$mode" "$filename" "--continue"; then
                echo "Successfully resumed and completed: $filename"
                resumed_any="true"
            else
                # If download fails again, keep it in the resume file
                echo "${url}|${mode}|${filename}|$(date '+%Y-%m-%d %H:%M:%S')" >> "$temp_resume_file"
            fi
        fi
    done < "$RESUME_FILE"
    
    # Replace old resume file with temp file (only if temp file has data)
    if [ -s "$temp_resume_file" ]; then # -s checks if file exists and is not empty
        mv "$temp_resume_file" "$RESUME_FILE"
        echo "Resume data updated. Some downloads still pending."
    else
        rm -f "$RESUME_FILE" "$temp_resume_file" # Clear both if all completed
        echo "All interrupted downloads completed or removed."
    fi
}

# Enhanced download progress display
# This hook processes output line by line.
# yt-dlp 2>&1 will send stdout and stderr to this function.
# We explicitly handle stderr from yt-dlp by directing it to /dev/stderr
progress_hook() {
    local line
    while IFS= read -r line; do
        # Check if the line is a progress update from yt-dlp
        if echo "$line" | grep -q "\[download\]"; then
            printf "\r%s" "$line" # Print on the same line
        elif echo "$line" | grep -q "Error" || echo "$line" | grep -q "ERROR"; then
            echo "$line" >&2 # Direct errors to stderr
        else
            echo "$line" # Print other lines normally
        fi
    done
}

# Download content
download_content() {
    local url="$1"
    local mode="$2"
    local safe_title="$3" # This is used for saving resume data, not directly for output name
    local resume_flag="$4"
    
    local format_selector
    local output_ext
    local extra_options=""
    local output_template="${OUTPUT_DIR}/%(title)s.%(ext)s" # Default template
    
    # Set download options based on type
    case "$mode" in
        "audio")
            format_selector="bestaudio"
            output_ext="$AUDIO_FORMAT"
            extra_options="--extract-audio --audio-format $AUDIO_FORMAT --audio-quality $AUDIO_QUALITY"
            echo "🔊 Downloading audio from: $url"
            ;;
        "playlist")
            format_selector="bv*+ba/best"
            output_ext="$VIDEO_FORMAT"
            extra_options="--yes-playlist"
            output_template="${OUTPUT_DIR}/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" # Playlist specific template
            echo "📂 Downloading playlist from: $url"
            ;;
        *) # Default is video
            format_selector="bv*+ba/best"
            output_ext="$VIDEO_FORMAT"
            echo "🎥 Downloading video (default) from: $url"
            ;;
    esac
    
    # Apply custom quality if set
    if [ -n "$custom_quality" ]; then
        format_selector="${format_selector}[height<=$custom_quality]" # Example: bestvideo[height<=720]+bestaudio
    fi

    # Add subtitle options
    if [ "$EMBED_SUBS" = "yes" ]; then
        extra_options="$extra_options --embed-subs --sub-langs ar,en"
    fi
    
    if [ "$AUTO_SUBS" = "yes" ]; then
        extra_options="$extra_options --write-auto-subs"
    fi
    
    # Construct the yt-dlp command
    local yt_dlp_cmd="yt-dlp \
        -f '$format_selector' \
        --merge-output-format $output_ext \
        -o '$output_template' \
        --add-metadata \
        --embed-thumbnail \
        --progress \
        --newline \
        $extra_options \
        $resume_flag \
        '$url'"
    
    echo "Executing command: $yt_dlp_cmd"
    
    # Execute download, capturing both stdout and stderr, then pipe to progress_hook
    # We use eval for correct handling of single quotes within the command string
    # And specifically redirect stderr to /dev/stderr from progress_hook to distinguish errors.
    if eval "$yt_dlp_cmd" 2>&1 | progress_hook; then
        echo "" # Newline after progress
        case "$mode" in
            "audio")
                echo "✅ Audio saved to: $OUTPUT_DIR"
                ;;
            "playlist")
                echo "✅ Playlist saved to: $OUTPUT_DIR"
                ;;
            *)
                echo "✅ Video saved to: $OUTPUT_DIR"
                ;;
        esac
        return 0 # Success
    else
        echo "" # Newline after progress
        echo "❌ Error: Download failed for $url." >&2
        save_resume_data "$url" "$mode" "$safe_title"
        echo "Resume data saved for this URL. Use --resume later." >&2
        return 1 # Failure
    fi
}

# Main function
main() {
    # Load settings early to get correct OUTPUT_DIR for resume file
    load_config
    
    # Process arguments
    mode="video"
    custom_format=""
    custom_quality="" # This will be passed to download_content
    url=""
    
    # Parse arguments
    local args=()
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --config)
                create_default_config
                exit 0
                ;;
            --resume)
                resume_downloads
                exit 0
                ;;
            --format)
                custom_format="$2"
                shift 2
                ;;
            --quality)
                custom_quality="$2"
                shift 2
                ;;
            audio|video|playlist)
                mode="$1"
                shift
                ;;
            http*://*)
                url="$1"
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
        esac
    done
    
    # Apply custom settings to override config for this run
    if [ -n "$custom_format" ]; then
        if [ "$mode" = "audio" ]; then
            AUDIO_FORMAT="$custom_format"
        else
            VIDEO_FORMAT="$custom_format"
        fi
    fi
    # custom_quality is handled directly in download_content

    # Check dependencies
    check_dependencies
    validate_url "$url"
    
    # Create output directory
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR" || {
            echo "Error: Failed to create directory $OUTPUT_DIR" >&2
            exit 1
        }
    fi
    
    # Get safe filename (for resume data and check_existing_file)
    safe_title=$(get_safe_filename "$url") || exit 1
    
    # Check for existing file (except playlists, which handle multiple files)
    if [ "$mode" != "playlist" ]; then
        if [ "$mode" = "audio" ]; then
            check_existing_file "$safe_title" "$AUDIO_FORMAT"
        else
            check_existing_file "$safe_title" "$VIDEO_FORMAT"
        fi
    fi
    
    # Start download
    download_content "$url" "$mode" "$safe_title"
}

# Run main function
main "$@"
