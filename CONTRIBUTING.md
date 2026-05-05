# Contributing to video-to-ui

Thanks for your interest. This is a small skill, so contributing is mostly:

1. Open an issue describing what you'd like to change. For bug reports include the video length, fps used, and the mode you ran.
2. For non-trivial changes, get a 👍 on the issue before opening a PR — saves you wasted effort if the direction is wrong.
3. Send the PR. Keep it focused: one change, one PR.

## Local development

The skill lives in [`skills/video-to-ui/`](skills/video-to-ui/). To test edits without reinstalling:

```bash
git clone https://github.com/mmohajer9/video-to-ui.git
ln -s "$PWD/video-to-ui/skills/video-to-ui" ~/.claude/skills/video-to-ui
```

Restart Claude Code. Now `~/.claude/skills/video-to-ui` points at the repo, so any edit is live.

## What changes are wanted

High-leverage:

- **Audio transcription** for voiceover-driven videos (mode 2, 3, 5). Whisper local, OpenAI API, or Gemini are all reasonable.
- **More mode-4 framework targets** — Svelte, Vue, SolidJS, plain Next.js. Each lives behind a small flag in the scaffold subagent's brief.
- **Better screen-deduplication** — currently the curated frame set is a heuristic per the synthesis-checklist; it under-clusters on long videos with subtle screen variants.
- **Test fixtures** — short reference videos (5–30s) covering common UI patterns (sheet, drawer, list, form, chart) that we can re-run the skill against to detect regressions.

Lower-priority:

- Windows-native script equivalents (the current bash scripts work in Git Bash / WSL).
- A `--dry-run` flag for mode 3 that prints the diff list to stdout without writing any files.

## What changes are NOT wanted

- **Autonomous edit mode** for mode 3. The approval gate is core to the skill — it's not slow, it's the value. PRs that bypass it will be closed.
- **Invented design tokens.** If a target codebase has no token system, the skill flags it. Don't change that to silently fabricate one.
- **Fake device chrome on editorial components.** A marketing landing page with a fake screenshot vibe is a known antipattern; the skill explicitly avoids producing it.

## Style

- Bash scripts use `set -euo pipefail` and validate args before running ffmpeg.
- Markdown lints loosely — readability over strict mdlint. Inline HTML for centered headers is fine.
- SKILL.md is the source of truth for skill behavior; references/ files are subagent prompts. If you change behavior, update SKILL.md to match.
