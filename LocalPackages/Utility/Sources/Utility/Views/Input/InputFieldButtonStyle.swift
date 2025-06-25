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
  
  private let animation: Animation
  
  public init(
    isFocused: Binding<Bool>,
    backgroundColor: Color,
    borderColor: Color,
    animation: Animation = .smooth
  ) {
    _isFocused = isFocused
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.animation = animation
  }
  
  public init(
    isFocused: Binding<Bool>,
    color: Color,
    animation: Animation = .smooth
  ) {
    self.init(
      isFocused: isFocused,
      backgroundColor: color.opacity(0.2),
      borderColor: color.opacity(1),
      animation: animation
    )
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    let isPressed = configuration.isPressed
    let isBordered = isEnabled && (isPressed || isFocused)
    
    let lineWidth: CGFloat = isBordered ? 1.5 : 0
    
    return configuration.label
      .background(backgroundColor)
      .cornerRadius(.cornerRadius)
      .overlay(
        RoundedRectangle(cornerRadius: .cornerRadius)
          .inset(by: 0.5 * lineWidth)
          .stroke(borderColor, lineWidth: lineWidth)
          .animation(animation, value: isBordered)
      )
      .opacity(isEnabled ? 1 : 0.5)
      .animation(animation, value: isEnabled)
  }
}

extension InputFieldButtonStyle {
  public static func defaultStyle(
    isFocused: Binding<Bool>,
    animation: Animation = .smooth
  ) -> InputFieldButtonStyle {
    InputFieldButtonStyle(
      isFocused: isFocused,
      color: .mainBackground,
      animation: animation
    )
  }
}


/// Constants
private extension CGFloat {
  static let cornerRadius: CGFloat = 12
}
