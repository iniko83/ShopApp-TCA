//
//  CellBackgroundButtonStyle.swift
//  Utility
//
//  Created by Igor Nikolaev on 21.06.2025.
//

import SwiftUI

/*
 Меняет только background кнопки (ячейки), не трогая фронт color.
 Opacity:
  enabled:  1.0
  disabled: 0.5
 */

extension ButtonStyle where Self == CellBackgroundButtonStyle {
  public static var highlightingCell: CellBackgroundButtonStyle {
    CellBackgroundButtonStyle()
  }
}

public struct CellBackgroundButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled: Bool
  
  public func makeBody(configuration: Configuration) -> some View {
    let isHighlighted = configuration.isPressed && isEnabled
    let backgroundColor: Color = isHighlighted
      ? .cellHighlighted
      : .transparent
    let opacity: Double = isEnabled ? 1 : 0.5
    
    return configuration
      .label
      .opacity(opacity)
      .background(backgroundColor)
  }
}
