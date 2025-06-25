//
//  String+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 25.06.2025.
//

import Foundation

public extension String {
  func markdown() -> AttributedString? {
    try? AttributedString(markdown: self)
  }
}
