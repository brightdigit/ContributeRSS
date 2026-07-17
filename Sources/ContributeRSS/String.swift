//
//  String.swift
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

import Foundation

extension String {
  public static let allParagraphTagRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(pattern: "<p[^>]*>(.*?)</p>", options: [])
    } catch {
      preconditionFailure("Invalid allParagraphTagRegex pattern: \(error)")
    }
  }()

  public func firstSummaryParagraph() -> String? {
    guard let htmlFirstParagraph = self.firstParagraphTag() else {
      return firstParagraphText()
    }

    return htmlFirstParagraph
  }

  public func firstParagraphText() -> String? {
    components(separatedBy: .newlines)
      .first { line in
        !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      }?
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

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
