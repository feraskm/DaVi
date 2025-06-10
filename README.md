# Davi YouTube Downloader

Davi is a simple yet powerful shell script that leverages `yt-dlp` to download videos and audio from YouTube and many other video-hosting sites. It's designed to be easy to use with common options and includes support for Termux on Android and various Linux distributions.

## Features

* **Download Videos/Audio:** Easily download videos, audio-only, or entire playlists.
* **Format & Quality Control:** Specify desired formats (mp4, mkv, mp3, etc.) and quality (best, 1080p, etc.).
* **Resume Downloads:** Automatically resumes interrupted downloads.
* **Subtitle Support:** Embed subtitles or download auto-generated ones.
* **Configurable:** Customize default settings via a simple configuration file.
* **Cross-Platform:** Works on Termux (Android) and various Linux distributions (Debian, Ubuntu, Fedora, Arch, Alpine).
* **Easy Alias:** Use a short `dv` command for quick access.

## Installation

1.  **Download the project:**
    Download the compressed file from the GitHub repository or clone it:
    `git clone https://github.com/feraskm/DaVi.git`
    `cd DaVi`

2.  **Run the installation script:**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

    The installer will:
    * Copy `davi.sh` to a suitable location in your `PATH`.
    * Create an alias `dv` in your `~/.bashrc` and `~/.zshrc` for easy access.
    * Create a default configuration file (`~/.dlconfig`) if it doesn't exist.
    * Provide instructions on how to install `yt-dlp` and `ffmpeg` for your specific system (Termux/Linux).

3.  **Install Dependencies:**
    Follow the instructions provided by the `install.sh` script to install `yt-dlp` and `ffmpeg`.
    * **For Termux:** `pkg install python python-yt-dlp ffmpeg` (and `termux-setup-storage`).
    * **For Linux:** Use your distribution's package manager (e.g., `sudo apt install yt-dlp ffmpeg`) or `pip`.

4.  **Reload your shell:**
    After installation, run `source ~/.bashrc` or `source ~/.zshrc` or restart your terminal to activate the `dv` alias.

## Usage:

Use the `dv` command followed by options and the video/playlist URL.

```bash
dv [Options] <video_or_playlist_url>
```

## Options:

* `audio`: Download audio only.
* `video`: Download video (default).
* `playlist`: Download full playlist.
* `--format` FORMAT: Specify file format (e.g., `mp4`, `mkv` for `video`; `mp3`, `wav` for audio).
* `--quality` QUALITY: Download quality (e.g., `best`, `worst, `720p`, `480p`).
* `--resume`: Resume interrupted downloads.
* `--config`: Create or recreate the default config file (`~/.dlconfig`).
* `--help`: Display help message.

## Examples:

```bash
dv [https://www.youtube.com/watch?v=dQw4w9WgXcQ](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
dv [https://www.youtube.com/watch?v=dQw4w9WgXcQ](https://www.youtube.com/watch?v=dQw4w9WgXcQ) audio
dv [https://www.youtube.com/playlist?list=PLqc_aT2_aC_jKkS_jXlZ_xZ_xZ_xZ_xZ](https://www.youtube.com/playlist?list=PLqc_aT2_aC_jKkS_jXlZ_xZ_xZ_xZ_xZ) playlist
dv [https://www.youtube.com/watch?v=dQw4w9WgXcQ](https://www.youtube.com/watch?v=dQw4w9WgXcQ) --format mkv --quality 720p
dv --resume
```
## Configuration
You can customize the default download settings by editing the `~/.dlconfig` file.
```bash
# Example content of ~/.dlconfig
OUTPUT_DIR="${HOME}/Downloads/media"
VIDEO_FORMAT="mp4"
AUDIO_FORMAT="mp3"
VIDEO_QUALITY="best"
AUDIO_QUALITY="0"
EMBED_SUBS="yes"
AUTO_SUBS="no"
```
## Uninstallation
To remove Davi and its associated files:
```bash
chmod +x uninstall.sh
./uninstall.sh
```
This will remove the script, the alias, and offer to remove the config file.

## Troubleshooting

* `yt-dlp` or `ffmpeg` not found: Ensure you have installed the dependencies as per the installation instructions.
* "externally-managed-environment" error with pip: On newer Python versions, pip might restrict global installs. Try `sudo pip install yt-dlp --break-system-packages` with caution, or use your system's package manager.
* Termux Storage: If you encounter storage issues in Termux, run `termux-setup-storage`.

## Contributing

Feel free to open issues or pull requests on the GitHub repository if you have suggestions for improvements or bug fixes.
