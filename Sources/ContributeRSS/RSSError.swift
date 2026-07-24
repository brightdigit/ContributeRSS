//
//  RSSError.swift
//  ContributeRSS
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

/// An error raised while turning a feed into episodes.
///
/// Most of these are per-item and non-fatal: ``RSSContent/items(from:id:)`` catches them,
/// logs the offending item to standard error, and moves on. ``invalidRSS(_:)`` is the
/// exception — it means the URL did not decode as an RSS feed at all.
public enum RSSError: ContributeError {
  /// The URL's contents did not decode as an RSS feed.
  case invalidRSS(URL)

  /// A feed item could not be read as a podcast episode.
  ///
  /// The payload is a description of the offending item, for logging.
  case invalidPodcastEpisodeFromRSSItem(String)

  /// A podcast episode was missing a field this package requires.
  ///
  /// The payload is a description of the offending episode plus the missing field.
  case missingFieldFromPodcastEpisode(String, EpisodeField)

  /// A field required to build a ``RSSContent/Source``.
  public enum EpisodeField: Sendable {
    /// `itunes:duration`.
    case duration

    /// `itunes:title`.
    case title

    /// `itunes:episode`, or an enclosure that is not `audio/mpeg`.
    case episode

    /// `itunes:summary` and `itunes:subtitle` were both absent.
    case summary

    /// `itunes:image`, with no channel artwork to fall back to.
    case imageHref

    /// The item `<link>`, used by callers that derive identifiers from it.
    case link
  }
}
