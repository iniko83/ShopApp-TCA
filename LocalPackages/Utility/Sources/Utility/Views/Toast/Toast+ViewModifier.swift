//
//  Toast+ViewModifier.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import SwiftUI

extension View {
  public func toast(_ style: ToastStyle) -> some View {
    modifier(ToastStyleModifier(style: style))
  }
}

struct ToastStyleModifier: ViewModifier {
  private let style: ToastStyle
  
  init(style: ToastStyle) {
    self.style = style
  }
  
  func body(content: Content) -> some View {
    let color = style.color()
    
    content
      .padding(12)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
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
