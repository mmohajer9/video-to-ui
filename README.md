<div align="center">

# video-to-ui

**A Claude Code skill that turns a UI screen recording into design data, code edits, or a runnable React scaffold.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Claude Code skill](https://img.shields.io/badge/Claude%20Code-skill-d97757)](https://docs.claude.com/en/docs/claude-code/skills)
[![Requires ffmpeg](https://img.shields.io/badge/requires-ffmpeg-007808)](https://ffmpeg.org/)

</div>

---

## What it does

Point the skill at a screen recording — a Figma prototype walkthrough, a mobile-app demo, a marketing clip, an internal Loom — and it returns one of four deliverables. You pick which one when the skill runs.

| #   | Mode                     | What you get                                                                                                                                                                                                                                                 |
| --- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | **Extract frames**       | A folder of PNGs from the video. No analysis, no synthesis. The fastest way to get the raw stills.                                                                                                                                                           |
| 2   | **Analyze the design**   | A markdown report describing the design system on screen — palette in hex, type scale, spacing rhythm, button and card styles, iconography — plus a chronological inventory of the distinct screens. No code.                                                |
| 3   | **Compare against code** | Mode 2, plus a per-file list of concrete edits to bring named target files closer to the video (`replace --button-radius 4px → 8px in Button.tsx, frame 014`). Always shows the diff list first and waits for approval before editing.                       |
| 4   | **Scaffold a React app** | Mode 2, plus a runnable **Vite + React + TypeScript + Tailwind + Framer Motion** project at `app/`, with one component per screen, a mock API that mimics the video's timing, and Tailwind tokens populated from the analysis. `npm install && npm run dev`. |

Modes 3 and 4 build on mode 2 — both run the same analysis under the hood, then act on it differently. Pick mode 3 if you have a codebase you want to bring closer to the design in the video; pick mode 4 if you want a runnable starting point.

## Install

### `npx` (fastest, via [skills.sh](https://skills.sh))

```bash
# project scope (drops into ./.claude/skills/video-to-ui)
npx skills add mmohajer9/video-to-ui --skill video-to-ui

# user scope (drops into ~/.claude/skills/video-to-ui)
npx skills add mmohajer9/video-to-ui --skill video-to-ui --global
```

To uninstall later: `npx skills rm video-to-ui`. Powered by the open-source [`vercel-labs/skills`](https://github.com/vercel-labs/skills) CLI.

### Plugin marketplace (in-app)

In Claude Code:

```text
/plugin marketplace add mmohajer9/video-to-ui
/plugin install video-to-ui@video-to-ui
```

### Manual drop-in (no Node, no Claude Code marketplace command)

```bash
git clone https://github.com/mmohajer9/video-to-ui.git ~/src/video-to-ui
ln -s ~/src/video-to-ui/skills/video-to-ui ~/.claude/skills/video-to-ui
```

After any of the above, restart Claude Code. The skill becomes available as `/video-to-ui` and auto-triggers on natural-language requests that match its description.

## How to invoke

The minimum invocation is a path to a video. The skill then asks which mode and where to put the output.

```text
/video-to-ui ~/Downloads/demo.mp4
```

It also auto-triggers on natural-language requests. Examples that route directly:

- *"What design system is this screen recording using? `~/demo.mp4`"* → mode 2
- *"Make the components in `src/components/` feel like this video: `demo.mp4`"* → mode 3
- *"Scaffold a working frontend app from this video"* → mode 4

A directory of pre-extracted frames works in place of a video, and skips the ffmpeg dependency:

```text
/video-to-ui /tmp/frames/
```

## Requirements

- **[ffmpeg](https://ffmpeg.org/)** — required for frame extraction. Skip if you bring pre-extracted frames.
  - macOS: `brew install ffmpeg`
  - Debian/Ubuntu: `sudo apt install ffmpeg`
  - Windows: `winget install Gyan.FFmpeg`
- **[Node.js ≥ 18](https://nodejs.org/)** — required for mode 4 only, to run the generated app. The skill scaffolds the project but does not run `npm install` for you.

## Pairs well with: `frontend-design`

In mode 4, if the [`frontend-design`](https://docs.claude.com/en/docs/claude-code/skills) skill is installed, the scaffolding subagent reads it before generating components and applies its layout, composition, and polish guidance on top of the video-derived design tokens. The video supplies the *signal* (palette, screen inventory, animation language); `frontend-design` supplies the *craftsmanship* (component composition, micro-interactions). The skill works without it — output is meaningfully richer with it.

## How it works under the hood

For modes 2–4, the skill walks the extracted frames in batches using a 2-tier subagent pattern. Disposable subagents read frame batches in parallel and write compact markdown reports to disk. The main agent reads only those reports — never the raw frame images. This keeps the main context small even on long recordings, and makes the cost roughly linear in the number of distinct screens rather than the total frame count.

In mode 4, a separate dedicated subagent receives the design report and curated frame set and writes the entire React project in one pass, so the generated code stays out of the main agent's context too.

The 2-tier walk is adapted from [fabriqaai/ffmpeg-analyse-video-skill](https://github.com/fabriqaai/ffmpeg-analyse-video-skill).

## Frame budget

Default extraction rate scales with video length:

| Length   | Default fps |
| -------- | ----------- |
| ≤ 2 min  | 1 fps       |
| 2–10 min | 0.5 fps     |
| > 10 min | 0.25 fps    |

The skill caps the resulting frame count: ≤ 120 proceed silently, 121–300 print a warning before continuing, > 300 require an explicit override. For long videos, pre-extract just the segments that matter and pass the frames folder.

## Scope and limitations

Things this skill is deliberately not:

- **Not an audio transcriber.** v1 has no Whisper / Gemini / OpenAI integration. If voiceover carries design intent ("make this calmer than the current page"), pass a notes file as the third argument or paste the relevant text into the conversation.
- **Not autonomous.** Mode 3 always shows the proposed edits first and waits for explicit approval. The approval gate is intentional — design judgments benefit from a human in the loop, and a wrong autopatch is harder to undo than a wrong recommendation.
- **Not a token-system fabricator.** If your target files have no design tokens or theme object, the skill flags that as a prerequisite step and stops short of inventing parallel tokens.
- **Mode 4 produces a scaffold, not a finished product.** The generated app is runnable and opinionated, with real components, real state, and a mock API that approximates the video's timing. It is a strong starting point, not a deliverable. Inferences about behaviors that weren't fully visible in the video are commented inline so you can replace them with real logic.

## Repo layout

```text
video-to-ui/
├── .claude-plugin/
│   └── marketplace.json        # registers the plugin so /plugin marketplace add works
├── skills/
│   └── video-to-ui/            # the skill itself
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── SKILL.md            # main skill instructions
│       ├── references/
│       │   ├── batch-analyzer.md      # disposable-subagent prompt template
│       │   └── synthesis-checklist.md # rules for the synthesis phase
│       └── scripts/
│           ├── extract-frames.sh      # ffmpeg wrapper with --help, validation, --scene mode
│           └── check-deps.sh          # ffmpeg/ffprobe presence check with install hints
├── README.md
├── LICENSE
├── CHANGELOG.md
└── CONTRIBUTING.md
```

## Related work

- **[fabriqaai/ffmpeg-analyse-video-skill](https://github.com/fabriqaai/ffmpeg-analyse-video-skill)** — origin of the 2-tier subagent pattern this skill borrows. Use it for general video summarization rather than UI-specific analysis.
- **[jordanrendric/claude-video-vision](https://github.com/jordanrendric/claude-video-vision)** — adds Whisper / Gemini / OpenAI audio transcription on top of frame analysis. Use it when voiceover content matters.
- **[JosiahSiegel/claude-plugin-marketplace](https://github.com/JosiahSiegel/claude-plugin-marketplace)** — community marketplace including a general-purpose `ffmpeg-master` plugin.

## Contributing

Issues and PRs welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for what kinds of changes are wanted (audio transcription, more mode-4 framework targets, test fixtures) and what's off-limits (autonomous edits in mode 3, fabricated tokens, fake device chrome on editorial components).

## License

MIT — see [LICENSE](LICENSE).
