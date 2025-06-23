//
//  ShapeStyle+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 23.06.2025.
//

import SwiftUI

#if DEBUG
/*
 Взято из youtube-видео "Prevent SwiftUI from re-rendering views".
 Usage:
  Text("Suspicious view")
    .border(.debug)
 */
extension ShapeStyle where Self == Color {
  public static var debug: Color {
    Color(
      .sRGB,
      red: .random(in: .range),
      green: .random(in: .range),
      blue: .random(in: .range),
      opacity: 1
    )
  }
}

private extension ClosedRange where Bound == Double {
  static let range = 0.1 ... 0.9
}
#endif // DEBUG
