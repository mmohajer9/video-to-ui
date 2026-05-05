# Batch analyzer subagent prompt

Use this template for the disposable subagents spawned in Phase 3 of the `video-to-ui` skill. Interpolate `{frame_paths}`, `{batch_number}`, and `{batch_output_path}` before passing the prompt to the Agent tool.

The point of this template is to extract *design signal* per distinct screen — not a description of what's happening. The main agent reads many of these reports back-to-back, so terseness matters.

---

## Prompt template (interpolate the curly-brace fields)

You are analyzing a batch of frames extracted from a UI screen recording. This is batch {batch_number}.

Read each of these frame images in order:

{frame_paths}

Produce a compact markdown report capturing the design signal of each distinct screen. Output rules:

- **Collapse identical or near-identical adjacent frames** into a single entry. If frames 045–052 all show the same screen with no meaningful change, write one entry covering frames 045–052. Do not pad with one-entry-per-frame.
- **Per distinct screen**, emit a bullet block with these fields. Omit any field where you can't extract a clear signal — don't pad with guesses:
  - **Screen** — a short name (the dashboard, the empty state, the settings drawer).
  - **Frames** — the range covered (e.g. `045–052`).
  - **Colors** — 3–6 dominant hexes with role hints (`bg #0E0F12`, `surface #1A1C22`, `accent #6E5BFF`).
  - **Type** — hierarchy (heading 32px bold, body 14px regular), family if guessable.
  - **Layout** — the dominant pattern (grid 3-col, vertical stack, sidebar + main, full-bleed hero).
  - **Motifs** — corner radii, shadows, gradients, glass/blur, illustration style, iconography choices.
  - **Animation** — any transition or motion across the batch (fade, slide, parallax, hover state lift).
- **No prose paragraphs.** Bullets only. The main agent reads many of these reports and prose is expensive.
- **Be specific with hex codes** when you can read them confidently. If you have to guess, prefix with `~` (e.g. `~#6E5BFF`).
- **Don't editorialize.** No "looks polished", "feels modern", "Stripe-ish vibes". The main agent draws those analogies — your job is to extract observable signal.

Write the markdown to: `{batch_output_path}`

Return only: `wrote {batch_output_path}`

Do not return the markdown content itself — the main agent will read the file directly.

---

## Example output

```
# Batch 003 (frames 020–029)

- Screen: Empty inbox
  - Frames: 020–024
  - Colors: bg #0E0F12, surface #1A1C22, accent #6E5BFF, text #E8EAED, muted #8A8F9B
  - Type: heading 28px semibold, body 14px regular, family looks like Inter
  - Layout: vertical stack, centered, max-width ~480px
  - Motifs: 12px radius cards, soft 0 8 24 rgba shadow, line icons
  - Animation: subtle fade-in on mount, ~200ms

- Screen: Compose drawer
  - Frames: 025–029
  - Colors: surface #1A1C22 (drawer), accent #6E5BFF (send button), border #2A2D36
  - Type: input 14px regular, send-button label 13px medium
  - Layout: bottom drawer, ~60% viewport height, slide-up
  - Motifs: 16px top radius, no shadow (uses border instead), filled send button
  - Animation: spring slide-up, ~300ms
```
