# Release Notes

## 1.0.0-alpha.1

First release of ContributeRSS as a standalone package, split out of the brightdigit.com
monorepo. It imports content from RSS and Atom feeds into Markdown via the
[Contribute](https://github.com/brightdigit/Contribute) framework, backed by
[SyndiKit](https://github.com/brightdigit/SyndiKit) for feed parsing.

### Library
* Provide the Contribute importer trio for feeds — `Source`, `FrontMatterTranslator` and `MarkdownExtractor` — over `RSSContent` by @leogdion in https://github.com/brightdigit/ContributeRSS/pull/1
* Add `RSSContent+Write` for emitting imported entries as Markdown, plus `RSSError` for import failures by @leogdion in https://github.com/brightdigit/ContributeRSS/pull/1
* Build on `swift-tools-version:6.4` with complete strict concurrency, depending on Contribute and SyndiKit by remote URL rather than a monorepo path by @leogdion in https://github.com/brightdigit/ContributeRSS/pull/1

### Documentation
* Add a `ContributeRSS.docc` catalog with logo resources by @leogdion in https://github.com/brightdigit/ContributeRSS/pull/1

### Tooling & CI
* Add the shared multi-platform CI template (macOS/Linux/Windows/Android) with mise-based linting via `.mise.toml`, `.swift-format`, `.swiftlint.yml` and `Scripts/lint.sh` by @leogdion in https://github.com/brightdigit/ContributeRSS/pull/1
