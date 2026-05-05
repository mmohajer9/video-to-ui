#!/usr/bin/env bash
# extract-frames.sh — extract frames from a video into an output directory.
# Part of the video-to-ui skill.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: extract-frames.sh <video> <out-dir> [--fps N] [--scene]

Extract frames from <video> into <out-dir> as zero-padded PNGs
(frame_00001.png, frame_00002.png, ...). Lexical sort = chronological order.

Options:
  --fps N    Frames per second to extract (default: 1).
  --scene    Use scene-change detection (threshold 0.3) instead of fixed fps.
             Better for marketing videos with rapid cuts.
  -h|--help  Show this help.

Examples:
  extract-frames.sh demo.mp4 /tmp/frames
  extract-frames.sh demo.mp4 /tmp/frames --fps 0.5
  extract-frames.sh trailer.mp4 /tmp/frames --scene

On success, prints "extracted N frames to <out-dir>" to stdout.
On failure, prints ffmpeg's stderr and exits non-zero.
EOF
}

if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 2 ]]; then
  echo "error: need at least <video> and <out-dir>" >&2
  echo >&2
  usage >&2
  exit 2
fi

video="$1"
outdir="$2"
shift 2

fps="1"
scene=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fps)
      [[ $# -ge 2 ]] || { echo "error: --fps needs a value" >&2; exit 2; }
      fps="$2"
      shift 2
      ;;
    --scene)
      scene=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      echo >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "error: ffmpeg not found on PATH" >&2
  echo "run check-deps.sh from this skill for install hints" >&2
  exit 3
fi

if [[ ! -e "$video" ]]; then
  echo "error: video file not found: $video" >&2
  exit 2
fi

if [[ ! -f "$video" ]]; then
  echo "error: not a regular file: $video" >&2
  exit 2
fi

if [[ ! -r "$video" ]]; then
  echo "error: video file not readable: $video" >&2
  exit 2
fi

mkdir -p "$outdir"

if [[ $scene -eq 1 ]]; then
  vf="select='gt(scene\,0.3)'"
  ffmpeg -hide_banner -loglevel error -i "$video" -vf "$vf" -vsync vfr "$outdir/frame_%05d.png"
else
  ffmpeg -hide_banner -loglevel error -i "$video" -vf "fps=$fps" "$outdir/frame_%05d.png"
fi

count=$(find "$outdir" -maxdepth 1 -type f -name 'frame_*.png' | wc -l | tr -d ' ')
echo "extracted $count frames to $outdir"
