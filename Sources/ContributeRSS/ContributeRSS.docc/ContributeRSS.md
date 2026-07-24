# ``ContributeRSS``

Turn podcast RSS feeds into Markdown files with YAML front matter.

## Overview

`ContributeRSS` is the RSS/Atom bridge between
[SyndiKit](https://github.com/brightdigit/SyndiKit) and
[Contribute](https://github.com/brightdigit/Contribute).

SyndiKit decodes a feed into typed models; Contribute owns the generic
source-model → Markdown-file pipeline. This package supplies the missing middle
piece: a ``RSSContent/Source`` model built from a podcast feed item, plus the
``RSSContent/FrontMatterTranslator`` and ``RSSContent/MarkdownExtractor``
conformances that Contribute needs in order to write one Markdown file per
episode.

The entry point is ``RSSContent/items(from:id:)``, which downloads and decodes a
feed URL and returns one ``RSSContent/Source`` per usable episode. Pass those
sources to one of the ``RSSContent`` `write(episodes:atContentPathURL:...)`
overloads to emit the files.

```swift
import ContributeRSS
import Foundation

let episodes = try RSSContent.items(from: feedURL) { item in
  guard let guid = item.guid?.rawValue else { throw MyError.missingGUID }
  return guid
}

try RSSContent.write(
  episodes: episodes,
  atContentPathURL: URL(fileURLWithPath: "Content/episodes"),
  using: { html in try htmlToMarkdown(html) }
)
```

### Resilient decoding

Feeds accumulate irregularities over the years, so decoding is deliberately
forgiving in two places:

- An episode with no `<itunes:image>` falls back to the channel's show artwork
  rather than being dropped.
- An item that cannot be turned into a ``RSSContent/Source`` at all (missing
  duration, title, episode number, summary, or a non-audio enclosure) is skipped
  and logged to standard error, so a single malformed entry never fails a whole
  import.

A missing item identifier is the one hard error: the `id` closure passed to
``RSSContent/items(from:id:)`` may throw, and that throw propagates.

## Topics

### Content Type

- ``RSSContent``

### Errors

- ``RSSError``
