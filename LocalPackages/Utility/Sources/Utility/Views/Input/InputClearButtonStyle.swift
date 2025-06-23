//
//  InputClearButtonStyle.swift
//  Utility
//
//  Created by Igor Nikolaev on 23.06.2025.
//

import SwiftUI

/* Special Button Style for avoid color "jumping" via disappear. */

struct InputClearButtonStyle: ButtonStyle {
  @Binding var isClosed: Bool
  
  func makeBody(configuration: Configuration) -> some View {
    let isFaded = configuration.isPressed || isClosed
    let opacity: Double = isFaded ? 0.5 : 1
    
    return configuration.label
      .foregroundStyle(.tint.opacity(opacity))
      .animation(.smooth, value: isFaded)
  }
}
