# Synthesis checklist

Read this before producing the three artifacts in Phase 4 of the `video-to-ui` skill.

## The non-negotiables

1. **Every diff entry cites the frames that justify it.** If you can't cite a frame range, you don't have evidence for the recommendation — drop it. The user must be able to verify each diff by re-watching the cited frames.
2. **Reuse existing tokens.** Phase 2 read the target files. The diff list must reference token names that actually exist in those files (CSS custom properties, theme objects, Tailwind classes, design-token JSON keys) — not raw values, not invented names.
3. **No fake device chrome in editorial / illustrative components.** Status bars, tab bars, iOS notches, browser frames drawn into marketing illustrations or empty states is a known antipattern. Don't recommend adding chrome to a target that doesn't already have it.

## When the target has no token system

If Phase 2 found no design tokens / CSS variables / theme object:

- Add a "Prerequisite" heading at the top of the diff list.
- Recommend introducing a token layer as a separate first step (with a sketch of what tokens to introduce based on the observed design system).
- Don't silently invent token names downstream in the diff list — that creates parallel systems the next person has to reconcile.

## Diff list format

    <file path> (frames N–M, P–Q)
    - <change verb> <thing> from <old> → <new> (frame N: <one-phrase justification>).
    - <change verb> ...

Every bullet ends with a frame citation. Verbs to prefer: `replace`, `tighten`, `loosen`, `add`, `remove`, `swap`, `reorder`. Avoid mush like `update` or `improve` — say what changes.

If a change applies across many files (e.g. a token-value bump), put the change once in the tokens file's section and reference it from the consumer files rather than repeating.

## Smells to flag in the diagnosis itself

- The target's palette and the video's palette are *both* internally consistent but completely different families (e.g. target is warm neutrals, video is cool blues). Don't try to half-merge — flag it and ask whether to fully migrate or hold off.
- The video shows a screen the targets don't have. Flag it in the screen inventory as out-of-scope rather than inventing a redesign of an unrelated target.
- The video shows fast animation that the target stack can't easily replicate (shader effects, complex Lottie, custom WebGL). Flag the implementation cost in the diff list rather than recommending blindly.
- The video appears to use a paid font (e.g. Söhne, GT Walsheim) where the target uses a free alternative (Inter, IBM Plex). Flag the licensing dimension; don't silently recommend the swap.

## What "design system observed" should NOT include

- **Behavioral descriptions** ("user clicks here, then this happens") — that belongs in the screen inventory, not the design system.
- **Subjective adjectives** ("feels modern", "looks polished"). Stick to extractable signal.
- **Brand interpretation** ("this gives Stripe vibes"). The user can draw their own analogies.
- **Recommendations.** The design system artifact is a *description* of the video. Recommendations live in the diff list.
