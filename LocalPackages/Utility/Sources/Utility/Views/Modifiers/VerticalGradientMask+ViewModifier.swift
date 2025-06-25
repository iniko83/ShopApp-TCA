//
//  VerticalGradientMask+ViewModifier.swift
//  Utility
//
//  Created by Igor Nikolaev on 25.06.2025.
//

import SwiftUI

extension View {
  public func verticalGradientMask(
    padding: Double,
    edgeOpacity: Double = 1
  ) -> some View {
    modifier(
      VerticalGradientMaskModifier(
        topPadding: padding,
        bottomPadding: padding,
        topOpacity: edgeOpacity,
        bottomOpacity: edgeOpacity
      )
    )
  }
  
  public func verticalGradientMaskWithPaddings(
    top: Double = .zero,
    bottom: Double = .zero,
    topOpacity: Double = 0,
    bottomOpacity: Double = 0
  ) -> some View {
    modifier(
      VerticalGradientMaskModifier(
        topPadding: top,
        bottomPadding: bottom,
        topOpacity: topOpacity,
        bottomOpacity: bottomOpacity
      )
    )
  }
}

struct VerticalGradientMaskModifier: ViewModifier {
  static let defaultLocations: [Double] = [0, 0.1, 0.9, 1]
  
  @State private var height: Double = 0
  
  let topPadding: Double
  let bottomPadding: Double
  let topOpacity: Double
  let bottomOpacity: Double
  
  func body(content: Content) -> some View {
    content
      .mask(
        LinearGradient(
          stops: stops(),
          startPoint: .init(x: 0.5, y: 1),
          endPoint: .init(x: 0.5, y: 0)
        )
      )
      .onGeometryChange(
        for: CGFloat.self,
        of: { $0.size.height },
        action: { height = $0 }
      )
  }
  
  private func stops() -> [Gradient.Stop] {
    let locations = locations()
    return [
      .init(color: .white.opacity(topOpacity), location: locations[0]),
      .init(color: .black, location: locations[1]),
      .init(color: .black, location: locations[2]),
      .init(color: .white.opacity(bottomOpacity), location: locations[3])
    ]
  }
  
  private func locations() -> [Double] {
    guard height > topPadding + bottomPadding else {
      return Self.defaultLocations
    }
    
    let factor = 1 / height
    let bottom = min(1, factor * bottomPadding)
    let top = min(1, 1 - factor * topPadding)
    return [0, bottom, top, 1]
  }
}
