//
//  FrontMatterTranslator.swift
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

extension RSSContent {
  /// Maps an episode onto the front matter written above the Markdown body.
  ///
  /// This is the default translator, producing the field set `brightdigit.com` expects.
  /// Sites wanting a different shape pass their own type to the
  /// `write(episodes:atContentPathURL:using:frontMatterTranslatorType:options:)` overload.
  public struct FrontMatterTranslator: Contribute.FrontMatterTranslator {
    /// The episode model this translator reads.
    public typealias SourceType = Source

    /// The encodable front matter this translator produces.
    public typealias FrontMatterType = FrontMatter

    /// The YAML front matter emitted for one episode.
    ///
    /// Encodes as `title`, `date`, `description`, `featuredImage`, `audioDuration`
    /// (seconds, rounded down), and `podcastID`.
    public struct FrontMatter: Codable {
      internal let title: String
      internal let date: String
      internal let description: String
      internal let featuredImage: URL
      internal let audioDuration: Int
      internal let podcastID: String

      /// Creates front matter from an episode.
      ///
      /// - Parameter episode: The episode to describe.
      public init(episode: Source) {
        title = episode.title
        date = YAML.dateFormatter.string(from: episode.date)
        description = episode.summary
        featuredImage = episode.imageURL
        audioDuration = Int(episode.duration)
        podcastID = episode.podcastID
      }
    }

    /// Creates a translator.
    public init() {}

    /// Builds the front matter for one episode.
    ///
    /// - Parameter source: The episode to describe.
    /// - Returns: The encodable front matter for that episode.
    public func frontMatter(from source: Source) -> FrontMatter {
      FrontMatter(episode: source)
    }
  }
}
