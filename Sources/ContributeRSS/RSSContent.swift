//
//  RSSContent.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Contribute
import Foundation
import SyndiKit

public enum RSSContent: ContentType {
  public typealias SourceType = Source
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

extension RSSContent {
  public static func items(from rssURL: URL, id: (RSSItem) throws -> String) throws
    -> [Source]
  {
    let decoder = SynDecoder()
    let data = try Data(contentsOf: rssURL)
    let synfeed = try decoder.decode(data)
    guard let rssFeed = synfeed as? RSSFeed else {
      throw RSSError.invalidRSS(rssURL)
    }
    // Show artwork, used when an episode has no per-episode image (older episodes
    // omit `<itunes:image>`), so a missing image doesn't drop the episode.
    let showImageURL =
      rssFeed.channel.itunesImage.flatMap(URL.init(string:))
      ?? rssFeed.channel.image?.url
    return try rssFeed.channel.items.compactMap { item in
      // A missing id makes the whole feed invalid for us, so it throws here
      // rather than inside the per-item Source init.
      let id = try id(item)
      // Per-item parse failures are skipped (old/malformed episodes lack fields
      // we require) but logged, so a dropped episode is never silent.
      do {
        return try Source(item: item, id: id, fallbackImageURL: showImageURL)
      } catch {
        FileHandle.standardError.write(
          Data("import: skipping RSS item id=\(id): \(error)\n".utf8)
        )
        return nil
      }
    }
  }
}
