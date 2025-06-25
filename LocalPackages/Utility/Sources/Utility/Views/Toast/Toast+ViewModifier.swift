//
//  Toast+ViewModifier.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import SwiftUI

extension View {
  public func toast(
    _ style: ToastStyle,
    cornerRadius: CGFloat = 16,
    padding: EdgeInsets
  ) -> some View {
    modifier(
      ToastStyleModifier(
        style: style,
        cornerRadius: cornerRadius,
        padding: padding
      )
    )
  }
  
  @inlinable public func toast(
    _ style: ToastStyle,
    cornerRadius: CGFloat = 16,
    padding: CGFloat = 12
  ) -> some View {
    toast(
      style,
      cornerRadius: cornerRadius,
      padding: EdgeInsets(value: padding)
    )
  }
}

struct ToastStyleModifier: ViewModifier {
  private let style: ToastStyle
  
  private let cornerRadius: CGFloat
  private let padding: EdgeInsets

  init(
    style: ToastStyle,
    cornerRadius: CGFloat,
    padding: EdgeInsets
  ) {
    self.style = style
    self.cornerRadius = cornerRadius
    self.padding = padding
  }
  
  func body(content: Content) -> some View {
    let color = style.color()
    
    content
      .padding(padding)
      .preventPassthoughTouches()
      .background(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .inset(by: 0.5 * .strokeLineWidth)
          .fill(.ultraThinMaterial)
          .fill(color.opacity(0.12))
          .stroke(color, lineWidth: .strokeLineWidth)
          .shadow(color: color.opacity(0.2), radius: 6, x: 2, y: 2)
      )      
  }
}


/// Constants
private extension CGFloat {
  static let strokeLineWidth: CGFloat = 1.2
}
