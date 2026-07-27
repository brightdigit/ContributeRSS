//
//  String.swift
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

import Foundation

/// Helpers for pulling a short summary out of feed prose.
///
/// Podcast `itunes:summary` values are inconsistent — some are HTML, some plain text —
/// so these extensions extract the first paragraph either way.
extension String {
  /// Matches an HTML `<p>` element, capturing its inner content.
  public static let allParagraphTagRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(pattern: "<p[^>]*>(.*?)</p>", options: [])
    } catch {
      preconditionFailure("Invalid allParagraphTagRegex pattern: \(error)")
    }
  }()

  /// Returns the first paragraph of this string, whether it is HTML or plain text.
  ///
  /// Prefers the first `<p>` element; if there is none, falls back to the first
  /// non-blank line.
  ///
  /// - Returns: The first paragraph, or `nil` if the string is empty or all whitespace.
  public func firstSummaryParagraph() -> String? {
    guard let htmlFirstParagraph = self.firstParagraphTag() else {
      return firstParagraphText()
    }

    return htmlFirstParagraph
  }

  /// Returns the first non-blank line, trimmed of surrounding whitespace.
  ///
  /// - Returns: The first non-blank line, or `nil` if there is none.
  public func firstParagraphText() -> String? {
    components(separatedBy: .newlines)
      .first { line in
        !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      }?
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Returns the content of the first HTML `<p>` element in this string.
  ///
  /// The captured content is returned as-is; any nested markup is preserved.
  ///
  /// - Returns: The first paragraph's inner HTML, or `nil` if there is no `<p>` element.
  public func firstParagraphTag() -> String? {
    let range = NSRange(location: 0, length: self.utf16.count)

    guard
      let match = String.allParagraphTagRegex.firstMatch(
        in: self,
        options: [],
        range: range
      )
    else {
      return nil
    }

    return (self as NSString).substring(with: match.range(at: 1))
  }
}
