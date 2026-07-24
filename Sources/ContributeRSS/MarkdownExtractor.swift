//
//  MarkdownExtractor.swift
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
  /// Produces the Markdown body of an episode from its show notes.
  ///
  /// The show notes are returned unchanged; Contribute applies the caller's
  /// HTML-to-Markdown conversion to the finished document, so this extractor
  /// deliberately ignores the conversion closure it is handed.
  public struct MarkdownExtractor: Contribute.MarkdownExtractor {
    /// The episode model this extractor reads.
    public typealias SourceType = Source

    /// Creates an extractor.
    public init() {}

    /// Returns the episode's show notes as the Markdown body.
    ///
    /// - Parameters:
    ///   - source: The episode to render.
    ///   - htmlToMarkdown: Ignored; the conversion is applied downstream by Contribute.
    /// - Returns: The episode's ``RSSContent/Source/content``, unmodified.
    /// - Throws: Never; the signature is `throws` to satisfy the protocol requirement.
    public func markdown(
      from source: SourceType,
      using htmlToMarkdown: @escaping (String) throws -> String
    ) throws -> String {
      source.content
    }
  }
}
