//
//  InputFieldButtonStyle.swift
//  Utility
//
//  Created by Igor Nikolaev on 23.06.2025.
//

import SwiftUI

public struct InputFieldButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled: Bool
  
  @Binding var isFocused: Bool
  
  private let backgroundColor: Color
  private let borderColor: Color
  
  public init(
    isFocused: Binding<Bool>,
    backgroundColor: Color,
    borderColor: Color
  ) {
    _isFocused = isFocused
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
  }
  
  public init(
    isFocused: Binding<Bool>,
    color: Color
  ) {
    self.init(
      isFocused: isFocused,
      backgroundColor: color.opacity(0.2),
      borderColor: color.opacity(1)
    )
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    let isPressed = configuration.isPressed
    let isBordered = isEnabled && (isPressed || isFocused)
    
    return configuration.label
      .background(backgroundColor)
      .cornerRadius(.cornerRadius)
      .if(isBordered) {
        $0.overlay(
          RoundedRectangle(cornerRadius: .cornerRadius)
            .stroke(borderColor)
        )
      }
      .animation(.smooth, value: isBordered)
      .opacity(isEnabled ? 1 : 0.5)
      .animation(.smooth, value: isEnabled)
  }
}

extension InputFieldButtonStyle {
  public static func defaultStyle(isFocused: Binding<Bool>) -> InputFieldButtonStyle {
    InputFieldButtonStyle(
      isFocused: isFocused,
      color: .mainBackground
    )
  }
}


/// Constants
private extension CGFloat {
  static let cornerRadius: CGFloat = 12
}
