//
//  View+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import SwiftUI

/// Famous
extension View {
  @ViewBuilder public func `if`<Content: View>(
    _ condition: Bool,
    transform: (Self) -> Content
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}


/// Others
extension View {
  @ViewBuilder public func iconSymbolEffect() -> some View {
    if #available(iOS 18, *) {
      self.symbolEffect(
        .wiggle,
        options: .repeat(.periodic(nil, delay: 5)).speed(0.7),
        isActive: true
      )
    } else if #available(iOS 17, *) {
      self.symbolEffect(.pulse, options: .repeating, isActive: true)
    } else {
      self
    }
  }
}
