//
//  Source.swift
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
import SyndiKit

extension RSSContent {
  /// A single podcast episode, flattened out of an RSS feed item.
  ///
  /// This is the `SourceType` the rest of the pipeline is generic over. Values are
  /// normally produced by ``RSSContent/items(from:id:)`` rather than constructed by
  /// hand, but the memberwise initializer is public so callers can synthesize
  /// episodes in tests or merge in metadata from another service.
  public struct Source: Sendable {
    /// The episode number, from `itunes:episode`.
    public let episodeNo: Int

    /// A URL-safe slug derived from the episode title, used as the file name.
    public let slug: String

    /// The episode title, from `itunes:title`.
    public let title: String

    /// The publication date of the feed item.
    public let date: Date

    /// A short description: the first paragraph of `itunes:summary`, falling back
    /// to `itunes:subtitle`.
    public let summary: String

    /// The full show notes, from `content:encoded` or the item `<description>`.
    ///
    /// Usually HTML — the HTML-to-Markdown conversion is the caller's, applied
    /// downstream by Contribute.
    public let content: String

    /// The `audio/mpeg` enclosure URL for the episode audio.
    public let audioURL: URL

    /// Episode artwork, from `itunes:image`, falling back to the channel artwork.
    public let imageURL: URL

    /// The episode length in seconds, from `itunes:duration`.
    public let duration: TimeInterval

    /// The caller-supplied identifier for this episode.
    ///
    /// Whatever the `id` closure passed to ``RSSContent/items(from:id:)`` returned —
    /// a GUID, a link slug, or any other stable per-episode key.
    public let podcastID: String

    /// Creates an episode source from its component fields.
    ///
    /// - Parameters:
    ///   - episodeNo: The episode number.
    ///   - slug: A URL-safe slug used as the output file name.
    ///   - title: The episode title.
    ///   - date: The publication date.
    ///   - summary: A short description.
    ///   - content: The full show notes.
    ///   - audioURL: The episode audio URL.
    ///   - imageURL: The episode artwork URL.
    ///   - duration: The episode length in seconds.
    ///   - podcastID: A stable per-episode identifier.
    public init(
      episodeNo: Int,
      slug: String,
      title: String,
      date: Date,
      summary: String,
      content: String,
      audioURL: URL,
      imageURL: URL,
      duration: TimeInterval,
      podcastID: String
    ) {
      self.episodeNo = episodeNo
      self.slug = slug
      self.title = title
      self.date = date
      self.summary = summary
      self.content = content
      self.audioURL = audioURL
      self.imageURL = imageURL
      self.duration = duration
      self.podcastID = podcastID
    }
  }
}

private let rssDiagnosticLimit = 120

private func boundedRSSDiagnostic(_ value: String, limit: Int = rssDiagnosticLimit) -> String {
  guard value.count > limit else {
    return value
  }
  return String(value.prefix(limit)) + "…"
}

private func boundedRSSItemDiagnostic(_ item: RSSItem) -> String {
  let title = item.title ?? "(untitled)"
  let link = item.link?.absoluteString ?? "(no link)"
  return boundedRSSDiagnostic("title=\(title), link=\(link)")
}

private func boundedPodcastEpisodeDiagnostic(_ episode: any PodcastEpisode) -> String {
  let title = episode.title ?? "(untitled)"
  return boundedRSSDiagnostic("title=\(title)")
}

private func require<Value>(
  _ value: Value?,
  _ error: @autoclosure () -> RSSError
) throws -> Value {
  guard let value else { throw error() }
  return value
}

extension RSSContent.Source {
  internal init(item: RSSItem, id: String, fallbackImageURL: URL? = nil) throws {
    let itemError = RSSError.invalidPodcastEpisodeFromRSSItem(boundedRSSItemDiagnostic(item))
    let content = try require(
      item.contentEncoded?.value ?? item.description?.value,
      itemError
    )
    let date = try require(item.published, itemError)

    guard case .podcast(let episode) = item.media else { throw itemError }

    func missing(_ field: RSSError.EpisodeField) -> RSSError {
      .missingFieldFromPodcastEpisode(boundedPodcastEpisodeDiagnostic(episode), field)
    }

    let duration = try require(episode.duration, missing(.duration))
    let title = try require(episode.title, missing(.title))
    let episodeNo = try require(episode.episode, missing(.episode))
    let summary = try require(
      episode.summary?.firstSummaryParagraph() ?? episode.subtitle, missing(.summary)
    )
    // Fall back to the show artwork when an episode has no per-episode image,
    // so an imageless (usually older) episode is enriched rather than dropped.
    let imageURL = try require(
      episode.image?.href ?? fallbackImageURL, missing(.imageHref)
    )

    guard episode.enclosure.type == "audio/mpeg" else { throw missing(.episode) }

    self.init(
      episodeNo: episodeNo,
      slug: title.slugify(),
      title: title,
      date: date,
      summary: summary,
      content: content,
      audioURL: episode.enclosure.url,
      imageURL: imageURL,
      duration: duration,
      podcastID: id
    )
  }
}
