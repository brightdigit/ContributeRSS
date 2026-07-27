![ContributeRSS Logo](Sources/ContributeRSS/ContributeRSS.docc/Resources/ContributeRSSLogo.svg)

# ContributeRSS


[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FContributeRSS%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/ContributeRSS)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FContributeRSS%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/ContributeRSS)
[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/ContributeRSS/documentation)
[![License](https://img.shields.io/github/license/brightdigit/ContributeRSS)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/ContributeRSS/ContributeRSS.yml?label=actions&logo=github&branch=main)](https://github.com/brightdigit/ContributeRSS/actions)
[![Maintainability](https://qlty.sh/gh/brightdigit/projects/ContributeRSS/maintainability.svg)](https://qlty.sh/gh/brightdigit/projects/ContributeRSS)
[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/ContributeRSS)](https://codecov.io/gh/brightdigit/ContributeRSS)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/ContributeRSS)](https://www.codefactor.io/repository/github/brightdigit/ContributeRSS)

Create content for your site from RSS/Atom feeds.

---

## What is ContributeRSS?

[Contribute](https://github.com/brightdigit/Contribute) turns *your* source models into markdown
files with YAML front matter — but it deliberately stops short of fetching or decoding anything.
[SyndiKit](https://github.com/brightdigit/SyndiKit) does the opposite: it decodes RSS, Atom, and
JSON Feed into typed Swift models, and stops there.

**ContributeRSS is the piece in between.** It reads a podcast feed with SyndiKit, flattens each
entry into a plain `RSSContent.Source` value, and supplies the `FrontMatterTranslator` and
`MarkdownExtractor` conformances Contribute needs. The result is one markdown file per episode,
ready to drop into a static site generator's content folder.

`brightdigit.com` uses it to import the *Empower Apps* podcast archive into its Swift-based
Publish site.

### Resilient by design

Long-running podcast feeds accumulate irregularities, so decoding is deliberately forgiving in two
specific ways:

- **Missing episode artwork falls back to show artwork.** Older items often omit
  `<itunes:image>`; rather than dropping them, ContributeRSS substitutes the channel's
  `itunes:image` (or `<image>`).
- **Unusable items are skipped, not fatal.** An entry missing a duration, title, episode number,
  or summary — or carrying a non-`audio/mpeg` enclosure — is skipped and reported on standard
  error, so one bad entry never fails the whole import.

The one hard error is a missing item identifier: the `id` closure you supply may throw, and that
throw propagates out of `items(from:id:)`.

## Installation

Add ContributeRSS to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/brightdigit/ContributeRSS.git", from: "1.0.0-alpha.1")
]
```

Then add it to a target:

```swift
.target(
  name: "MySite",
  dependencies: [.product(name: "ContributeRSS", package: "ContributeRSS")]
)
```

## Usage

Two calls: decode the feed into sources, then write them out.

```swift
import Contribute
import ContributeRSS
import Foundation

let feedURL = URL(string: "https://example.com/podcast.xml")!

// 1. Decode. The closure derives a stable per-episode id from the feed item;
//    throw if the feed can't give you one.
let episodes = try RSSContent.items(from: feedURL) { item in
  guard let link = item.link else {
    throw RSSError.missingFieldFromPodcastEpisode(String(describing: item), .link)
  }
  return link.lastPathComponent
}

// 2. Write one markdown file per episode, named from the slugified title.
let htmlToMarkdown = SwiftSoupMarkdownGenerator().markdown(fromHTML:)

try RSSContent.write(
  episodes: episodes,
  atContentPathURL: URL(fileURLWithPath: "Content/episodes"),
  using: htmlToMarkdown
)
```

Each file looks like:

```markdown
---
title: Building a Swift Static Site Generator
date: 2026-06-29T12:00:00Z
description: How the brightdigit.com site is generated.
featuredImage: https://example.com/artwork/42.jpg
audioDuration: 2734
podcastID: building-a-swift-static-site-generator
---

The episode show notes, converted from HTML to clean markdown.
```

### What `RSSContent.Source` carries

`items(from:id:)` returns `[RSSContent.Source]` — one flat, `Sendable` value per episode:

| Property | Feed origin |
| --- | --- |
| `episodeNo` | `itunes:episode` |
| `slug` | slugified `itunes:title` |
| `title` | `itunes:title` |
| `date` | item `pubDate` |
| `summary` | first paragraph of `itunes:summary`, falling back to `itunes:subtitle` |
| `content` | `content:encoded`, falling back to `<description>` |
| `audioURL` | the `audio/mpeg` `<enclosure>` |
| `imageURL` | `itunes:image`, falling back to the channel artwork |
| `duration` | `itunes:duration` |
| `podcastID` | whatever your `id` closure returned |

Because `Source` is an ordinary struct, you can extend it or map it into a richer model — the
brightdigit.com site joins it against YouTube metadata before writing.

### Customizing the output

`write(episodes:...)` comes in four overloads. Beyond the defaults shown above, you can supply
your own `markdownExtractorType:` (how the body is rendered), your own
`frontMatterTranslatorType:` (what front matter your site expects), a `fileNameWithoutExtension:`
closure, and Contribute's `MarkdownContentBuilderOptions`:

```swift
try RSSContent.write(
  episodes: episodes,
  atContentPathURL: contentURL,
  using: htmlToMarkdown,
  markdownExtractorType: MySiteExtractor.self,
  frontMatterTranslatorType: MySiteFrontMatter.self,
  options: .init(shouldOverwriteExisting: true, includeMissingPrevious: false)
)
```

## Requirements

- Swift 6.4
- macOS 15+, iOS 16+, tvOS 16+, watchOS 9+
- Also built and tested on current Ubuntu (Noble), Windows, and Android in CI

## License

[MIT](LICENSE) © BrightDigit
