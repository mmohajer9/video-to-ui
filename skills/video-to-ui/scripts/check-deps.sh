#!/usr/bin/env bash
# check-deps.sh — verify ffmpeg/ffprobe are on PATH.
# Part of the video-to-ui skill.

set -u

missing=0
for cmd in ffmpeg ffprobe; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing=1
  fi
done

if [[ $missing -eq 0 ]]; then
  ffmpeg -version | head -1
  exit 0
fi

cat >&2 <<'EOF'
error: ffmpeg (and/or ffprobe) not found on PATH.

The video-to-ui skill needs both ffmpeg and ffprobe to extract and probe frames.

Install:
  macOS:          brew install ffmpeg
  Debian/Ubuntu:  sudo apt update && sudo apt install ffmpeg
  Windows:        winget install Gyan.FFmpeg
                  (or)  choco install ffmpeg
  Other:          https://ffmpeg.org/download.html

After installing, restart your terminal (or run `hash -r`) and re-run the skill.

If you already have a frames folder ready, you can pass that directory directly to
the skill instead of a video file — ffmpeg is only needed for extraction.
EOF
exit 1
