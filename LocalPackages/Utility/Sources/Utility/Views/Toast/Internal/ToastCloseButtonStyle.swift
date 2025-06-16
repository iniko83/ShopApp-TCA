//
//  ToastCloseButtonStyle.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import SwiftUI

/* Special Button Style for avoid "color jumping" via disappear. */

struct ToastCloseButtonStyle: ButtonStyle {
  @Binding var isClosed: Bool
  
  private let style: ToastStyle
  
  init(
    isClosed: Binding<Bool>,
    style: ToastStyle
  ) {
    _isClosed = isClosed
    self.style = style
  }
  
  func makeBody(configuration: Configuration) -> some View {
    let isFaded = configuration.isPressed || isClosed
    let opacity: Double = isFaded ? 0.5 : 1
    
    return configuration.label
      .foregroundStyle(.tint.opacity(opacity))
      .animation(.smooth, value: isFaded)
  }
}
