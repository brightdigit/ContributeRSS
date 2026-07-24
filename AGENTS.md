# AGENTS.md

This is the canonical agent instruction file for this repository. `CLAUDE.md` is a symlink to it.

## Overview

ContributeRSS is a Swift library (SPM package, product `ContributeRSS`) that turns podcast
RSS feeds into Markdown files with YAML front matter. It is the bridge between two other
BrightDigit packages:

- **[SyndiKit](https://github.com/brightdigit/SyndiKit)** decodes the feed into typed models.
- **[Contribute](https://github.com/brightdigit/Contribute)** owns the generic
  source-model → Markdown-file pipeline.

ContributeRSS supplies the middle piece: `RSSContent.Source` (a flat, `Sendable` per-episode
value built from a SyndiKit `RSSItem`) plus the `FrontMatterTranslator` and `MarkdownExtractor`
conformances Contribute requires.

It is consumed as a library; there is no executable target.

## Commands

Builds with the **Swift 6.4 toolchain** (`.swift-version` → `6.4.x-snapshot`; tools-version 6.4,
Swift 6 language mode). Use the matching snapshot / `Xcode-beta` toolchain locally.

- Build: `swift build`
- Build incl. tests: `swift build --build-tests`
- Run tests: `swift test`
- Run one test: `swift test --filter ContributeRSSTests`

### Linting

Lint tooling is pinned via **mise** (`.mise.toml`). The canonical entry point is
`Scripts/lint.sh`, which bootstraps tools with `mise install` then runs swift-format, SwiftLint,
and a build check (periphery and the `Scripts/header.sh` license-header rewrite run locally
only).

- Full lint + autofix (local): `Scripts/lint.sh`
- Format only: `FORMAT_ONLY=1 Scripts/lint.sh`
- CI/strict mode (no autofix, fails on warnings): `LINT_MODE=STRICT CI=1 Scripts/lint.sh`
- Individual tools: `mise exec -- swift-format ...`, `mise exec -- swiftlint`,
  `mise exec -- periphery scan -- --build-system native`

The SwiftLint and swift-format configs are the strict shared BrightDigit pair: `explicit_acl`,
`force_unwrapping`, `missing_docs`, and swift-format's
`AllPublicDeclarationsHaveDocumentation` are all on. **Every public declaration needs a doc
comment** — keep files small and ACLs explicit.

## Architecture

Everything hangs off `RSSContent`, an `enum` conforming to Contribute's `ContentType`:

- **`RSSContent.Source`** (`Sources/ContributeRSS/Source.swift`) — the per-episode model.
  Its `internal init(item:id:fallbackImageURL:)` is where all the SyndiKit-to-us mapping and
  validation lives.
- **`RSSContent.FrontMatterTranslator`** — maps a `Source` to the brightdigit.com front matter
  shape (title, date, description, featuredImage, audioDuration, podcastID).
- **`RSSContent.MarkdownExtractor`** — returns `source.content` verbatim; the HTML→Markdown
  conversion is the caller's injected closure, applied by Contribute.
- **`RSSContent.items(from:id:)`** (`RSSContent.swift`) — downloads and decodes a feed URL with
  SyndiKit's `SynDecoder`, then builds one `Source` per usable item.
- **`RSSContent.write(episodes:...)`** (`RSSContent+Write.swift`) — four convenience overloads
  over Contribute's generic `write(from:...)`.
- **`RSSError`** — the package's `ContributeError`, including the `EpisodeField` enum naming
  which required field was missing.

### Decoding is deliberately lossy

Two behaviors are intentional and must be preserved (there are comments in the source saying so):

1. **Show-artwork fallback.** Older episodes omit `<itunes:image>`; `items(from:id:)` passes the
   channel's artwork as `fallbackImageURL` so those episodes are enriched rather than dropped.
2. **Per-item skip, not per-feed failure.** A `Source` that fails to initialize is logged to
   standard error and skipped. Only a failure of the caller's `id` closure aborts the whole feed.

Don't "fix" either into a hard error without checking the podcast archive still imports.

## Dependencies

Both dependencies are BrightDigit-maintained and currently pinned to remote branches while the
brightdigit.com package split is in flight:

- `brightdigit/Contribute` — the generic source→Markdown pipeline.
- `brightdigit/SyndiKit` — RSS/Atom/JSON Feed decoding.

## CI

A single primary workflow, `.github/workflows/ContributeRSS.yml` (the shared BrightDigit
template — its filename must keep matching the package name, because the README's Actions badge
URL embeds it). It builds on Ubuntu (nightly-6.4 container), macOS + Apple platform simulators
(Xcode 27 / Swift 6.4), Windows, and Android. Matrix scope tiers up by ref: a small set always;
the full matrix plus Windows on `main`, semver tags, dispatch, and PRs into `main`. Skip CI with
`ci skip` in the commit message.

Auxiliary workflows: `check-unsafe-flags.yml`, `claude-code-review.yml`, `claude.yml`,
`cleanup-caches.yml`, `swift-source-compat.yml`.

## Coding Conventions

**Strict concurrency is mandatory.** The package is Swift 6 language mode with complete
concurrency checking. When a strict-concurrency error surfaces, fix it properly (add
`Sendable`/`@Sendable`, isolate with actors, restructure ownership) — never lower the language
mode, relax the setting, or silence the diagnostic to make it build.

## Memory & Corrections Convention

`.claude/agent-notes.md` is the canonical, versioned corrections log for this repository — an
append-only record of the maintainer's corrections and standing **always/never** directives.

- **Read `.claude/agent-notes.md` at the start of every work session, before doing any work.** It
  is the source of truth for *how* to work in this repo.
- **Whenever the maintainer makes a correction or gives an always/never instruction, append one
  line to `.claude/agent-notes.md` proactively (without being asked).** One line per directive,
  newest at the bottom. If a directive supersedes an earlier one, update or remove the stale line
  rather than leaving both.
