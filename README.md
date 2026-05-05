<div align="center">

# video-to-ui

**Drop a UI screen recording. Get back a real working frontend.**

A Claude Code skill that turns a screen recording (mobile demo, Figma prototype, marketing clip, anything) into one of five things — extracted frames, a design-system report, codebase edits, a clickable HTML/CSS/JS mockup, or a working Vite + React + TypeScript + Tailwind app you can `npm run dev`.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757)](https://docs.claude.com/en/docs/claude-code/skills)
[![ffmpeg](https://img.shields.io/badge/requires-ffmpeg-007808)](https://ffmpeg.org/)

</div>

---

## Why this exists

Most "video understanding" tools give you a transcript or a summary of what happens in the clip. That's not what you want from a UI demo. You want the **design language** out of it, and ideally something runnable that captures the *behavior* — not just the look.

`video-to-ui` is built for that. The skill walks the frames with disposable subagents (so the main context never sees raw frames), synthesizes a design system, and then either reports it, applies it to your code, or scaffolds a real app from it.

## What you can do with it

When you run the skill, it asks which mode you want:

| #   | Mode                            | What you get                                                                                                                                                                                                           |
| --- | ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Extract frames**              | A folder of PNGs from the video. No analysis. Fast.                                                                                                                                                                    |
| 2   | **Analyze the design**          | A markdown report: palette in hex, type scale, spacing rhythm, button/card styles, plus a chronological list of distinct screens.                                                                                      |
| 3   | **Compare to your code**        | Mode 2, plus a diff list of edits ("change `--button-radius` 4px → 8px in `Button.tsx`") against files you point it at. **Always asks before editing.**                                                                |
| 4   | **Build an HTML/CSS/JS mockup** | A clickable, vanilla-JS preview at `mockup/index.html`. No framework. No build step. Open in a browser.                                                                                                                |
| 5   | **Build a real frontend app**   | A working **Vite + React + TypeScript + Tailwind + Framer Motion** app at `app/`. Real components, real state, working interactions, mock API that streams the same way the video shows. `npm install && npm run dev`. |

Modes 3, 4, and 5 are alternative deliverables that all build on mode 2. Pick one based on what you want at the end.

## Install

### Option A — Plugin marketplace (recommended)

In Claude Code:

```text
/plugin marketplace add mmohajer9/video-to-ui
/plugin install video-to-ui@video-to-ui
```

That's it. Restart and the skill is available.

### Option B — Drop-in to a single project

```bash
git clone https://github.com/mmohajer9/video-to-ui.git
mkdir -p .claude/skills
cp -r video-to-ui/skills/video-to-ui .claude/skills/video-to-ui
```

### Option C — Make it available everywhere

```bash
git clone https://github.com/mmohajer9/video-to-ui.git ~/src/video-to-ui
ln -s ~/src/video-to-ui/skills/video-to-ui ~/.claude/skills/video-to-ui
```

## Use it

The simplest invocation is just a video path:

```text
/video-to-ui ~/Downloads/demo.mp4
```

The skill will ask which mode. You can also be conversational:

- *"I have a screen recording at `~/demo.mp4` — what design system is it using?"* → mode 2
- *"Make the components in `src/components/` feel like this video: `demo.mp4`"* → mode 3
- *"Build me a working frontend app from this video"* → mode 5

Pre-extracted frames work too — pass a folder instead of a video and `ffmpeg` isn't needed:

```text
/video-to-ui /tmp/frames/
```

## Requirements

- **[ffmpeg](https://ffmpeg.org/)** for frame extraction (skip if you bring pre-extracted frames).
  - macOS: `brew install ffmpeg`
  - Debian/Ubuntu: `sudo apt install ffmpeg`
  - Windows: `winget install Gyan.FFmpeg`
- **[Node.js ≥ 18](https://nodejs.org/)** — only for mode 5 (running the generated app).

## How it stays cheap on context

For modes 2–5, the skill walks frames in batches using a 2-tier subagent pattern: disposable subagents read frame batches and emit compact markdown notes, the main agent reads only the notes — never raw frames. On a 10-minute video this is roughly a 90% context reduction vs. naive whole-video analysis.

In modes 4 and 5, a separate dedicated subagent receives the design report and curated frames and writes the deliverable in one pass, so the main agent's context never holds the generated code either.

(The 2-tier pattern is adapted from [fabriqaai/ffmpeg-analyse-video-skill](https://github.com/fabriqaai/ffmpeg-analyse-video-skill).)

## Frame budget

Default extraction rate scales with video length:

| Length   | Default fps |
| -------- | ----------- |
| ≤ 2 min  | 1 fps       |
| 2–10 min | 0.5 fps     |
| > 10 min | 0.25 fps    |

The skill enforces a budget on the resulting frame count: ≤ 120 frames proceed silently, 121–300 warn, > 300 require an explicit override. For very long videos, pre-extract just the segments you care about.

## Limitations

- **No audio transcription** in v1 — pass a notes file as the third argument if voiceover matters.
- **No autonomous code edits** — mode 3 always shows changes first and waits for approval. This is core to the skill's value, not a bug.
- **No invented design tokens** — if your target files have no token system, the skill flags it instead of fabricating one.
- **Mode 4 mockup** is a static visualization, not production code.
- **Mode 5 app** is a strong scaffold, not a finished product. Mocked behaviors are commented inline so you can swap them for real ones.

## Repo layout

```text
video-to-ui/
├── .claude-plugin/
│   └── marketplace.json        # makes /plugin marketplace add work
├── skills/
│   └── video-to-ui/            # the actual skill
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── SKILL.md            # main skill instructions
│       ├── references/         # subagent prompts + checklists
│       │   ├── batch-analyzer.md
│       │   └── synthesis-checklist.md
│       └── scripts/
│           ├── extract-frames.sh
│           └── check-deps.sh
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

## Related work

- **[fabriqaai/ffmpeg-analyse-video-skill](https://github.com/fabriqaai/ffmpeg-analyse-video-skill)** — parent of the 2-tier subagent pattern. Use it for general video summarization.
- **[jordanrendric/claude-video-vision](https://github.com/jordanrendric/claude-video-vision)** — adds Whisper / Gemini / OpenAI audio transcription. Use it if you need voiceover captured.
- **[JosiahSiegel/claude-plugin-marketplace](https://github.com/JosiahSiegel/claude-plugin-marketplace)** — community marketplace with a general-purpose `ffmpeg-master` plugin.

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Areas where help is most useful right now:

- Audio transcription (mode 2/3/5 with voiceover context)
- More framework targets for mode 5 (Svelte, Vue, SolidJS)
- A test fixture set of short reference videos

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

If this saved you a Friday afternoon, **a star helps a lot.** ⭐

</div>
