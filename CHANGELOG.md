# Changelog

All notable changes to this project will be documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-05-02

### Added

- Initial public release.
- Four modes: extract frames, analyze design, compare-and-edit, Vite + React + TypeScript + Tailwind app scaffold.
- 2-tier subagent pattern for context-efficient frame analysis (per-batch markdown summaries; main agent never reads raw frames).
- ffmpeg-based frame extraction with duration-aware default fps and a frame budget.
- Optional integration with the `frontend-design` skill in scaffold mode — when installed, its component-quality and aesthetic guidance is applied on top of the video-derived design tokens.
- Claude Code plugin marketplace metadata for one-line install via `/plugin marketplace add`.
