//
//  Source.swift
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

extension RSSContent {
  public struct Source: Sendable {
    public let episodeNo: Int
    public let slug: String
    public let title: String
    public let date: Date
    public let summary: String
    public let content: String
    public let audioURL: URL
    public let imageURL: URL
    public let duration: TimeInterval
    public let podcastID: String

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

private func require<Value>(
  _ value: Value?,
  _ error: @autoclosure () -> RSSError
) throws -> Value {
  guard let value else { throw error() }
  return value
}

extension RSSContent.Source {
  internal init(item: RSSItem, id: String, fallbackImageURL: URL? = nil) throws {
    let itemError = RSSError.invalidPodcastEpisodeFromRSSItem(String(describing: item))
    let content = try require(
      item.contentEncoded?.value ?? item.description?.value,
      itemError
    )
    let date = try require(item.published, itemError)

    guard case let .podcast(episode) = item.media else { throw itemError }

    func missing(_ field: RSSError.EpisodeField) -> RSSError {
      .missingFieldFromPodcastEpisode(String(describing: episode), field)
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
      episodeNo: episodeNo, slug: title.slugify(), title: title, date: date,
      summary: summary, content: content, audioURL: episode.enclosure.url,
      imageURL: imageURL, duration: duration, podcastID: id
    )
  }
}
