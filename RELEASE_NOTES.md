# Release Notes

## Unreleased

Wave 1 split-off (brightdigit/ContributeRSS #1, head `brightdigit-com-260717`) — the
`ContributeRSS` module was extracted from the brightdigit.com monorepo into this standalone
package via `git subrepo push`, then brought up to the shared BrightDigit package standard.

### Library

- Initial standalone `ContributeRSS` library: `RSSContent` (a Contribute `ContentType`),
  `RSSContent.Source`, `RSSContent.FrontMatterTranslator`, `RSSContent.MarkdownExtractor`,
  the `RSSContent.write(episodes:...)` overloads, and `RSSError`.
- `RSSContent.items(from:id:)` decodes a podcast feed with SyndiKit and returns one `Source`
  per usable item. Episodes with no `<itunes:image>` fall back to the channel artwork instead
  of being dropped; items that cannot be decoded at all are logged to standard error and
  skipped rather than failing the whole feed.
- Apple platform floors raised to macOS 15 / iOS 16 / tvOS 16 / watchOS 9 to match the Publish
  stack's `Synchronization.Mutex` requirement and standalone SyndiKit consumption.
- Dependencies resolve from remote branches (`brightdigit/Contribute`, `brightdigit/SyndiKit`)
  rather than monorepo paths, so the package builds standalone.

### Tests

- Added the `ContributeRSSTests` target with a module-load smoke test. Real coverage of the
  feed-decoding paths is still outstanding.

### CI

- Added the shared BrightDigit workflow set: `ContributeRSS.yml` (Ubuntu, macOS, Apple platform
  simulators, Windows, Android, lint), plus `check-unsafe-flags.yml`, `claude-code-review.yml`,
  `claude.yml`, `cleanup-caches.yml`, and `swift-source-compat.yml`.
- `fail-fast: true` on all four build matrices.
- Ubuntu coverage now uses upstream `sersoft-gmbh/swift-coverage-action@v5` instead of the
  SHA-pinned BrightDigit fork, without `fail-on-empty-output`; the Codecov upload drops
  `verbose`.
- `build-macos-platforms` adds a visionOS leg (Apple Vision Pro, 27.0) and drops the
  `ENABLE_WATCHOS` gate on the watchOS leg.
- Added `.github/dependabot.yml` (weekly SwiftPM updates) and `codecov.yml` (ignores `Tests/`).
- `.devcontainer/devcontainer.json` moved to the `swiftlang/swift:nightly-6.4.x-noble` image.
- `.spi.yml` documentation build pinned to Swift `"6.4"`.
- Adopted the shared strict `.swift-format` / `.swiftlint.yml` pair, which requires
  documentation on every public declaration.

### Docs

- Full README: badges, what the package does, installation, usage, the `Source` field table,
  and accurate requirements.
- Added the `ContributeRSS.docc` catalog with a real landing page and a placeholder logo.
- `AGENTS.md` is now the canonical agent instruction file; `CLAUDE.md` is a symlink to it.
  Added `.claude/agent-notes.md` and the shared `.claude/skills/` set.
