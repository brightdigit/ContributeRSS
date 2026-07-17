//
//  RSSContent+Write.swift
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

extension RSSContent {
  public static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
      Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      using: htmlToMarkdown,
      markdownExtractorType: Self.MarkdownExtractorType.self,
      frontMatterTranslatorType: Self.FrontMatterTranslatorType.self
    )
  }

  public static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
      Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    markdownExtractorType: MarkdownExtractorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      using: htmlToMarkdown,
      markdownExtractorType: markdownExtractorType,
      frontMatterTranslatorType: Self.FrontMatterTranslatorType.self
    )
  }

  public static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
      Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    frontMatterTranslatorType: FrontMatterTranslatorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try self.write(
      episodes: episodes,
      atContentPathURL: contentPathURL,
      using: htmlToMarkdown,
      markdownExtractorType: Self.MarkdownExtractorType.self,
      frontMatterTranslatorType: frontMatterTranslatorType
    )
  }

  public static func write(
    episodes: [SourceType],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (SourceType) -> String =
      Self.fileNameWithoutExtensionFromSource(_:),
    using htmlToMarkdown: @escaping (String) throws -> String,
    markdownExtractorType: MarkdownExtractorType.Type,
    frontMatterTranslatorType: FrontMatterTranslatorType.Type,
    options: MarkdownContentBuilderOptions = []
  ) throws {
    try write(
      from: episodes,
      atContentPathURL: contentPathURL,
      fileNameWithoutExtension: fileNameWithoutExtension,
      using: htmlToMarkdown,
      options: options
    )
  }

  public static func fileNameWithoutExtensionFromSource(
    _ source: SourceType
  ) -> String {
    source.slug
  }
}
