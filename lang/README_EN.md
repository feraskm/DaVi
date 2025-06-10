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
    `git clone https://github.com/your_username/davi-youtube-downloader.git`
    `cd davi-youtube-downloader`

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

## Usage

Use the `dv` command followed by options and the video/playlist URL.

```bash
dv [Options] <video_or_playlist_url>